// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;
import "hardhat/console.sol";
import { IRouterAdapter } from "../intf/IRouterAdapter.sol";
import { ISwap, IPoolRegistry } from "../intf/IStableSwap.sol";
import { IERC20 } from "../../intf/IERC20.sol";
import { SafeMath } from "../../lib/SafeMath.sol";
import { UniERC20 } from "../../lib/UniERC20.sol";
import { SafeERC20 } from "../../lib/SafeERC20.sol";
import "hardhat/console.sol";

// In curve factory = registry
contract StableSwapNoRegistryAdapter is IRouterAdapter {
    using SafeMath for uint256;
    using UniERC20 for IERC20;
    using SafeERC20 for IERC20;
    address public constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // MetaSwap is a modified version of Swap that allows Swap's LP token to be utilized in pooling with other tokens.
    // As an example, if there is a Swap pool consisting of [DAI, USDC, USDT]. Then a MetaSwap pool can be created
    // with [sUSD, BaseSwapLPToken] to allow trades between either the LP token or the underlying tokens and sUSD.

    function getAmountOut(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool
    ) public view override returns (uint256 _output) {
        ISwap stableSwap = ISwap(pool);

        uint8 i = stableSwap.getTokenIndex(fromToken);
        uint8 j = stableSwap.getTokenIndex(toToken);
        _output = stableSwap.calculateSwap(i, j, amountIn);
    }

    function swapExactIn(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool,
        address to
    ) external payable override returns (uint256 _output) {
        IERC20(fromToken).universalApproveMax(pool, amountIn);
        ISwap stableSwap = ISwap(pool);
        uint8 i = stableSwap.getTokenIndex(fromToken);
        uint8 j = stableSwap.getTokenIndex(toToken);

        _output = stableSwap.swap(i, j, amountIn, 1, type(uint256).max);

        IERC20(toToken).uniTransfer(to, _output);
    }
}
