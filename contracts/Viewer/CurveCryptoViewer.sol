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

        CurveCryptoPoolInfo memory curveCryptoPoolInfo;
        curveCryptoPoolInfo.totalSupply = token.totalSupply();
        curveCryptoPoolInfo.A = curvePool.A();
        curveCryptoPoolInfo.gamma = curvePool.gamma();
        curveCryptoPoolInfo.last_prices_timestamp = curvePool.last_prices_timestamp();
        curveCryptoPoolInfo.block_timestamp = block.timestamp;
        curveCryptoPoolInfo.ma_half_time = curvePool.ma_half_time();
        curveCryptoPoolInfo.xcp_profit = curvePool.xcp_profit();
        curveCryptoPoolInfo.xcp_profit_a = curvePool.xcp_profit_a();
        curveCryptoPoolInfo.fee_gamma = curvePool.fee_gamma();
        curveCryptoPoolInfo.fees = cryptoRegistry.get_fees(pool);
        curveCryptoPoolInfo.adjustment_step = curvePool.adjustment_step();
        curveCryptoPoolInfo.allowed_extra_profit = curvePool.allowed_extra_profit();
        curveCryptoPoolInfo.price_oracle = priceOracles;
        curveCryptoPoolInfo.price_scale = priceScales;
        curveCryptoPoolInfo.last_price = lastPrices;
        curveCryptoPoolInfo.virtual_price = curvePool.virtual_price();
        curveCryptoPoolInfo.tokenBalances = cryptoRegistry.get_balances(pool);
        curveCryptoPoolInfo.pool = address(token);
        curveCryptoPoolInfo.tokenList = tokenList;
        curveCryptoPoolInfo.decimals = token.decimals();
        curveCryptoPoolInfo.name = token.name();
        curveCryptoPoolInfo.symbol = token.symbol();

        return curveCryptoPoolInfo;
    }
}
