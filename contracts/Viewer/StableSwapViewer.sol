// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IERC20Metadata } from "../intf/IERC20Metadata.sol";
import { ISwap } from "../SmartRoute/intf/IStableSwap.sol";

import "./intf/IStableSwapPoolInfoViewer.sol";

/*
 * @dev: for test only
 */
import "hardhat/console.sol";

contract StableSwapViewer is IStableSwapPoolInfoViewer {
    function getPoolInfo(address pool) public view override returns (StableSwapPoolInfo memory) {
        ISwap swapPool = ISwap(pool);
        uint256[2] memory fees;
        address lp;

        (, , , , fees[0], fees[1], lp) = swapPool.swapStorage();
        IERC20Metadata token = IERC20Metadata(lp);
        uint256 tokenNum;
        uint256 isMeta;
        address[] memory tokenList;
        uint256[] memory tokenBalances;

        address[] memory tmp = new address[](8);

        // Check token addresses
        for (uint8 i = 0; i < 8; i++) {
            try swapPool.getToken(i) returns (address _token) {
                require(_token != address(0), "PR: token is 0");
                tmp[i] = _token;
                tokenNum += 1;
            } catch {
                assembly {
                    mstore(tmp, sub(mload(tmp), sub(8, i)))
                }
                break;
            }
        }

        for (uint8 i = 0; i < tokenNum; i++) {
            tokenList[i] = tmp[i];
            tokenBalances[i] = swapPool.getTokenBalance(i);
        }

        try swapPool.metaSwapStorage() {
            isMeta = 1;
        } catch {
            isMeta = 0;
        }

        return
            StableSwapPoolInfo({
                totalSupply: token.totalSupply(),
                A: swapPool.getA(),
                fees: fees,
                tokenBalances: tokenBalances, //
                pool: pool,
                lpToken: address(token),
                tokenList: tokenList, //
                isMeta: isMeta, //
                decimals: token.decimals(),
                name: token.name(),
                symbol: token.symbol()
            });
    }
}
