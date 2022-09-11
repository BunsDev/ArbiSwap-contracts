// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;
import "hardhat/console.sol";
import { IRouterAdapter } from "../intf/IRouterAdapter.sol";
import {
    ICurveProvider,
    ICurveRegistry,
    ICurveCryptoRegistry,
    ICurveFactoryRegistry,
    ICurve,
    ICurveCrypto
} from "../intf/ICurve.sol";
import { IERC20 } from "../../intf/IERC20.sol";
import { SafeMath } from "../../lib/SafeMath.sol";
import { UniERC20 } from "../../lib/UniERC20.sol";
import { SafeERC20 } from "../../lib/SafeERC20.sol";
import "hardhat/console.sol";

// In curve factory = registry
contract CurveAdapter is IRouterAdapter {
    using SafeMath for uint256;
    using UniERC20 for IERC20;
    using SafeERC20 for IERC20;
    address public constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address public immutable _WETH_ADDRESS_;
    address public immutable registry;
    address public immutable cryptoRegistry;
    address public immutable factoryRegistry;
    address public immutable cryptoFactoryRegistry;

    mapping(address => address[2]) public baseCoins;

    constructor(
        address __WETH_ADDRESS_,
        address _registry,
        address _cryptoRegistry,
        address _factoryRegistry,
        address _cryptoFactoryRegistry
    ) {
        _WETH_ADDRESS_ = __WETH_ADDRESS_;
        registry = _registry;
        cryptoRegistry = _cryptoRegistry;
        factoryRegistry = _factoryRegistry;
        cryptoFactoryRegistry = _cryptoFactoryRegistry;
    }

    function _getAmountOutCurve(
        address _registry,
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool
    ) internal view returns (uint256 _output) {
        require(amountIn > 0, "Curve: INSUFFICIENT_INPUT_AMOUNT");

        (int128 i, int128 j, bool isUnder) = ICurveRegistry(_registry).get_coin_indices(pool, fromToken, toToken);
        if (isUnder && (_registry == registry || ICurveRegistry(_registry).is_meta(pool))) {
            _output = ICurve(pool).get_dy_underlying(i, j, amountIn);
        } else {
            _output = ICurve(pool).get_dy(i, j, amountIn);
        }
    }

    function _getAmountOutCryptoCurve(
        address _registry,
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool
    ) internal view returns (uint256 _output) {
        require(amountIn > 0, "Curve: INSUFFICIENT_INPUT_AMOUNT");

        (uint256 i, uint256 j) = ICurveCryptoRegistry(_registry).get_coin_indices(pool, fromToken, toToken);

        _output = ICurveCrypto(pool).get_dy(i, j, amountIn);
    }

    function getAmountOut(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool
    ) public view override returns (uint256 _output) {
        console.log("In Curve");
        console.log(fromToken);
        console.log(toToken);
        console.log(amountIn);
        if (ICurveRegistry(registry).get_lp_token(pool) != address(0)) {
            // console.log("get_lp_token registry result %s", ICurveRegistry(registry).get_lp_token(pool));
            _output = _getAmountOutCurve(registry, fromToken, amountIn, toToken, pool);
        } else {
            if (ICurveFactoryRegistry(factoryRegistry).get_coins(pool)[0] != address(0)) {
                // console.log(
                //     "get_coins factory registry result %s",
                //     ICurveFactoryRegistry(factoryRegistry).get_coins(pool)[0]
                // );

                _output = _getAmountOutCurve(factoryRegistry, fromToken, amountIn, toToken, pool);
            } else {
                // console.log(
                //     "get_lp_token crypto registry result %s",
                //     ICurveCryptoRegistry(cryptoRegistry).get_lp_token(pool)
                // );
                _output = _getAmountOutCryptoCurve(
                    ICurveCryptoRegistry(cryptoRegistry).get_lp_token(pool) != address(0)
                        ? cryptoRegistry
                        : cryptoFactoryRegistry,
                    fromToken,
                    amountIn,
                    toToken,
                    pool
                );
            }
        }
    }

    function _swapExactInCurve(
        address _registry,
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool
    ) internal {
        require(amountIn > 0, "Curve: INSUFFICIENT_INPUT_AMOUNT");
        (int128 i, int128 j, bool isUnder) = ICurveRegistry(_registry).get_coin_indices(pool, fromToken, toToken);
        uint256 ethAmount;
        if (fromToken == _ETH_ADDRESS_) {
            ethAmount = amountIn;
        }
        if (isUnder && _registry == factoryRegistry && ICurveRegistry(_registry).is_meta(pool)) {
            address[2] memory _baseCoins = baseCoins[pool];
            if (_baseCoins[0] == address(0)) {
                _baseCoins = [ICurve(pool).coins(0), ICurve(pool).coins(1)];
                baseCoins[pool] = _baseCoins;
            }
            isUnder =
                (fromToken != _baseCoins[0] && fromToken != _baseCoins[1]) ||
                (toToken != _baseCoins[0] && toToken != _baseCoins[1]);
        }

        if (isUnder) {
            ICurve(pool).exchange_underlying{ value: ethAmount }(i, j, amountIn, 1);
        } else {
            ICurve(pool).exchange{ value: ethAmount }(i, j, amountIn, 1);
        }
    }

    function _swapExactInCryptoCurve(
        address _registry,
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool
    ) internal {
        require(amountIn > 0, "Curve: INSUFFICIENT_INPUT_AMOUNT");
        address _fromToken;
        address _toToken;
        if (fromToken == _ETH_ADDRESS_) {
            _fromToken = _WETH_ADDRESS_;
        }
        if (toToken == _ETH_ADDRESS_) {
            _toToken = _WETH_ADDRESS_;
        }

        (uint256 i, uint256 j) = ICurveCryptoRegistry(_registry).get_coin_indices(pool, fromToken, toToken);
        uint256 ethAmount;
        if (fromToken == _ETH_ADDRESS_) {
            ethAmount = amountIn;
        }
        if (fromToken == _ETH_ADDRESS_ || toToken == _ETH_ADDRESS_) {
            ICurveCrypto(pool).exchange{ value: ethAmount }(i, j, amountIn, 1, true);
        } else {
            ICurveCrypto(pool).exchange(i, j, amountIn, 1);
        }
    }

    function swapExactIn(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool,
        address to
    ) external payable override returns (uint256 _output) {
        IERC20(fromToken).universalApproveMax(pool, amountIn);
        if (ICurveRegistry(registry).get_lp_token(pool) != address(0)) {
            _swapExactInCurve(registry, fromToken, amountIn, toToken, pool);
        } else {
            if (ICurveFactoryRegistry(factoryRegistry).get_coins(pool)[0] != address(0)) {
                _swapExactInCurve(factoryRegistry, fromToken, amountIn, toToken, pool);
            } else {
                _swapExactInCryptoCurve(
                    ICurveCryptoRegistry(cryptoRegistry).get_lp_token(pool) != address(0)
                        ? cryptoRegistry
                        : cryptoFactoryRegistry,
                    fromToken,
                    amountIn,
                    toToken,
                    pool
                );
            }
        }
        _output = IERC20(toToken).uniBalanceOf(address(this));

        IERC20(toToken).uniTransfer(to, _output);
    }
}
