// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;
import { IRouterAdapter } from "../intf/IRouterAdapter.sol";
import { IBalancerVault, IBalancerPool, IBalancerRegistry } from "../intf/IBalancer.sol";
import { IERC20 } from "../../intf/IERC20.sol";
import { FixedPoint } from "../../lib/FixedPoint.sol";
import { UniERC20 } from "../../lib/UniERC20.sol";

contract BalancerAdapter is IRouterAdapter {
    using UniERC20 for IERC20;
    address public constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function vault(address pool) public view returns (address) {
        return IBalancerPool(pool).getVault();
    }

    function getAmountOut(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool
    ) public override returns (uint256 _output) {
        bytes32 poolId = IBalancerPool(pool).getPoolId();

        IBalancerVault _vault = IBalancerVault(IBalancerPool(pool).getVault());

        IBalancerPool.SwapRequest memory request;
        request.kind = IBalancerVault.SwapKind.GIVEN_IN;
        request.tokenIn = fromToken;
        request.tokenOut = toToken;
        request.amount = amountIn;
        request.poolId = poolId;

        (uint256 fromBalance, , , ) = _vault.getPoolTokenInfo(poolId, fromToken);
        (uint256 toBalance, , , ) = _vault.getPoolTokenInfo(poolId, toToken);

        _output = IBalancerPool(pool).onSwap(request, fromBalance, toBalance);
    }

    function swapExactIn(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool,
        address to
    ) external payable override returns (uint256 _output) {
        IBalancerVault.SingleSwap memory singleswap;
        singleswap.poolId = IBalancerPool(pool).getPoolId();
        singleswap.kind = IBalancerVault.SwapKind.GIVEN_IN;
        singleswap.tokenIn = fromToken;
        singleswap.tokenOut = toToken;
        singleswap.amount = amountIn;

        IBalancerVault.FundManagement memory fundManagement;
        fundManagement.sender = address(this);
        fundManagement.fromInternalBalance = false;
        fundManagement.recipient = payable(to);
        fundManagement.toInternalBalance = false;

        IERC20(fromToken).universalApproveMax(IBalancerPool(pool).getVault(), amountIn);

        _output = IBalancerVault(IBalancerPool(pool).getVault()).swap{
            value: fromToken == _ETH_ADDRESS_ ? amountIn : 0
        }(singleswap, fundManagement, 1, type(uint256).max);
    }
}
