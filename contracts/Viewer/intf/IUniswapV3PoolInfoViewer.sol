//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.15;
import { ITickLens } from "../../SmartRoute/intf/IUniV3.sol";

interface IUniswapV3PoolInfoViewer {
    struct UniswapV3PoolInfo {
        address pool;
        address[] tokenList;
        uint32 block_timestamp;
        uint160 sqrtPriceX96;
        uint128 liquidity;
        uint24 fee;
        int24 tick;
        int24 tickSpacing;
        ITickLens.PopulatedTick[] cheapPopulatedTicks;
        ITickLens.PopulatedTick[] currentPopulatedTicks;
        ITickLens.PopulatedTick[] expensivePopulatedTicks;
        uint8 feeProtocol;
        bool unlocked;
    }

    function getPoolInfo(address pool) external view returns (UniswapV3PoolInfo memory);
}
