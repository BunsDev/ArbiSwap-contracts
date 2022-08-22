// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

interface ICurveProvider {
    function get_registry() external view returns (address);

    function get_address(uint256 _id) external view returns (address);
}

interface ICurveRegistry {
    function pool_list(uint256 idx) external view returns (address);

    function pool_count() external view returns (uint256);

    function get_coins(address _pool) external view returns (address[] memory);

    function get_underlying_coins(address _pool) external view returns (address[] memory);

    function get_decimals(address _pool) external view returns (uint256[] memory);

    function get_underlying_decimals(address _pool) external view returns (uint256[] memory);

    function get_balances(address _pool) external view returns (uint256[] memory);

    function get_rates(address _pool) external view returns (uint256[] memory);

    // Pool fee as uint256 with 1e10 precision
    // Admin fee as 1e10 percentage of pool fee
    // Mid fee (if cryptopool)
    // Out fee (if cryptopool)
    function get_fees(address _pool) external view returns (uint256[] memory);

    function get_lp_token(address _pool) external view returns (address);

    function is_meta(address _pool) external view returns (bool);

    function get_pool_name(address _pool) external view returns (string memory);

    function find_pool_for_coins(
        address _srcToken,
        address _dstToken,
        uint256 _index
    ) external view returns (address);

    function get_coin_indices(
        address _pool,
        address _srcToken,
        address _dstToken
    )
        external
        view
        returns (
            int128,
            int128,
            bool
        );
}

interface ICurveCryptoRegistry {
    function get_coin_indices(
        address _pool,
        address _srcToken,
        address _dstToken
    ) external view returns (uint256, uint256);
}

interface ICurve {
    function token() external view returns (address);

    function gamma() external view returns (uint256);

    function xcp_profit() external view returns (uint256);

    function xcp_profit_a() external view returns (uint256);

    function fee_gamma() external view returns (uint256);

    function mid_fee() external view returns (uint256);

    function out_fee() external view returns (uint256);

    function admin_fee() external view returns (uint256);

    function fee() external view returns (uint256);

    function adjustment_step() external view returns (uint256);

    function allowed_extra_profit() external view returns (uint256);

    function price_oracle(uint256 k) external view returns (uint256);

    function price_oracle() external view returns (uint256);

    function price_scale(uint256 k) external view returns (uint256);

    function price_scale() external view returns (uint256);

    function last_prices() external view returns (uint256);

    function last_prices(uint256 k) external view returns (uint256);

    function virtual_price() external view returns (uint256);

    function A() external view returns (uint256);

    function last_prices_timestamp() external view returns (uint256);

    function future_A_gamma_time() external view returns (uint256);

    function ma_half_time() external view returns (uint256);

    // solium-disable-next-line mixedcase
    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256 dy);

    // solium-disable-next-line mixedcase
    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256 dy);

    // solium-disable-next-line mixedcase
    function exchange_underlying(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 minDy
    ) external;

    // solium-disable-next-line mixedcase
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 minDy
    ) external;

    // view coins address
    function underlying_coins(uint256 arg0) external view returns (address out);

    function coins(uint256 arg0) external view returns (address out);

    function factory() external view returns (address);
}
