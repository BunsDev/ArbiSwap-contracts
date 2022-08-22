// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;
import { ReentrancyGuard } from "../../lib/ReentrancyGuard.sol";
import { IRouterAdapter } from "../intf/IRouterAdapter.sol";
import { IWETH } from "../../intf/IWETH.sol";
import { IUniV3Pair, IUniswapV3SwapCallback } from "../intf/IUniV3.sol";
import { IERC20 } from "../../intf/IERC20.sol";
import { SafeMath } from "../../lib/SafeMath.sol";

// to adapter like dodo V1
contract UniV3Adapter is IRouterAdapter, IUniswapV3SwapCallback {
    using SafeMath for uint256;
    /// @dev The minimum value that can be returned from SqrtRatioAtTick.
    uint160 public constant MIN_SQRT_RATIO = 4295128739;
    /// @dev The maximum value that can be returned from SqrtRatioAtTick.
    uint160 public constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    address public immutable _WETH_ADDRESS_;
    address public constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(address __WETH_ADDRESS_) {
        _WETH_ADDRESS_ = __WETH_ADDRESS_;
    }

    struct SwapCallbackData {
        bytes path;
        address payer;
    }

    function factory(address pool) public view returns (address) {
        return IUniV3Pair(pool).factory();
    }

    // TODO
    function getAmountOut(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool
    ) public view override returns (uint256 _output) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");

        (uint256 reserve0, uint256 reserve1, ) = IUni(pool).getReserves();
        require(reserve0 > 0 && reserve1 > 0, "UniswapV2Library: INSUFFICIENT_LIQUIDITY");

        uint256 reserveInput;
        uint256 reserveOutput;
        address token0 = IUniV3Pair(pool).token0();
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
        bool zeroForOne = IUniV3Pair(pool).token(0) == fromToken;

        bytes memory path = abi.encodePacked(fromToken, IUniV3Pair(pool).fee(), toToken);
        SwapCallbackData memory swapCallBack;
        swapCallBack.path = path;
        swapCallBack.payer = msg.sender;

        IERC20(fromToken).universalApproveMax(pool, amountIn);

        (int256 amount0, int256 amount1) = IUniV3Pair(pool).swap(
            to,
            zeroForOne,
            amountIn.toInt256(),
            (zeroForOne ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1),
            abi.encodePacked(swapCallBack)
        );

        _output = uint256(-(zeroForOne ? amount1 : amount0));
    }

    // for uniV3 callback
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata _data
    ) external override {
        require(amount0Delta > 0 || amount1Delta > 0); // swaps entirely within 0-liquidity regions are not supported
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        (address tokenIn, address tokenOut, ) = abi.decode(data.path, (address, address, uint24));

        (bool isExactInput, uint256 amountToPay) = amount0Delta > 0
            ? (tokenIn < tokenOut, uint256(amount0Delta))
            : (tokenOut < tokenIn, uint256(amount1Delta));
        if (isExactInput) {
            pay(tokenIn, address(this), msg.sender, amountToPay);
        } else {
            tokenIn = tokenOut; // swap in/out because exact output swaps are reversed
            pay(tokenIn, address(this), msg.sender, amountToPay);
        }
    }

    /// @param token The token to pay
    /// @param payer The entity that must pay
    /// @param recipient The entity that will receive payment
    /// @param value The amount to pay
    function pay(
        address token,
        address payer,
        address recipient,
        uint256 value
    ) internal {
        if (token == _ETH_ADDRESS_ && address(this).balance >= value) {
            // pay with WETH9
            IWETH(_WETH_ADDRESS_).deposit{ value: value }(); // wrap only what is needed to pay
            IWETH(_WETH_ADDRESS_).transfer(recipient, value);
        } else if (payer == address(this)) {
            // pay with tokens already in the contract (for the exact input multihop case)
            IERC20(token).safeTransfer(recipient, value);
        } else {
            // pull payment
            IERC20(token).safeTransferFrom(payer, recipient, value);
        }
    }
}
