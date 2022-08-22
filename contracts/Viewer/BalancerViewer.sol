// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IERC20Metadata } from "../intf/IERC20Metadata.sol";
import { IBalancerPool, IBalancerVault } from "../SmartRoute/intf/IBalancer.sol";
import { SafeMath } from "../lib/SafeMath.sol";
import "./intf/IBalancerPoolInfoViewer.sol";

/*
 * @dev: for test only
 */
import "hardhat/console.sol";

contract BalancerViewer is IBalancerPoolInfoViewer {
    using SafeMath for uint256;

    function getPoolInfo(address pool) public view override returns (BalancerPoolInfo memory) {
        IBalancerPool balancerPair = IBalancerPool(pool);
        bytes32 poolId = balancerPair.getPoolId();
        (address[] memory tokenList, uint256[] memory tokenBalances, ) = IBalancerVault(balancerPair.getVault())
            .getPoolTokens(poolId);
        uint32[] memory fees = new uint32[](1);
        fees[0] = uint32(balancerPair.getSwapFeePercentage().div(1e12));
        return
            BalancerPoolInfo({
                totalSupply: balancerPair.totalSupply(),
                tokenBalances: tokenBalances,
                normWeights: IBalancerPool(pool).getNormalizedWeights(),
                pool: pool,
                tokenList: tokenList,
                fees: fees,
                decimals: balancerPair.decimals(),
                name: balancerPair.name(),
                symbol: balancerPair.symbol()
            });
    }
}
