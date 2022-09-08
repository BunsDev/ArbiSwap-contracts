// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "hardhat/console.sol";
import { IUniV3Pair, IUniswapV3SwapCallback, ITickLens } from "../SmartRoute/intf/IUniV3.sol";
import "./intf/IUniswapV3PoolInfoViewer.sol";

/*
 * @dev: for test only
 */
import "hardhat/console.sol";

// optimizer run : 1000000
contract UniV3Viewer is IUniswapV3PoolInfoViewer {
    address public immutable tickLens;

    constructor(address _tickLens) {
        tickLens = _tickLens;
    }

    function getPoolInfo(address pool) public view override returns (UniswapV3PoolInfo memory) {
        IUniV3Pair uniswapV3Pool = IUniV3Pair(pool);
        address[] memory tokenList = new address[](2);
        tokenList[0] = uniswapV3Pool.token0();
        tokenList[1] = uniswapV3Pool.token1();
        (uint160 sqrtPriceX96, int24 tick, , , , uint8 feeProtocol, bool unlocked) = uniswapV3Pool.slot0();
        int24 tickSpacing = uniswapV3Pool.tickSpacing();
        int16 wordPos = int16((tick / uniswapV3Pool.tickSpacing()) >> 8);

        return
            UniswapV3PoolInfo({
                pool: pool,
                tokenList: tokenList,
                block_timestamp: uint32(block.timestamp),
                sqrtPriceX96: sqrtPriceX96,
                liquidity: uniswapV3Pool.liquidity(),
                fee: uniswapV3Pool.fee(),
                tick: tick,
                tickSpacing: tickSpacing,
                cheapPopulatedTicks: ITickLens(tickLens).getPopulatedTicksInWord(pool, wordPos - 1),
                currentPopulatedTicks: ITickLens(tickLens).getPopulatedTicksInWord(pool, wordPos),
                expensivePopulatedTicks: ITickLens(tickLens).getPopulatedTicksInWord(pool, wordPos + 1),
                feeProtocol: feeProtocol,
                unlocked: unlocked
            });
    }
}
