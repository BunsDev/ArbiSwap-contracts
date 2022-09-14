//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.15;

interface ICurveCryptoPoolInfoViewer {
    struct CurveCryptoPoolInfo {
        uint256 totalSupply;
        uint256 A;
        uint256 gamma;
        uint256 last_prices_timestamp;
        uint256 block_timestamp;
        uint256 ma_half_time;
        uint256 xcp_profit;
        uint256 xcp_profit_a;
        uint256 fee_gamma;
        uint256[4] fees;
        uint256 adjustment_step;
        uint256 allowed_extra_profit;
        uint256[] price_oracle;
        uint256[] price_scale;
        uint256[] last_price;
        uint256 virtual_price;
        uint256[] tokenBalances;
        address pool;
        address lpToken;
        address[] tokenList;
        uint8 decimals;
        string name;
        string symbol;
    }

    function getPoolInfo(address pool) external view returns (CurveCryptoPoolInfo memory);

    function pools() external view returns (address[] memory);
}
