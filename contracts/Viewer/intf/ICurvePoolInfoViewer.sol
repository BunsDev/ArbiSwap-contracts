//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.15;

interface ICurvePoolInfoViewer {
    struct CurvePoolInfo {
        uint256 totalSupply;
        uint256[] tokenBalances;
        address pool;
        address[] tokenList;
        uint64[] fees;
        uint8 decimals;
        string name;
        string symbol;
    }

    function getPoolInfo(address pool) external view returns (CurvePoolInfo memory);
}
