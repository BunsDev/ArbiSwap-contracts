//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.15;

interface IBalancerPoolInfoViewer {
    struct BalancerPoolInfo {
        uint256 totalSupply;
        uint256[] tokenBalances;
        uint256[] normWeights;
        address pool;
        address[] tokenList;
        uint32[] fees;
        uint8 decimals;
        string name;
        string symbol;
    }

    function getPoolInfo(address pool) external view returns (BalancerPoolInfo memory);
}
