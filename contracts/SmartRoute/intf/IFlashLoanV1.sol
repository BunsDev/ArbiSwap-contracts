// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

interface IFlashLoanReceiver {
    function executeOperation(
        address pool,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata params
    ) external;
}

interface IFlashLoan {
    function flashLoanFeeBPS() external returns (uint256);

    function flashLoan(
        address receiver,
        address token,
        uint256 amount,
        bytes memory params
    ) external;
}
