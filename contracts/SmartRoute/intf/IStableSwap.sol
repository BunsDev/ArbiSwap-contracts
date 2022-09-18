// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

interface ISwap {
    // pool data view functions
    function getA() external view returns (uint256);

    function getTokenIndex(address tokenAddress) external view returns (uint8);

    function getToken(uint8 index) external view returns (address);

    function getTokenBalance(uint8 index) external view returns (uint256);

    function getVirtualPrice() external view returns (uint256);

    //   initialA   uint256
    //   futureA   uint256
    //   initialATime   uint256
    //   futureATime   uint256
    //   swapFee   uint256
    //   adminFee   uint256
    //   lpToken  address
    function swapStorage()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        );

    // baseSwap   address
    // baseVirtualPrice   uint256
    // baseCacheLastUpdated   uint256

    function metaSwapStorage()
        external
        view
        returns (
            address,
            uint256,
            uint256
        );

    // min return calculation functions
    function calculateSwap(
        uint8 tokenIndexFrom,
        uint8 tokenIndexTo,
        uint256 dx
    ) external view returns (uint256);

    // min return calculation functions
    function calculateSwapUnderlying(
        uint8 tokenIndexFrom,
        uint8 tokenIndexTo,
        uint256 dx
    ) external view returns (uint256);

    function calculateTokenAmount(uint256[] calldata amounts, bool deposit) external view returns (uint256);

    function calculateRemoveLiquidity(uint256 amount) external view returns (uint256[] memory);

    function calculateRemoveLiquidityOneToken(uint256 tokenAmount, uint8 tokenIndex)
        external
        view
        returns (uint256 availableTokenAmount);

    function swap(
        uint8 tokenIndexFrom,
        uint8 tokenIndexTo,
        uint256 dx,
        uint256 minDy,
        uint256 deadline
    ) external returns (uint256);

    function swapUnderlying(
        uint8 tokenIndexFrom,
        uint8 tokenIndexTo,
        uint256 dx,
        uint256 minDy,
        uint256 deadline
    ) external returns (uint256);

    function addLiquidity(
        uint256[] calldata amounts,
        uint256 minToMint,
        uint256 deadline
    ) external returns (uint256);

    function removeLiquidity(
        uint256 amount,
        uint256[] calldata minAmounts,
        uint256 deadline
    ) external returns (uint256[] memory);

    function removeLiquidityOneToken(
        uint256 tokenAmount,
        uint8 tokenIndex,
        uint256 minAmount,
        uint256 deadline
    ) external returns (uint256);

    function removeLiquidityImbalance(
        uint256[] calldata amounts,
        uint256 maxBurnAmount,
        uint256 deadline
    ) external returns (uint256);

    function withdrawAdminFees() external;
}

interface IPoolRegistry {
    /* Structs */

    struct PoolInputData {
        address poolAddress;
        uint8 typeOfAsset;
        bytes32 poolName;
        address targetAddress;
        address metaSwapDepositAddress;
        bool isSaddleApproved;
        bool isRemoved;
        bool isGuarded;
    }

    struct PoolData {
        address poolAddress;
        address lpToken;
        uint8 typeOfAsset;
        bytes32 poolName;
        address targetAddress;
        address[] tokens;
        address[] underlyingTokens;
        address basePoolAddress;
        address metaSwapDepositAddress;
        bool isSaddleApproved;
        bool isRemoved;
        bool isGuarded;
    }

    struct SwapStorageData {
        uint256 initialA;
        uint256 futureA;
        uint256 initialATime;
        uint256 futureATime;
        uint256 swapFee;
        uint256 adminFee;
        address lpToken;
    }

    /* Public Variables */

    /**
     * @notice Returns the index + 1 of the pool address in the registry
     * @param poolAddress address to look for
     */
    function poolsIndexOfPlusOne(address poolAddress) external returns (uint256);

    /**
     * @notice Returns the index + 1 of the pool name in the registry
     * @param poolName pool name in bytes32 format to look for
     */
    function poolsIndexOfNamePlusOne(bytes32 poolName) external returns (uint256);

    /**
     * @notice Returns PoolData for given pool address
     * @param poolAddress address of the pool to read
     */
    function getPoolData(address poolAddress) external view returns (PoolData memory);

    /**
     * @notice Returns PoolData at given index
     * @param index index of the pool to read
     */
    function getPoolDataAtIndex(uint256 index) external view returns (PoolData memory);

    /**
     * @notice Returns PoolData with given name
     * @param poolName name of the pool to read
     */
    function getPoolDataByName(bytes32 poolName) external view returns (PoolData memory);

    /**
     * @notice Returns virtual price of the given pool address
     * @param poolAddress address of the pool to read
     */
    function getVirtualPrice(address poolAddress) external view returns (uint256);

    /**
     * @notice Returns A of the given pool address
     * @param poolAddress address of the pool to read
     */
    function getA(address poolAddress) external view returns (uint256);

    /**
     * @notice Returns the paused status of the given pool address
     * @param poolAddress address of the pool to read
     */
    function getPaused(address poolAddress) external view returns (bool);

    /**
     * @notice Returns the SwapStorage struct of the given pool address
     * @param poolAddress address of the pool to read
     */
    function getSwapStorage(address poolAddress) external view returns (SwapStorageData memory swapStorageData);

    /**
     * @notice Returns number of entries in the registry. Includes removed pools
     * in the list as well.
     */
    function getPoolsLength() external view returns (uint256);

    /**
     * @notice Returns an array of pool addresses that can swap between from and to
     * @param from address of the token to swap from
     * @param to address of the token to swap to
     * @return eligiblePools array of pool addresses that can swap between from and to
     */
    function getEligiblePools(address from, address to) external view returns (address[] memory eligiblePools);

    /**
     * @notice Returns an array of balances of the tokens
     * @param poolAddress address of the pool to look up the token balances for
     * @return balances array of token balances
     */
    function getTokenBalances(address poolAddress) external view returns (uint256[] memory balances);

    /**
     * @notice Returns an array of balances of the tokens
     * @param poolAddress address of the pool to look up the token balances for
     * @return balances array of token balances
     */
    function getUnderlyingTokenBalances(address poolAddress) external view returns (uint256[] memory balances);
}
