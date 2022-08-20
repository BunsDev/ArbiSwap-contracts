// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

library MultiAMMLib {
    enum DexType {
        UNI2,
        CURVE,
        BALANCER,
        UNI3
        // DODO,
        // KYBERDMM
        // STABLESWAP,
        // SADDLE
    }
    //dexType:
    // 0: uniswapV2
    // 1: curve
    // 2: balancer
    // 3: uniswapV3
    // 4: dodo - proactive
    // 5: Kyber dmm
    // 6: stable swap
    // 7: saddle
    struct Swap {
        address fromToken;
        uint256 amountIn;
        address toToken;
        address to;
        address pool;
        address adapter;
        uint16 poolEdition;
    }

    struct WeightedSwap {
        address fromToken;
        uint256 amountIn;
        address toToken;
        address to;
        address[] pools;
        uint256[] weights;
        address[] adapters;
        uint16[] poolEditions;
    }

    struct LinearWeightedSwap {
        address fromToken;
        uint256 amountIn;
        address toToken;
        address to;
        uint256[] weights;
        WeightedSwap[][] weightedSwaps;
    }

    struct FlashLoanDes {
        address asset;
        uint256 amountIn;
        Swap[] swaps;
    }
}
