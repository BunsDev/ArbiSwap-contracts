// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.15;
import "hardhat/console.sol";
import { IRouterAdapter } from "../intf/IRouterAdapter.sol";
import { ICurve } from "../intf/ICurve.sol";
import { IERC20 } from "../../intf/IERC20.sol";
import { SafeMath } from "../../lib/SafeMath.sol";
import { UniERC20 } from "../../lib/UniERC20.sol";
import { SafeERC20 } from "../../lib/SafeERC20.sol";
import { SafeCast } from "../../lib/SafeCast.sol";
import { EnumerableSet } from "../../lib/EnumerableSet.sol";
import { EnumerableMap } from "../../lib/EnumerableMap.sol";
import "hardhat/console.sol";

// In curve factory = registry
contract CurveNoRegistryAdapter is IRouterAdapter {
    using SafeMath for uint256;
    using SafeCast for uint256;
    using SafeCast for int256;
    using UniERC20 for IERC20;
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableMap for EnumerableMap.AddressToUintMap;

    address public constant _ETH_ADDRESS_ = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    EnumerableSet.AddressSet private basePools;
    EnumerableMap.AddressToUintMap private basePoolsTokenNum;

    constructor(address[] memory _basePools, uint256[] memory _tokenNums) {
        require(_basePools.length == _tokenNums.length, "diff length");
        for (uint256 i; i < _basePools.length; i++) {
            basePools.add(_basePools[i]);
            basePoolsTokenNum.set(_basePools[i], _tokenNums[i]);
        }
    }

    function getCoinIndices(
        address pool,
        address fromToken,
        address toToken
    ) internal view returns (int128 i, int128 j) {
        i = -1;
        j = -1;

        for (uint256 k; k < basePoolsTokenNum.get(pool); k++) {
            address tmp = ICurve(pool).coins(k);
            if (fromToken == tmp) {
                i = k.toInt256().toInt128();
            } else if (toToken == tmp) {
                j = k.toInt256().toInt128();
            }
        }
    }

    function getAmountOut(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool
    ) public view override returns (uint256 _output) {
        (int128 i, int128 j) = getCoinIndices(pool, fromToken, toToken);
        _output = ICurve(pool).get_dy(i, j, amountIn);
    }

    function swapExactIn(
        address fromToken,
        uint256 amountIn,
        address toToken,
        address pool,
        address to
    ) external payable override returns (uint256 _output) {
        IERC20(fromToken).universalApproveMax(pool, amountIn);

        (int128 i, int128 j) = getCoinIndices(pool, fromToken, toToken);
        ICurve(pool).exchange(i, j, amountIn, 1);
        _output = IERC20(toToken).uniBalanceOf(address(this));

        IERC20(toToken).uniTransfer(to, _output);
    }
}
