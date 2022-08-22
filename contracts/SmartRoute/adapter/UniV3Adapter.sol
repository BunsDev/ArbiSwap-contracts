// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.8.15;
import { ReentrancyGuard } from "../../lib/ReentrancyGuard.sol";
import { IRouterAdapter } from "../intf/IRouterAdapter.sol";
import { IWETH } from "../../intf/IWETH.sol";
import { IUniV3Pair, IUniswapV3SwapCallback } from "../intf/IUniV3.sol";
import { IERC20 } from "../../intf/IERC20.sol";
import { SafeMath } from "../../lib/SafeMath.sol";
import { SafeCast } from "../../lib/SafeCast.sol";
import { UniERC20 } from "../../lib/UniERC20.sol";
import { SafeERC20 } from "../../lib/SafeERC20.sol";

contract UniV3Adapter is IRouterAdapter, IUniswapV3SwapCallback {
    using SafeMath for uint256;
    using SafeCast for uint256;
    using SafeCast for int256;
    using UniERC20 for IERC20;
    using SafeERC20 for IERC20;
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;
    /// @dev The minimum value that can be returned from SqrtRatioAtTick.
    uint160 public constant MIN_SQRT_RATIO = 4295128739;
    /// @dev The maximum value that can be returned from SqrtRatioAtTick.
    uint160 public constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

    address public immutable _Factory_;
    address payable public immutable _WETH_ADDRESS_;
    address public constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(address payable __WETH_ADDRESS_, address _factory) {
        _WETH_ADDRESS_ = __WETH_ADDRESS_;
        _Factory_ = _factory;
    }

    struct SwapCallbackData {
        bytes path;
        address payer;
        uint256 isQuote;
    }

    /// @notice Deterministically computes the pool address given the factory and PoolKey
    /// @param token0 token0 address
    /// @param token1 token1 address
    /// @param fee fee
    /// @return pool The contract address of the V3 pool
    function computeAddress(
        address token0,
        address token1,
        uint24 fee
    ) internal view returns (address pool) {
        require(token0 < token1);
        pool = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            _Factory_,
                            keccak256(abi.encode(token0, token1, fee)),
                            POOL_INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }

    /// @notice Returns the address of a valid Uniswap V3 Pool
    /// @param tokenA tokenA address
    /// @param tokenB tokenB address
    /// @param fee fee
    /// @return pool The V3 pool contract address
    function verifyCallback(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal view returns (address pool) {
        if (tokenA < tokenB) {
            pool = computeAddress(tokenA, tokenB, fee);
        } else {
            pool = computeAddress(tokenB, tokenA, fee);
        }
        require(msg.sender == pool);
    }

    /// @dev Parses a revert reason that should contain the numeric quote
    function parseRevertReason(bytes memory reason) private pure returns (uint256) {
        if (reason.length != 32) {
            if (reason.length < 68) revert("Unexpected error");
            assembly {
                reason := add(reason, 0x04)
            }
            revert(abi.decode(reason, (string)));
        }
        return abi.decode(reason, (uint256));
    }

    function factory(address pool) public view returns (address) {
        return IUniV3Pair(pool).factory();
    }

    function getAmountOut(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool
    ) public override returns (uint256 _output) {
        require(amountIn > 0, "UniswapV3Library: INSUFFICIENT_INPUT_AMOUNT");

        bool zeroForOne = fromToken < toToken;

        SwapCallbackData memory swapCallBack;
        swapCallBack.path = abi.encodePacked(fromToken, toToken, IUniV3Pair(pool).fee());
        swapCallBack.payer = address(0);
        swapCallBack.isQuote = 1;

        try
            IUniV3Pair(pool).swap(
                address(this), // address(0) might cause issues with some tokens
                zeroForOne,
                amountIn.toInt256(),
                (zeroForOne ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1),
                abi.encode(swapCallBack)
            )
        {} catch (bytes memory reason) {
            return parseRevertReason(reason);
        }
    }

    function swapExactIn(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool,
        address to
    ) external override returns (uint256 _output) {
        bool zeroForOne = IUniV3Pair(pool).token0() == fromToken;

        SwapCallbackData memory swapCallBack;
        swapCallBack.path = abi.encodePacked(fromToken, toToken, IUniV3Pair(pool).fee());
        swapCallBack.payer = msg.sender;
        swapCallBack.isQuote = 0;

        (int256 amount0, int256 amount1) = IUniV3Pair(pool).swap(
            to,
            zeroForOne,
            amountIn.toInt256(),
            (zeroForOne ? MIN_SQRT_RATIO + 1 : MAX_SQRT_RATIO - 1),
            abi.encode(swapCallBack)
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
        (address tokenIn, address tokenOut, uint24 fee) = abi.decode(data.path, (address, address, uint24));

        verifyCallback(tokenIn, tokenOut, fee);

        (bool isExactInput, uint256 amountToPay, uint256 amountReceived) = amount0Delta > 0
            ? (tokenIn < tokenOut, uint256(amount0Delta), uint256(-amount1Delta))
            : (tokenOut < tokenIn, uint256(amount1Delta), uint256(-amount0Delta));

        require(isExactInput, "Only exact input");
        if (data.isQuote == 1) {
            assembly {
                let ptr := mload(0x40)
                mstore(ptr, amountReceived)
                revert(ptr, 32)
            }
        } else if (data.isQuote == 0) {
            pay(tokenIn, msg.sender, amountToPay);
        } else {
            revert("invalid isQuote");
        }
    }

    /// @param token The token to pay
    /// @param recipient The entity that will receive payment
    /// @param value The amount to pay
    function pay(
        address token,
        address recipient,
        uint256 value
    ) internal {
        if (token == _ETH_ADDRESS_ && address(this).balance >= value) {
            // pay with WETH9
            IWETH(_WETH_ADDRESS_).deposit{ value: value }(); // wrap only what is needed to pay
            IERC20(_WETH_ADDRESS_).safeTransfer(recipient, value);
        } else {
            // pay with tokens already in the contract (for the exact input multihop case)
            IERC20(token).safeTransfer(recipient, value);
        }
    }
}
