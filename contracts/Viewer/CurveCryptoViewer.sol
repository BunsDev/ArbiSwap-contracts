// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IERC20Metadata } from "../intf/IERC20Metadata.sol";
import { ICurve, ICurveRegistry } from "../SmartRoute/intf/ICurve.sol";

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
        ICurve curvePool = ICurve(pool);
        ICurveRegistry cryptoRegistry = ICurveRegistry(registry);
        IERC20Metadata token = IERC20Metadata(curvePool.token());

        address[] memory tokenList = cryptoRegistry.get_coins(pool);
        uint256 tokenNum = tokenList.length;
        require(tokenNum >= 2, "invalid tokenNum");
        uint256[] memory priceOracles = new uint256[](tokenNum - 1);
        uint256[] memory priceScales = new uint256[](tokenNum - 1);
        uint256[] memory lastPrices = new uint256[](tokenNum - 1);

        if (tokenNum == 2) {
            priceOracles[0] = curvePool.price_oracle();
            priceScales[0] = curvePool.price_scale();
            lastPrices[0] = curvePool.last_prices();
        } else {
            for (uint256 i; i < tokenNum - 1; i++) {
                priceOracles[i] = curvePool.price_oracle(i);
                priceScales[i] = curvePool.price_scale(i);
                lastPrices[i] = curvePool.last_prices(i);
            }
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
                tokenBalances: cryptoRegistry.get_balances(pool),
                pool: address(token),
                tokenList: tokenList,
                decimals: token.decimals(),
                name: token.name(),
                symbol: token.symbol()
            });
    }
}
