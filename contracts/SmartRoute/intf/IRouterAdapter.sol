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
    ) external returns (uint256 _output);

    function swapExactIn(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool,
        address to
    ) external payable returns (uint256 _output);
}

abstract contract IRouterAdapter is ReentrancyGuard, Routing, Ownable {}
