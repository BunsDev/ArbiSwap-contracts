// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;
import "hardhat/console.sol";
import { IRouterAdapter } from "../intf/IRouterAdapter.sol";
import { ICurve } from "../intf/ICurve.sol";
import { IERC20 } from "../../intf/IERC20.sol";
import { SafeMath } from "../../lib/SafeMath.sol";
import { UniERC20 } from "../../lib/UniERC20.sol";
import { SafeERC20 } from "../../lib/SafeERC20.sol";
import { SafeCast } from "../../lib/SafeCast.sol";
import "hardhat/console.sol";

// In curve factory = registry
contract CurveNoRegistryAdapter is IRouterAdapter {
    using SafeMath for uint256;
    using SafeCast for uint256;
    using SafeCast for int256;
    using UniERC20 for IERC20;
    using SafeERC20 for IERC20;
    address public constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address public immutable basePool;
    address[3] public baseCoins;

    constructor(address _basePool) {
        basePool = _basePool;
    }

    function getCoinIndices(
        address pool,
        address fromToken,
        address toToken,
        uint8 isMeta
    ) internal returns (int128 i, int128 j) {
        i = -1;
        j = -1;
        if (isMeta == 1) {
            for (uint256 k; k < 3; k++) {
                baseCoins[k] = ICurve(pool).coins(k);
                if (fromToken == baseCoins[k]) {
                    i = k.toInt256().toInt128() + 1;
                } else if (toToken == baseCoins[k]) {
                    j = k.toInt256().toInt128() + 1;
                }
            }

            if (i == -1) {
                if (fromToken == ICurve(pool).coins(0)) {
                    i = 0;
                }
            } else if (j == -1) {
                if (toToken == ICurve(pool).coins(0)) {
                    j = 0;
                }
            }
        } else {
            if (baseCoins[0] == address(0)) {
                for (uint256 k; k < 3; k++) {
                    baseCoins[k] = ICurve(pool).coins(k);
                    if (fromToken == baseCoins[k]) {
                        i = k.toInt256().toInt128();
                    } else if (toToken == baseCoins[k]) {
                        j = k.toInt256().toInt128();
                    }
                }
            } else {
                for (uint256 k; k < 3; k++) {
                    baseCoins[k] = ICurve(pool).coins(k);
                    if (fromToken == baseCoins[k]) {
                        i = k.toInt256().toInt128();
                    } else if (toToken == baseCoins[k]) {
                        j = k.toInt256().toInt128();
                    }
                }
            }
        }
    }

    function getAmountOut(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool
    ) public override returns (uint256 _output) {
        if (pool == basePool) {
            (int128 i, int128 j) = getCoinIndices(pool, fromToken, toToken, 0);
            _output = ICurve(pool).get_dy(i, j, amountIn);
        } else {
            (int128 i, int128 j) = getCoinIndices(pool, fromToken, toToken, 1);
            _output = ICurve(pool).get_dy(i, j, amountIn);
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

        if (pool == basePool) {
            (int128 i, int128 j) = getCoinIndices(pool, fromToken, toToken, 0);
            ICurve(pool).exchange(i, j, amountIn, 1);
        } else {
            (int128 i, int128 j) = getCoinIndices(pool, fromToken, toToken, 1);
            ICurve(pool).exchange_underlying(i, j, amountIn, 1);
        }
        _output = IERC20(toToken).uniBalanceOf(address(this));

        IERC20(toToken).uniTransfer(to, _output);
    }
}
