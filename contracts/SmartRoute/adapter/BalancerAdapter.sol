// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;
import { IRouterAdapter } from "../intf/IRouterAdapter.sol";
import { IBalancerVault, IBalancerPool, IBalancerRegistry } from "../intf/IBalancer.sol";
import { IERC20 } from "../../intf/IERC20.sol";
import { FixedPoint } from "../../lib/FixedPoint.sol";
import { UniERC20 } from "../../lib/UniERC20.sol";

contract BalancerAdapter is IRouterAdapter {
    using UniERC20 for IERC20;

    function vault(address pool) public view returns (address) {
        return IBalancerPool(pool).getVault();
    }

    function getAmountOut(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool
    ) public view override returns (uint256 _output) {
        bytes memory poolId = IBalancerPool(pool).getPoolId();

        IBalancerVault vault = IBalancerVault(IBalancerPool(pool).getVault());

        SwapRequest memory request;
        request.kind = vault.SwapKind.GIVEN_IN;
        request.assetIn = IERC20(fromToken);
        request.assetOut = IERC20(toToken);
        request.amount = amountIn;
        request.poolId = poolId;

        (uint256 fromBalance, , , ) = vault.getPoolTokenInfo(poolId, IERC20(fromToken));
        (uint256 toBalance, , , ) = vault.getPoolTokenInfo(poolId, IERC20(toToken));

        _output = IBalancerPool(pool).onSwap(request, fromBalance, toBalance);
    }

    function swapExactIn(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool,
        address to
    ) external override returns (uint256 _output) {
        IBalancerVault.SingleSwap memory singleswap;
        singleswap.poolId = IBalancerPool(pool).getPoolId();
        singleswap.kind = IBalancerVault.SwapKind.GIVEN_IN;
        singleswap.assetIn = fromToken;
        singleswap.assetOut = toToken;
        singleswap.amount = amountIn;

        IBalancerVault.FundManagement memory fundManagement;
        fundManagement.sender = address(this);
        fundManagement.fromInternalBalance = false;
        fundManagement.recipient = to;
        fundManagement.toInternalBalance = false;

        IERC20(fromToken).universalApproveMax(IBalancerPool(pool).getVault(), amountIn);

        _output = IBalancerVault(IBalancerPool(pool).getVault()).swap(singleswap, fundManagement, 1, type(uint256).max);
    }
}
