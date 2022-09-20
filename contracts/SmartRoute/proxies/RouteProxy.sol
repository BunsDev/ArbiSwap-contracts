// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import { IApproveProxy } from "../ApproveProxy.sol";
import { IERC20 } from "../../intf/IERC20.sol";
import { IWETH } from "../../intf/IWETH.sol";
import { SafeMath } from "../../lib/SafeMath.sol";
import { ReentrancyGuard } from "../../lib/ReentrancyGuard.sol";
import { Withdrawable } from "../../lib/Withdrawable.sol";
import { UniERC20 } from "../../lib/UniERC20.sol";
import { SafeERC20 } from "../../lib/SafeERC20.sol";
import { MultiAMMLib } from "../../lib/MultiAMMLib.sol";
import { IRouterAdapter } from "../intf/IRouterAdapter.sol";

import { IFlashLoanReceiver, IFlashLoan } from "../intf/IFlashLoanV1.sol";

import { ILendingPoolAddressesProviderV2 } from "../intf/ILendingPoolAddressesProviderV2.sol";
import { ILendingPoolV2 } from "../intf/ILendingPoolV2.sol";

import "hardhat/console.sol";

/**
 * @title RouteProxy
 * @author fortoon21
 *
 * @notice Split trading
 * Need to wrap eth address in the following pool convention
 */
contract RouteProxy is IFlashLoanReceiver, Withdrawable, ReentrancyGuard {
    using SafeMath for uint256;
    using UniERC20 for IERC20;
    using SafeERC20 for IERC20;

    receive() external payable {}

    // ============ Storage ============

    uint256 constant _DEFAULT_WO_FEE_ = 999000; // 0.1% trading fee from output
    uint256 constant _FEE_DENOMINATOR_ = 1000000;
    address constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address payable public immutable _WETH_ADDRESS_;
    address public immutable _APPROVE_PROXY_;
    address public immutable LENDING_POOL;

    // ============ Events ============

    event OrderHistory(
        address fromToken,
        address toToken,
        address sender,
        uint256 fromAmount,
        uint256 returnAmount,
        uint256 deductedFee
    );

    // ============ Modifiers ============

    modifier checkDeadline(uint256 deadLine) {
        require(deadLine >= block.timestamp, "RouteProxy: EXPIRED");
        _;
    }

    fallback() external payable {}

    constructor(
        address approveProxy,
        address _defaultFlashloan,
        address payable __WETH_ADDRESS_
    ) {
        _APPROVE_PROXY_ = approveProxy;
        LENDING_POOL = _defaultFlashloan;
        _WETH_ADDRESS_ = __WETH_ADDRESS_;
    }

    /**
     * @dev This function executes sequential swaps without spliting input amount (100%)
     *
     * A 100% [ UNI2 ] B [ CURVE] C
     *
     * @param fromToken for WETH, ETH, address(eee...), for ERC20, its own address
     * @param amountIn input amount of fromToken
     * @param toToken for WETH, ETH, address(eee...), for ERC20, its own address
     * @param pathInfos Sequential swaps information
     * @param minReturnAmount minimum return amount
     * @param deadLine blocktime limit
     */
    function multiHopSingleSwap(
        address fromToken,
        uint256 amountIn,
        address toToken,
        MultiAMMLib.Swap[] calldata pathInfos,
        uint256 minReturnAmount,
        uint256 deadLine,
        uint16[2] calldata isWETH
    ) public payable checkDeadline(deadLine) nonReentrant returns (uint256[] memory outputs) {
        // debug
        require(minReturnAmount > 0, "minReturn should be larger than 0");

        require(
            pathInfos[0].fromToken == fromToken &&
                pathInfos[0].amountIn == amountIn &&
                pathInfos[pathInfos.length - 1].toToken == toToken,
            "not same input"
        );

        _deposit(msg.sender, isWETH[0] == 1 ? _WETH_ADDRESS_ : fromToken, amountIn);

        // weth came to routeproxy at first so unwrap weth to eth
        if (isWETH[0] == 1) {
            require(fromToken == _ETH_ADDRESS_, "Not valid fromToken");
            IWETH(_WETH_ADDRESS_).withdraw(amountIn);
        }
        outputs = _multiHopSingleSwap(pathInfos);
        uint256 realOutput = outputs[outputs.length - 1].mul(_DEFAULT_WO_FEE_).div(_FEE_DENOMINATOR_);
        require(realOutput >= minReturnAmount, "out of slippage");

        if (isWETH[1] == 1) {
            require(toToken == _ETH_ADDRESS_, "Not valid toToken");
            IWETH(_WETH_ADDRESS_).deposit{ value: realOutput }();
            IERC20(_WETH_ADDRESS_).safeTransfer(pathInfos[pathInfos.length - 1].to, realOutput);
        } else {
            IERC20(toToken).uniTransfer(pathInfos[pathInfos.length - 1].to, realOutput);
        }

        emit OrderHistory(
            fromToken,
            toToken,
            msg.sender,
            amountIn,
            realOutput,
            outputs[outputs.length - 1] - realOutput
        );
    }

    /**
     * @dev This function estimates sequential swaps without spliting input amount (100%)
     *
     * A 100% [ UNI2 ] B [ CURVE] C
     *
     * @param fromToken for WETH, ETH, address(eee...), for ERC20, its own address
     * @param amountIn input amount of fromToken
     * @param toToken for WETH, ETH, address(eee...), for ERC20, its own address
     * @param pathInfos Sequential swaps information
     */
    function getMultiHopSingleSwapOut(
        address fromToken,
        uint256 amountIn,
        address toToken,
        MultiAMMLib.Swap[] calldata pathInfos
    ) public returns (uint256[] memory outputs) {
        require(
            pathInfos[0].fromToken == fromToken &&
                pathInfos[0].amountIn == amountIn &&
                pathInfos[pathInfos.length - 1].toToken == toToken,
            "not same input"
        );

        outputs = _calcMultiHopSingleSwap(pathInfos);
    }

    /**
     * @dev This function executes the single swap with multiple pool paths which have the same input token and output token by spliting input amount
     *
     * A 50% [ UNI2 ] B
     *   30% [ CURVE]
     *   20% [ UNI3 ]
     *
     * @param fromToken for WETH, ETH, address(eee...), for ERC20, its own address
     * @param amountIn input amount of fromToken
     * @param toToken for WETH, ETH, address(eee...), for ERC20, its own address
     * @param weightPathInfo spliting input amount to multiple pools swap information
     * @param minReturnAmount minimum return amount
     * @param deadLine blocktime limit
     */
    function singleHopMultiSwap(
        address fromToken,
        uint256 amountIn,
        address toToken,
        MultiAMMLib.WeightedSwap calldata weightPathInfo,
        uint256 minReturnAmount,
        uint256 deadLine,
        uint16[2] calldata isWETH
    ) public payable checkDeadline(deadLine) nonReentrant returns (uint256 output) {
        // debug
        require(minReturnAmount > 0, "minReturn should be larger than 0");

        require(
            weightPathInfo.fromToken == fromToken &&
                weightPathInfo.amountIn == amountIn &&
                weightPathInfo.toToken == toToken,
            "not same input"
        );
        _deposit(msg.sender, isWETH[0] == 1 ? _WETH_ADDRESS_ : fromToken, amountIn);

        // weth came to routeproxy at first so unwrap weth to eth
        if (isWETH[0] == 1) {
            require(fromToken == _ETH_ADDRESS_, "Not valid fromToken");
            IWETH(_WETH_ADDRESS_).withdraw(amountIn);
        }
        output = _singleHopMultiSwap(weightPathInfo);

        uint256 realOutput = output.mul(_DEFAULT_WO_FEE_).div(_FEE_DENOMINATOR_);
        require(realOutput >= minReturnAmount, "out of slippage");

        if (isWETH[1] == 1) {
            require(toToken == _ETH_ADDRESS_, "Not valid toToken");
            IWETH(_WETH_ADDRESS_).deposit{ value: realOutput }();
            IERC20(_WETH_ADDRESS_).safeTransfer(weightPathInfo.to, realOutput);
        } else {
            IERC20(toToken).uniTransfer(weightPathInfo.to, realOutput);
        }

        emit OrderHistory(fromToken, toToken, msg.sender, amountIn, realOutput, output - realOutput);
    }

    /**
     * @dev This function executes the single swap with multiple pool paths which have the same input token and output token by spliting input amount
     *
     * A 50% [ UNI2 ] B
     *   30% [ CURVE]
     *   20% [ UNI3 ]
     *
     * @param fromToken for WETH, ETH, address(eee...), for ERC20, its own address
     * @param amountIn input amount of fromToken
     * @param toToken for WETH, ETH, address(eee...), for ERC20, its own address
     * @param weightPathInfo spliting input amount to multiple pools swap information
     */
    function getSingleHopMultiSwapOut(
        address fromToken,
        uint256 amountIn,
        address toToken,
        MultiAMMLib.WeightedSwap calldata weightPathInfo
    ) public returns (uint256 output) {
        require(
            weightPathInfo.fromToken == fromToken &&
                weightPathInfo.amountIn == amountIn &&
                weightPathInfo.toToken == toToken,
            "not same input"
        );
        output = _calcSingleHopMultiSwap(weightPathInfo);
    }

    /**
     * @dev This function executes sequential single hop swaps which consists of multiple pool paths which have the same input token and output token by spliting input amount
     *
     * A 50% [ UNI3 ] B 60% [ CURVE] C
     *   50% [ UNI2 ]   40% [ UNI3 ]
     *
     * @param fromToken for WETH, ETH, address(eee...), for ERC20, its own address
     * @param amountIn input amount of fromToken
     * @param toToken for WETH, ETH, address(eee...), for ERC20, its own address
     * @param weightPathInfos sequential spliting input amount to multiple pools swap information
     * @param minReturnAmount minimum return amount
     * @param deadLine blocktime limit
     */
    function multiHopMultiSwap(
        address fromToken,
        uint256 amountIn,
        address toToken,
        MultiAMMLib.WeightedSwap[] calldata weightPathInfos,
        uint256 minReturnAmount,
        uint256 deadLine,
        uint16[2] calldata isWETH
    ) public payable checkDeadline(deadLine) nonReentrant returns (uint256[] memory outputs) {
        // debug
        require(minReturnAmount > 0, "minReturn should be larger than 0");

        require(
            weightPathInfos[0].fromToken == fromToken &&
                weightPathInfos[0].amountIn == amountIn &&
                weightPathInfos[weightPathInfos.length - 1].toToken == toToken,
            "not same input"
        );
        _deposit(msg.sender, isWETH[0] == 1 ? _WETH_ADDRESS_ : fromToken, amountIn);

        // weth came to routeproxy at first so unwrap weth to eth
        if (isWETH[0] == 1) {
            require(fromToken == _ETH_ADDRESS_, "Not valid fromToken");
            IWETH(_WETH_ADDRESS_).withdraw(amountIn);
        }
        outputs = _multiHopMultiSwap(weightPathInfos);
        uint256 realOutput = outputs[outputs.length - 1].mul(_DEFAULT_WO_FEE_).div(_FEE_DENOMINATOR_);

        require(realOutput >= minReturnAmount, "out of slippage");
        if (isWETH[1] == 1) {
            require(toToken == _ETH_ADDRESS_, "Not valid toToken");
            IWETH(_WETH_ADDRESS_).deposit{ value: realOutput }();
            IERC20(_WETH_ADDRESS_).safeTransfer(weightPathInfos[weightPathInfos.length - 1].to, realOutput);
        } else {
            IERC20(toToken).uniTransfer(weightPathInfos[weightPathInfos.length - 1].to, realOutput);
        }

        emit OrderHistory(
            fromToken,
            toToken,
            msg.sender,
            amountIn,
            realOutput,
            outputs[outputs.length - 1] - realOutput
        );
    }

    /**
     * @dev This function executes sequential single hop swaps which consists of multiple pool paths which have the same input token and output token by spliting input amount
     *
     * A 50% [ UNI3 ] B 60% [ CURVE] C
     *   50% [ UNI2 ]   40% [ UNI3 ]
     *
     * @param fromToken for WETH, ETH, address(eee...), for ERC20, its own address
     * @param amountIn input amount of fromToken
     * @param toToken for WETH, ETH, address(eee...), for ERC20, its own address

     */
    function getMultiHopMultiSwapOut(
        address fromToken,
        uint256 amountIn,
        address toToken,
        MultiAMMLib.WeightedSwap[] calldata weightPathInfos
    ) public returns (uint256[] memory outputs) {
        require(
            weightPathInfos[0].fromToken == fromToken &&
                weightPathInfos[0].amountIn == amountIn &&
                weightPathInfos[weightPathInfos.length - 1].toToken == toToken,
            "not same input"
        );
        outputs = _calcMultiHopMultiSwap(weightPathInfos);
    }

    /**
     * @dev This function executes the multihop swap with multiple pool paths by spliting input amount it has no limit to compose any swaps
     *
     * A 60% [ UNI3 ] B 60% [ CURVE] C
     *                  30% [ UNI3 ]
     *                  10% [ UNI2 ]
     *   40% [         UNI2        ]
     *
     * @param fromToken for WETH, ETH, address(eee...), for ERC20, its own address
     * @param amountIn input amount of fromToken
     * @param toToken for WETH, ETH, address(eee...), for ERC20, its own address
     * @param linearWeightPathInfo linearly spliting input amount to multiple pools swap information with full composability
     * @param minReturnAmount minimum return amount
     * @param deadLine blocktime limit
     */
    function linearSplitMultiHopMultiSwap(
        address fromToken,
        uint256 amountIn,
        address toToken,
        MultiAMMLib.LinearWeightedSwap calldata linearWeightPathInfo,
        uint256 minReturnAmount,
        uint256 deadLine,
        uint16[2] calldata isWETH
    ) public payable checkDeadline(deadLine) nonReentrant returns (uint256 output) {
        require(minReturnAmount > 0, "minReturn should be larger than 0");

        require(
            linearWeightPathInfo.amountIn == amountIn &&
                linearWeightPathInfo.fromToken == fromToken &&
                linearWeightPathInfo.toToken == toToken,
            "not same input"
        );
        _deposit(msg.sender, isWETH[0] == 1 ? _WETH_ADDRESS_ : fromToken, amountIn);
        // weth came to routeproxy at first so unwrap weth to eth
        if (isWETH[0] == 1) {
            require(fromToken == _ETH_ADDRESS_, "Not valid fromToken");
            IWETH(_WETH_ADDRESS_).withdraw(amountIn);
        }
        output = _linearSplitMultiHopMultiSwap(linearWeightPathInfo);

        uint256 realOutput = output.mul(_DEFAULT_WO_FEE_).div(_FEE_DENOMINATOR_);
        require(realOutput >= minReturnAmount, "out of slippage");

        if (isWETH[1] == 1) {
            require(toToken == _ETH_ADDRESS_, "Not valid toToken");
            IWETH(_WETH_ADDRESS_).deposit{ value: realOutput }();
            IERC20(_WETH_ADDRESS_).safeTransfer(linearWeightPathInfo.to, realOutput);
        } else {
            IERC20(toToken).uniTransfer(linearWeightPathInfo.to, realOutput);
        }
        emit OrderHistory(fromToken, toToken, msg.sender, amountIn, realOutput, output - realOutput);
    }

    /**
     * @dev This function executes the multihop swap with multiple pool paths by spliting input amount it has no limit to compose any swaps
     *
     * A 60% [ UNI3 ] B 60% [ CURVE] C
     *                  30% [ UNI3 ]
     *                  10% [ UNI2 ]
     *   40% [         UNI2        ]
     *
     * @param fromToken for WETH, ETH, address(eee...), for ERC20, its own address
     * @param amountIn input amount of fromToken
     * @param toToken for WETH, ETH, address(eee...), for ERC20, its own address
     * @param linearWeightPathInfo linearly spliting input amount to multiple pools swap information with full composability
     */
    function getLinearSplitMultiHopMultiSwapOut(
        address fromToken,
        uint256 amountIn,
        address toToken,
        MultiAMMLib.LinearWeightedSwap calldata linearWeightPathInfo
    ) public returns (uint256 output) {
        require(
            linearWeightPathInfo.amountIn == amountIn &&
                linearWeightPathInfo.fromToken == fromToken &&
                linearWeightPathInfo.toToken == toToken,
            "not same input"
        );
        output = _calcLinearSplitMultiHopMultiSwap(linearWeightPathInfo);
    }

    /**
     * @dev This function executes linearSplitMultiHopMultiSwap and calculate the cyclic arbitrage paths to decide whether it executes arbitrage logic using flashloan. By doing so, traders can minimize slippage and protect themselves by MEV attack
     *
     * A 60% [ UNI3 ] B 60% [ CURVE] C
     *                  30% [ UNI3 ]
     *                  10% [ UNI2 ]
     *   40% [         UNI2        ]
     *
     * calculate cyclic arbitrage (arbitrage candidate paths are calculated from off-chain)
     * $ 100% [ 1? ] C [ 2? ] A [ 3? ] $
     * if these cycle profits are larger than each flashloan premium, (== new_balance($) >= old_balance($) * (1+premium))
     * executes flashloans and transfer the profits to trader
     *
     * @param fromToken for WETH, ETH, address(eee...), for ERC20, its own address
     * @param amountIn input amount of fromToken
     * @param toToken for WETH, ETH, address(eee...), for ERC20, its own address
     * @param linearWeightPathInfo linearly spliting input amount to multiple pools swap information with full composability
     * @param flashDes flashloan descriptions
     * @param minReturnAmount minimum return amount
     * @param deadLine blocktime limit
     */
    function shieldSwap(
        address fromToken,
        uint256 amountIn,
        address toToken,
        MultiAMMLib.LinearWeightedSwap memory linearWeightPathInfo,
        MultiAMMLib.FlashLoanDes[] memory flashDes,
        uint256 minReturnAmount,
        uint256 deadLine,
        uint16[2] calldata isWETH
    ) external payable checkDeadline(deadLine) nonReentrant returns (uint256 output) {
        require(minReturnAmount > 0, "minReturn should be larger than 0");
        require(
            linearWeightPathInfo.amountIn == amountIn &&
                linearWeightPathInfo.fromToken == fromToken &&
                linearWeightPathInfo.toToken == toToken,
            "not same input"
        );
        _deposit(msg.sender, isWETH[0] == 1 ? _WETH_ADDRESS_ : fromToken, amountIn);
        // weth came to routeproxy at first so unwrap weth to eth
        if (isWETH[0] == 1) {
            require(fromToken == _ETH_ADDRESS_, "Not valid fromToken");
            IWETH(_WETH_ADDRESS_).withdraw(amountIn);
        }
        output = _linearSplitMultiHopMultiSwap(linearWeightPathInfo);

        uint256 realOutput = output.mul(_DEFAULT_WO_FEE_).div(_FEE_DENOMINATOR_);
        require(realOutput >= minReturnAmount, "out of slippage");

        if (isWETH[1] == 1) {
            require(toToken == _ETH_ADDRESS_, "Not valid toToken");
            IWETH(_WETH_ADDRESS_).deposit{ value: realOutput }();
            IERC20(_WETH_ADDRESS_).safeTransfer(linearWeightPathInfo.to, realOutput);
        } else {
            IERC20(toToken).uniTransfer(linearWeightPathInfo.to, realOutput);
        }

        // we should execute multihopsingleswap array only to prevent errors from overusing the same pool before updating states
        for (uint256 i; i < flashDes.length; i++) {
            require(flashDes[i].swaps[0].amountIn == flashDes[i].amountIn, "flashloan amountIn not match");
            require(
                flashDes[i].swaps[0].fromToken == flashDes[i].asset &&
                    flashDes[i].asset == flashDes[i].swaps[flashDes[i].swaps.length - 1].toToken,
                "flashloan from to assets not match"
            );
            uint256[] memory outputs = _calcMultiHopSingleSwap(flashDes[i].swaps);
            if (
                outputs[outputs.length - 1] >
                flashDes[i].amountIn.mul(10000 + IFlashLoan(LENDING_POOL).flashLoanFeeBPS()).div(10000)
            ) {
                uint256 delta = IERC20(flashDes[i].asset).uniBalanceOf(address(this));
                IFlashLoan(LENDING_POOL).flashLoan(
                    address(this),
                    flashDes[i].asset,
                    flashDes[i].amountIn,
                    abi.encode(flashDes[i].swaps)
                );
                delta = IERC20(flashDes[i].asset).uniBalanceOf(address(this)) - delta;
                delta = delta.mul(_DEFAULT_WO_FEE_).div(_FEE_DENOMINATOR_);
                if (toToken == flashDes[i].asset) {
                    realOutput += delta;
                }

                IERC20(flashDes[i].asset).uniTransfer(msg.sender, delta);
            }
        }
        emit OrderHistory(fromToken, toToken, msg.sender, amountIn, realOutput, output - realOutput);
    }

    /**
     * @dev This function must be called only be the LENDING_POOL and takes care of repaying
     * active debt positions, migrating collateral and incurring new V2 debt token debt.
     *
     * @param pool The address that initiated the flash loan, unused.
     * @param token flash loaned asset used to repay debt.
     * @param amount flash loaned asset amounts used to repay debt.
     * @param fee the premium incurred as additional debt.
     * @param params The byte array containing, in this case, the arrays of aTokens and aTokenAmounts.
     */
    function executeOperation(
        address pool,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata params
    ) external override {
        //
        // This contract now has the funds requested.
        // Your logic goes here.
        //

        MultiAMMLib.Swap[] memory pathInfos = abi.decode(params, (MultiAMMLib.Swap[]));
        pathInfos[pathInfos.length - 1].to = address(this);
        _multiHopSingleSwap(pathInfos);

        // At the end of your logic above, this contract owes
        // the flashloaned amount + fee.
        // Therefore ensure your contract has enough to repay
        // these amounts.
        IERC20(token).safeTransfer(pool, amount + fee);
    }

    function _deposit(
        address from,
        address token,
        uint256 amount
    ) internal {
        if (token == _ETH_ADDRESS_) {
            require(msg.value == amount, "ETH_VALUE_WRONG");
        } else {
            IApproveProxy(_APPROVE_PROXY_).claimTokens(token, from, address(this), amount);
        }
    }

    function _executeSwap(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address adapter,
        address pool,
        uint16 poolEdition
    ) internal returns (uint256 output) {
        // only ETH comes as from not WETH
        // ETH -> WETH address (wrapping)
        address from = fromToken;
        address to = toToken;

        // poolEdition is 0 only for uniV2
        if (poolEdition == 0) {
            if (fromToken == _ETH_ADDRESS_) {
                IWETH(_WETH_ADDRESS_).deposit{ value: amountIn }();
                from = _WETH_ADDRESS_;
            }
            if (toToken == _ETH_ADDRESS_) {
                to = _WETH_ADDRESS_;
            }

            IERC20(from).safeTransfer(pool, amountIn);
        } else if (poolEdition == 1) {
            IERC20(fromToken).uniTransfer(adapter, amountIn);
        } else {
            revert("Invalid poolEdition");
        }

        output = IRouterAdapter(adapter).swapExactIn(from, amountIn, to, pool, address(this));

        // unwrap weth to eth
        if (toToken == _ETH_ADDRESS_ && poolEdition == 0) {
            IWETH(_WETH_ADDRESS_).withdraw(output);
        }
    }

    function _calcMultiHopSingleSwap(MultiAMMLib.Swap[] memory pathInfos) internal returns (uint256[] memory outputs) {
        uint256 pathInfoNum = pathInfos.length;
        outputs = new uint256[](pathInfoNum + 1);
        outputs[0] = pathInfos[0].amountIn;

        for (uint256 i = 1; i < pathInfoNum; i++) {
            // define midtoken address, ETH -> WETH address
            require(pathInfos[i - 1].toToken == pathInfos[i].fromToken, "Not valid multihopSingleSwap Path");

            outputs[i] = IRouterAdapter(pathInfos[i - 1].adapter).getAmountOut(
                pathInfos[i - 1].fromToken == _ETH_ADDRESS_ ? _WETH_ADDRESS_ : pathInfos[i - 1].fromToken,
                outputs[i - 1],
                pathInfos[i - 1].toToken == _ETH_ADDRESS_ ? _WETH_ADDRESS_ : pathInfos[i - 1].toToken,
                pathInfos[i - 1].pool
            );
        }
        outputs[pathInfoNum] = IRouterAdapter(pathInfos[pathInfoNum - 1].adapter).getAmountOut(
            pathInfos[pathInfoNum - 1].fromToken == _ETH_ADDRESS_
                ? _WETH_ADDRESS_
                : pathInfos[pathInfoNum - 1].fromToken,
            outputs[pathInfoNum - 1],
            pathInfos[pathInfoNum - 1].toToken == _ETH_ADDRESS_ ? _WETH_ADDRESS_ : pathInfos[pathInfoNum - 1].toToken,
            pathInfos[pathInfoNum - 1].pool
        );
    }

    function _calcSingleHopMultiSwap(MultiAMMLib.WeightedSwap memory weightPathInfo) internal returns (uint256 output) {
        require(
            weightPathInfo.weights.length == weightPathInfo.adapters.length &&
                weightPathInfo.weights.length == weightPathInfo.pools.length &&
                weightPathInfo.weights.length == weightPathInfo.poolEditions.length,
            "Invalid input length"
        );
        uint256 totalWeight;
        uint256 poolNum = weightPathInfo.weights.length;
        for (uint256 i; i < poolNum; i++) {
            totalWeight += weightPathInfo.weights[i];
        }

        uint256 rest = weightPathInfo.amountIn;
        for (uint256 i; i < poolNum; i++) {
            uint256 partAmountIn = i == poolNum - 1
                ? rest
                : weightPathInfo.amountIn.mul(weightPathInfo.weights[i]).div(totalWeight);
            rest = rest.sub(partAmountIn);

            output += IRouterAdapter(weightPathInfo.adapters[i]).getAmountOut(
                weightPathInfo.fromToken == _ETH_ADDRESS_ ? _WETH_ADDRESS_ : weightPathInfo.fromToken,
                partAmountIn,
                weightPathInfo.toToken == _ETH_ADDRESS_ ? _WETH_ADDRESS_ : weightPathInfo.toToken,
                weightPathInfo.pools[i]
            );
        }
    }

    function _calcMultiHopMultiSwap(MultiAMMLib.WeightedSwap[] memory weightPathInfos)
        internal
        returns (uint256[] memory outputs)
    {
        outputs = new uint256[](weightPathInfos.length + 1);
        outputs[0] = weightPathInfos[0].amountIn;
        for (uint256 i = 1; i < weightPathInfos.length; i++) {
            require(weightPathInfos[i - 1].toToken == weightPathInfos[i].fromToken, "Not valid multihop Path");

            outputs[i] = _calcSingleHopMultiSwap(weightPathInfos[i - 1]);
            weightPathInfos[i].amountIn = outputs[i];
        }
        outputs[outputs.length - 1] = _calcSingleHopMultiSwap(weightPathInfos[weightPathInfos.length - 1]);
    }

    function _calcLinearSplitMultiHopMultiSwap(MultiAMMLib.LinearWeightedSwap memory linearWeightPathInfo)
        internal
        returns (uint256 output)
    {
        require(
            linearWeightPathInfo.weights.length == linearWeightPathInfo.weightedSwaps.length,
            "Invalid input length"
        );
        uint256 totalWeight;
        uint256 splitNum = linearWeightPathInfo.weights.length;
        for (uint256 i; i < splitNum; i++) {
            totalWeight += linearWeightPathInfo.weights[i];
        }

        uint256 rest = linearWeightPathInfo.amountIn;
        for (uint256 i; i < splitNum; i++) {
            uint256 hopNum = linearWeightPathInfo.weightedSwaps[i].length;
            require(
                linearWeightPathInfo.weightedSwaps[i][hopNum - 1].toToken == linearWeightPathInfo.toToken,
                "Not valid linear toToken"
            );
            require(
                linearWeightPathInfo.weightedSwaps[i][0].fromToken == linearWeightPathInfo.fromToken,
                "Not valid linear fromToken"
            );
            uint256 partAmountIn = i == splitNum - 1
                ? rest
                : linearWeightPathInfo.amountIn.mul(linearWeightPathInfo.weights[i]).div(totalWeight);
            rest = rest.sub(partAmountIn);
            linearWeightPathInfo.weightedSwaps[i][0].amountIn = partAmountIn;
            uint256[] memory outputs = _calcMultiHopMultiSwap(linearWeightPathInfo.weightedSwaps[i]);
            output += outputs[outputs.length - 1];
        }
    }

    function _multiHopSingleSwap(MultiAMMLib.Swap[] memory pathInfos) internal returns (uint256[] memory outputs) {
        uint256 pathInfoNum = pathInfos.length;
        outputs = _calcMultiHopSingleSwap(pathInfos);

        for (uint256 i = 1; i < pathInfoNum; i++) {
            require(pathInfos[i - 1].toToken == pathInfos[i].fromToken, "Not valid multihop Path");

            _executeSwap(
                pathInfos[i - 1].fromToken,
                outputs[i - 1],
                pathInfos[i - 1].toToken,
                pathInfos[i - 1].adapter,
                pathInfos[i - 1].pool,
                pathInfos[i - 1].poolEdition
            );
        }

        _executeSwap(
            pathInfos[pathInfoNum - 1].fromToken,
            outputs[pathInfoNum - 1],
            pathInfos[pathInfoNum - 1].toToken,
            pathInfos[pathInfoNum - 1].adapter,
            pathInfos[pathInfoNum - 1].pool,
            pathInfos[pathInfoNum - 1].poolEdition
        );
    }

    function _singleHopMultiSwap(MultiAMMLib.WeightedSwap memory weightPathInfo) internal returns (uint256 output) {
        require(
            weightPathInfo.weights.length == weightPathInfo.adapters.length &&
                weightPathInfo.weights.length == weightPathInfo.pools.length &&
                weightPathInfo.weights.length == weightPathInfo.poolEditions.length,
            "Invalid input length"
        );

        uint256 totalWeight;
        uint256 poolNum = weightPathInfo.weights.length;
        for (uint256 i; i < poolNum; i++) {
            totalWeight += weightPathInfo.weights[i];
        }

        uint256 rest = weightPathInfo.amountIn;

        for (uint256 i; i < poolNum; i++) {
            uint256 partAmountIn = i == poolNum - 1
                ? rest
                : weightPathInfo.amountIn.mul(weightPathInfo.weights[i]).div(totalWeight);
            rest = rest.sub(partAmountIn);

            output += _executeSwap(
                weightPathInfo.fromToken,
                partAmountIn,
                weightPathInfo.toToken,
                weightPathInfo.adapters[i],
                weightPathInfo.pools[i],
                weightPathInfo.poolEditions[i]
            );
        }
    }

    function _multiHopMultiSwap(MultiAMMLib.WeightedSwap[] memory weightPathInfos)
        internal
        returns (uint256[] memory outputs)
    {
        outputs = new uint256[](weightPathInfos.length + 1);
        outputs[0] = weightPathInfos[0].amountIn;
        for (uint256 i = 1; i < weightPathInfos.length; i++) {
            require(weightPathInfos[i - 1].toToken == weightPathInfos[i].fromToken, "Not valid multihop Path");
            if (i != weightPathInfos.length - 1) {
                weightPathInfos[i].to = address(this);
            }
            outputs[i] = _singleHopMultiSwap(weightPathInfos[i - 1]);
            weightPathInfos[i].amountIn = outputs[i];
        }
        outputs[outputs.length - 1] = _singleHopMultiSwap(weightPathInfos[weightPathInfos.length - 1]);
    }

    function _linearSplitMultiHopMultiSwap(MultiAMMLib.LinearWeightedSwap memory linearWeightPathInfo)
        internal
        returns (uint256 output)
    {
        require(
            linearWeightPathInfo.weights.length == linearWeightPathInfo.weightedSwaps.length,
            "Invalid input length"
        );
        uint256 totalWeight;
        uint256 splitNum = linearWeightPathInfo.weights.length;
        for (uint256 i; i < splitNum; i++) {
            totalWeight += linearWeightPathInfo.weights[i];
        }

        uint256 rest = linearWeightPathInfo.amountIn;
        for (uint256 i; i < splitNum; i++) {
            uint256 hopNum = linearWeightPathInfo.weightedSwaps[i].length;
            require(
                linearWeightPathInfo.weightedSwaps[i][hopNum - 1].toToken == linearWeightPathInfo.toToken,
                "Not valid linear toToken"
            );
            require(
                linearWeightPathInfo.weightedSwaps[i][0].fromToken == linearWeightPathInfo.fromToken,
                "Not valid linear fromToken"
            );

            uint256 partAmountIn = i == splitNum - 1
                ? rest
                : linearWeightPathInfo.amountIn.mul(linearWeightPathInfo.weights[i]).div(totalWeight);
            rest = rest.sub(partAmountIn);
            linearWeightPathInfo.weightedSwaps[i][0].amountIn = partAmountIn;
            uint256[] memory outputs = _multiHopMultiSwap(linearWeightPathInfo.weightedSwaps[i]);
            output += outputs[outputs.length - 1];
        }
    }
}
