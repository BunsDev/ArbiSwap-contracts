// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IERC20Metadata } from "../intf/IERC20Metadata.sol";
import { ICurveCrypto, ICurveCryptoRegistry } from "../SmartRoute/intf/ICurve.sol";

import "./intf/ICurveCryptoPoolInfoViewer.sol";

/*
 * @dev: for test only
 */
import "hardhat/console.sol";

contract CurveCryptoViewer is ICurveCryptoPoolInfoViewer {
    address public immutable registry;

    constructor(address _registry) {
        registry = _registry;
    }

    function getPoolInfo(address pool) public view override returns (CurveCryptoPoolInfo memory) {
        ICurveCrypto curvePool = ICurveCrypto(pool);
        ICurveCryptoRegistry cryptoRegistry = ICurveCryptoRegistry(registry);
        IERC20Metadata token = IERC20Metadata(curvePool.token());

        uint256 tokenNum = cryptoRegistry.get_n_coins(pool);
        address[] memory tokenList = new address[](tokenNum);
        uint256[] memory tokenBalances = new uint256[](tokenNum);
        address[8] memory tmp = cryptoRegistry.get_coins(pool);
        uint256[8] memory _tmp = cryptoRegistry.get_balances(pool);
        require(tokenNum >= 2, "invalid tokenNum");
        uint256[] memory priceOracles = new uint256[](tokenNum - 1);
        uint256[] memory priceScales = new uint256[](tokenNum - 1);
        uint256[] memory lastPrices = new uint256[](tokenNum - 1);

        if (tokenNum == 2) {
            priceOracles[0] = curvePool.price_oracle();
            priceScales[0] = curvePool.price_scale();
            lastPrices[0] = curvePool.last_prices();
            for (uint256 i; i < tokenNum; i++) {
                tokenList[i] = tmp[i];
                tokenBalances[i] = _tmp[i];
            }
        } else {
            for (uint256 i; i < tokenNum - 1; i++) {
                priceOracles[i] = curvePool.price_oracle(i);
                priceScales[i] = curvePool.price_scale(i);
                lastPrices[i] = curvePool.last_prices(i);
                tokenList[i] = tmp[i];
                tokenBalances[i] = _tmp[i];
            }
            tokenList[tokenNum - 1] = tmp[tokenNum - 1];
            tokenBalances[tokenNum - 1] = _tmp[tokenNum - 1];
        }

        return
            CurveCryptoPoolInfo({
                totalSupply: token.totalSupply(),
                A: curvePool.A(),
                gamma: curvePool.gamma(),
                last_prices_timestamp: curvePool.last_prices_timestamp(),
                block_timestamp: block.timestamp,
                ma_half_time: curvePool.ma_half_time(),
                xcp_profit: curvePool.xcp_profit(),
                xcp_profit_a: curvePool.xcp_profit_a(),
                fee_gamma: curvePool.fee_gamma(),
                fees: cryptoRegistry.get_fees(pool),
                adjustment_step: curvePool.adjustment_step(),
                allowed_extra_profit: curvePool.allowed_extra_profit(),
                price_oracle: priceOracles,
                price_scale: priceScales,
                last_price: lastPrices,
                virtual_price: curvePool.virtual_price(),
                tokenBalances: tokenBalances,
                pool: address(token),
                tokenList: tokenList,
                decimals: token.decimals(),
                name: token.name(),
                symbol: token.symbol()
            });
    }

    function pools() external view override returns (address[] memory) {
        address[] memory _pools = new address[](ICurveCryptoRegistry(registry).pool_count());
        for (uint256 i; i < _pools.length; i++) {
            _pools[i] = ICurveCryptoRegistry(registry).pool_list(i);
        }
        return _pools;
    }
}
