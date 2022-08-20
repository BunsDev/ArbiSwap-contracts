// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;
import { ReentrancyGuard } from "../../lib/ReentrancyGuard.sol";
import { Ownable } from "../../lib/Ownable.sol";

interface Routing {
    function getAmountOut(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool
    ) external view returns (uint256 _output);

    function swapExactIn(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool,
        address to
    ) external returns (uint256 _output);

    function factory(address pool) external view returns (address);

    function getWETH(address pool) external view returns (address);
}

abstract contract IRouterAdapter is ReentrancyGuard, Routing, Ownable {
    event setWETH(address WETH);
    event unsetWETH(address WETH);
    event matchWETH(address factory, address WETH);
    mapping(address => uint8) public isETH;
    mapping(address => address) public factoryToWETH;

    function checkWETH(address token) public view returns (bool) {
        return isETH[token] == 1;
    }

    function changeWETH(address[] memory factories, address[] memory WETHs) public onlyOwner {
        _changeWETH(factories, WETHs);
    }

    function _setWETH(address WETH) internal {
        if (isETH[WETH] == 0) {
            isETH[WETH] = 1;
            emit setWETH(WETH);
        }
    }

    function _unsetWETH(address WETH) internal {
        if (isETH[WETH] == 1) {
            isETH[WETH] = 0;
            emit unsetWETH(WETH);
        }
    }

    function _changeWETH(address[] memory factories, address[] memory WETHs) internal {
        for (uint256 i; i < WETHs.length; i++) {
            if (WETHs[i] == address(0)) {
                _unsetWETH(WETHs[i]);
            } else {
                _setWETH(WETHs[i]);
            }
            factoryToWETH[factories[i]] = WETHs[i];
            emit matchWETH(factories[i], WETHs[i]);
        }
    }
}
