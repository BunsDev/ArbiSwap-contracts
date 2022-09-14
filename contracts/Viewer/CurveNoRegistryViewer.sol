// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IERC20Metadata } from "../intf/IERC20Metadata.sol";
import { ICurve } from "../SmartRoute/intf/ICurve.sol";

import "./intf/ICurveNoRegistryPoolInfoViewer.sol";

/*
 * @dev: for test only
 */
import "hardhat/console.sol";

contract CurveNoRegistryViewer is ICurveNoRegistryPoolInfoViewer {
    address public immutable basePool;

    constructor(address _basePool) {
        basePool = _basePool;
    }

    function getPoolInfo(address pool) public view override returns (CurveNoRegistryPoolInfo memory) {
        ICurve curvePool = ICurve(pool);
        IERC20Metadata token;
        uint256 tokenNum;

        uint256[2] memory fees;
        fees = [curvePool.fee(), curvePool.admin_fee()];

        uint256 isMeta;
        address[] memory tokenList;
        uint256[] memory tokenBalances;
        if (pool == basePool) {
            token = IERC20Metadata(curvePool.lp_token());
            // usdt/usdc/dai
            tokenNum = 3;
            isMeta = 0;
        } else {
            token = IERC20Metadata(curvePool.token());
            // usd/lp
            tokenNum = 2;
            isMeta = 1;
        }
        tokenList = new address[](tokenNum);
        tokenBalances = new uint256[](tokenNum);
        for (uint256 i; i < tokenNum; i++) {
            tokenList[i] = curvePool.coins(i);
            tokenBalances[i] = curvePool.balances(i);
        }

        return
            CurveNoRegistryPoolInfo({
                totalSupply: token.totalSupply(),
                A: curvePool.A(),
                fees: fees,
                tokenBalances: tokenBalances,
                pool: pool,
                lpToken: address(token),
                tokenList: tokenList,
                isMeta: isMeta,
                decimals: token.decimals(),
                name: token.name(),
                symbol: token.symbol()
            });
    }
}
