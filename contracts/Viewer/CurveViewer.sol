// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IERC20Metadata } from "../intf/IERC20Metadata.sol";
import { ICurve, ICurveRegistry } from "../SmartRoute/intf/ICurve.sol";

import "./intf/ICurvePoolInfoViewer.sol";

/*
 * @dev: for test only
 */
import "hardhat/console.sol";

contract CurveViewer is ICurvePoolInfoViewer {
    address public immutable registry;

    constructor(address _registry) {
        registry = _registry;
    }

    function getPoolInfo(address pool) public view override returns (CurvePoolInfo memory) {
        ICurve curvePool = ICurve(pool);
        ICurveRegistry curveRegistry = ICurveRegistry(registry);
        IERC20Metadata token = IERC20Metadata(curvePool.lp_token());

        return
            CurvePoolInfo({
                totalSupply: token.totalSupply(),
                A: curvePool.A(),
                fees: curveRegistry.get_fees(pool),
                tokenBalances: curveRegistry.get_balances(pool),
                pool: address(token),
                tokenList: curveRegistry.get_coins(pool),
                isMeta: curveRegistry.is_meta(pool) ? 1 : 0,
                decimals: token.decimals(),
                name: token.name(),
                symbol: token.symbol()
            });
    }

    function pools(address _registry) external view returns (address[] memory) {
        address[] memory _pools = new address[](ICurveRegistry(_registry).pool_count());
        for (uint256 i; i < _pools.length; i++) {
            _pools[i] = ICurveRegistry(_registry).pool_list(i);
        }
        return _pools;
    }
}
