// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { IERC20Metadata } from "../intf/IERC20Metadata.sol";
import { ICurve, ICurveRegistry, ICurveFactoryRegistry } from "../SmartRoute/intf/ICurve.sol";

import "./intf/ICurvePoolInfoViewer.sol";

/*
 * @dev: for test only
 */
import "hardhat/console.sol";

contract CurveViewer is ICurvePoolInfoViewer {
    address public immutable registry;
    address public immutable factoryRegistry;

    constructor(address _registry, address _factoryRegistry) {
        registry = _registry;
        factoryRegistry = _factoryRegistry;
    }

    function getPoolInfo(address pool) public view override returns (CurvePoolInfo memory) {
        address _registry = registry;
        if (ICurveRegistry(_registry).get_lp_token(pool) == address(0)) {
            _registry = factoryRegistry;
        }

        ICurve curvePool = ICurve(pool);
        IERC20Metadata token;
        uint256 tokenNum;

        uint256[2] memory fees;
        uint256 isMeta;
        address[] memory tokenList;
        uint256[] memory tokenBalances;
        if (_registry == registry) {
            ICurveRegistry curveRegistry = ICurveRegistry(_registry);
            tokenNum = curveRegistry.get_n_coins(pool)[0];
            token = IERC20Metadata(curveRegistry.get_lp_token(pool));
            address[8] memory tmp = curveRegistry.get_coins(pool);
            uint256[8] memory _tmp = curveRegistry.get_balances(pool);
            fees = curveRegistry.get_fees(pool);
            isMeta = curveRegistry.is_meta(pool) ? 1 : 0;
            tokenList = new address[](tokenNum);
            tokenBalances = new uint256[](tokenNum);
            for (uint256 i; i < tokenNum; i++) {
                tokenList[i] = tmp[i];
                tokenBalances[i] = _tmp[i];
            }
        } else {
            ICurveFactoryRegistry curveRegistry = ICurveFactoryRegistry(_registry);
            tokenNum = curveRegistry.get_n_coins(pool);
            token = IERC20Metadata(curvePool.lp_token());
            address[4] memory tmp = curveRegistry.get_coins(pool);
            uint256[4] memory _tmp = curveRegistry.get_balances(pool);
            (uint256 fee0, uint256 fee1) = curveRegistry.get_fees(pool);
            fees = [fee0, fee1];
            isMeta = curveRegistry.is_meta(pool) ? 1 : 0;
            tokenList = new address[](tokenNum);
            tokenBalances = new uint256[](tokenNum);
            for (uint256 i; i < tokenNum; i++) {
                tokenList[i] = tmp[i];
                tokenBalances[i] = _tmp[i];
            }
        }

        return
            CurvePoolInfo({
                totalSupply: token.totalSupply(),
                A: curvePool.A(),
                fees: fees,
                tokenBalances: tokenBalances,
                pool: address(token),
                tokenList: tokenList,
                isMeta: isMeta,
                decimals: token.decimals(),
                name: token.name(),
                symbol: token.symbol()
            });
    }

    function pools() external view returns (address[] memory) {
        uint256 regiNum = ICurveRegistry(registry).pool_count();
        uint256 factNum = ICurveFactoryRegistry(factoryRegistry).pool_count();
        address[] memory _pools = new address[](regiNum + factNum);

        for (uint256 i; i < regiNum; i++) {
            _pools[i] = ICurveRegistry(registry).pool_list(i);
        }
        for (uint256 i; i < factNum; i++) {
            _pools[i + regiNum] = ICurveFactoryRegistry(factoryRegistry).pool_list(i);
        }
        return _pools;
    }
}
