// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;
import { ReentrancyGuard } from "../../lib/ReentrancyGuard.sol";
import { IRouterAdapter } from "../intf/IRouterAdapter.sol";
import { IUniswapV2Pair } from "../intf/IUniV2.sol";
import { IERC20 } from "../../intf/IERC20.sol";
import { SafeMath } from "../../lib/SafeMath.sol";

contract UniV2Adapter is IRouterAdapter {
    using SafeMath for uint256;

    function factory(address pool) public view returns (address) {
        return IUniswapV2Pair(pool).factory();
    }

    function getAmountOut(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool
    ) public override returns (uint256 _output) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");

        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(pool).getReserves();
        require(reserve0 > 0 && reserve1 > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");

        uint256 reserveInput;
        uint256 reserveOutput;
        address token0 = IUniswapV2Pair(pool).token0();
        if (fromToken == token0) {
            (reserveInput, reserveOutput) = (reserve0, reserve1);
            require(toToken == token0, "invalid token pair");
        } else if (toToken == token0) {
            (reserveInput, reserveOutput) = (reserve1, reserve0);
            require(fromToken == token0, "invalid token pair");
        } else {
            revert("invalid token pair");
        }

        try IUniswapV2Pair(pool).swapFee() returns (uint32 _fee) {
            uint256 amountInWithFee = amountIn.mul(uint256(10000).sub(_fee));
            uint256 numerator = amountInWithFee.mul(reserveOutput);
            uint256 denominator = reserveInput.mul(10000).add(amountInWithFee);
            _output = numerator / denominator;
        } catch {
            uint256 amountInWithFee = amountIn.mul(997);
            uint256 numerator = amountInWithFee.mul(reserveOutput);
            uint256 denominator = reserveInput.mul(1000).add(amountInWithFee);
            _output = numerator / denominator;
        }
    }

    function swapExactIn(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool,
        address to
    ) external override returns (uint256 _output) {
        _output = getAmountOut(fromToken, amountIn, toToken, pool);
        (uint256 amount0Out, uint256 amount1Out) = fromToken == IUniswapV2Pair(pool).token0()
            ? (uint256(0), _output)
            : (_output, uint256(0));
        IUniswapV2Pair(pool).swap(amount0Out, amount1Out, to, new bytes(0));
    }
}
