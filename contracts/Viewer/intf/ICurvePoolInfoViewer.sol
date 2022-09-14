//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.15;

interface ICurvePoolInfoViewer {
    struct CurvePoolInfo {
        uint256 totalSupply;
        uint256 A;
        uint256[2] fees;
        uint256[] tokenBalances;
        address pool;
        address lpToken;
        address[] tokenList;
        uint256 isMeta;
        uint8 decimals;
        string name;
        string symbol;
    }

    function getPoolInfo(address pool) external view returns (CurvePoolInfo memory);

    function pools() external view returns (address[] memory);
}
