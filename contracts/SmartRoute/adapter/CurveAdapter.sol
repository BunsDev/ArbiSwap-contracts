// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;
import { IRouterAdapter } from "../intf/IRouterAdapter.sol";
import { ICurveProvider, ICurveRegistry, ICurve } from "../intf/ICurve.sol";
import { IERC20 } from "../../intf/IERC20.sol";
import { SafeMath } from "../../lib/SafeMath.sol";
import { UniERC20 } from "../../lib/UniERC20.sol";

// In curve factory = registry
contract CurveAdapter is IRouterAdapter {
    using SafeMath for uint256;
    using UniERC20 for IERC20;

    address[] public registries;

    constructor(address[] memory _registries) {
        registries = _registries;
    }

    function _setRegistries(address[] memory _registries) internal {
        registries = _registries;
    }

    function setRegistries(address[] memory _registries) external onlyOwner {
        _setRegistries(_registries);
    }

    function getRegistries() external view returns (address[] memory) {
        address[] memory _registries = new address[](registries.length);
        for (uint256 i; i < registries.length; i++) {
            _registries[i] = registries[i];
        }
        return _registries;
    }

    function _getAmountOut(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool
    )
        internal
        view
        returns (
            uint256 _output,
            int128,
            int128,
            bool
        )
    {
        require(amountIn > 0, "Curve: INSUFFICIENT_INPUT_AMOUNT");

        address registry;
        for (uint256 k; k < registries.length; k++) {
            if (ICurveRegistry(registries[k]).get_lp_token(pool) != address(0)) {
                registry = registries[k];
                break;
            }
        }

        require(registry != address(0), "Pool is not registered");

        (int128 i, int128 j, bool isUnder) = ICurveRegistry(registry).get_coin_indices(pool, fromToken, toToken);
        if (isUnder) {
            _output = ICurve(pool).get_dy_underlying(i, j, amountIn);
        } else {
            _output = ICurve(pool).get_dy(i, j, amountIn);
        }

        return (_output, i, j, isUnder);
    }

    function getAmountOut(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool
    ) public view override returns (uint256 _output) {
        (_output, , , ) = _getAmountOut(fromToken, amountIn, toToken, pool);
    }

    function swapExactIn(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool,
        address to
    ) external override returns (uint256 _output) {
        bool isUnder;
        int128 i;
        int128 j;
        (_output, i, j, isUnder) = _getAmountOut(fromToken, amountIn, toToken, pool);

        IERC20(fromToken).universalApproveMax(pool, amountIn);

        if (isUnder) {
            ICurve(pool).exchange_underlying(i, j, amountIn, 1);
        } else {
            ICurve(pool).exchange(i, j, amountIn, 1);
        }

        IERC20(toToken).uniTransfer(to, _output);
    }
}
