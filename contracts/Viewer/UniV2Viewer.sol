// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IERC20Metadata } from "../intf/IERC20Metadata.sol";
import { IUniswapV2Pair, IUniswapV2Factory } from "../SmartRoute/intf/IUniV2.sol";

import "./intf/IUniswapV2PoolInfoViewer.sol";

/*
 * @dev: for test only
 */
import "hardhat/console.sol";
import { EnumerableMap } from "../lib/EnumerableMap.sol";

contract UniV2Viewer is IUniswapV2PoolInfoViewer {
    using EnumerableMap for EnumerableMap.AddressToUintMap;
    EnumerableMap.AddressToUintMap private dexTofees;

    constructor(address[] memory factories, uint256[] memory fees) {
        require(factories.length == fees.length, "diff length");
        for (uint256 i; i < factories.length; i++) {
            dexTofees.set(factories[i], fees[i]);
        }
    }

    function fee(address pool) external view returns (uint32) {
        return uint32(dexTofees.get(IUniswapV2Pair(pool).factory()));
    }

    function getPoolInfo(address pool) public view override returns (UniswapV2PoolInfo memory) {
        IUniswapV2Pair uniswapV2Pair = IUniswapV2Pair(pool);
        address[] memory tokenList = new address[](2);
        tokenList[0] = uniswapV2Pair.token0();
        tokenList[1] = uniswapV2Pair.token1();
        uint256[] memory tokenBalances = new uint256[](2);
        (tokenBalances[0], tokenBalances[1], ) = uniswapV2Pair.getReserves();
        uint32[] memory fees = new uint32[](1);

        fees[0] = this.fee(pool);
        return
            UniswapV2PoolInfo({
                totalSupply: uniswapV2Pair.totalSupply(),
                tokenBalances: tokenBalances,
                pool: pool,
                tokenList: tokenList,
                fees: fees,
                decimals: uniswapV2Pair.decimals(),
                name: uniswapV2Pair.name(),
                symbol: uniswapV2Pair.symbol()
            });
    }

    function getPairInfo(address _factory, uint256 idx) public view returns (UniswapV2PoolInfo memory) {
        return getPoolInfo(IUniswapV2Factory(_factory).allPairs(idx));
    }

    function allPairsLength(address _factory) external view returns (uint256) {
        return IUniswapV2Factory(_factory).allPairsLength();
    }

    function pools(address _facotry) external view returns (address[] memory) {
        address[] memory _pools = new address[](IUniswapV2Factory(_facotry).allPairsLength());
        for (uint256 i; i < _pools.length; i++) {
            _pools[i] = IUniswapV2Factory(_facotry).allPairs(i);
        }
        return _pools;
    }
}
