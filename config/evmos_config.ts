const evmos_config = {
  coin: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
  //WETH(WETH)
  WETH: "0xd4949664cd82660aae99bedc034a0dea8a0bd517",
  //lending address provider
  AAVEV2LendingAddressProvider: "0x0000000000000000000000000000000000000000",

  //flashloan from saddle finance(trisolaris usdt/usdc/frax)
  FlashloanSwap: "0x21d4365834B7c61447e142ef6bCf01136cBD01c6",

  //UniV2Factory
  EvmoSwapFactory: "0xf24e36e53628c3086493b9efa785ab9dd85232eb", //fee 0.25%
  DiffusionFactory: "0x6aBdDa34Fb225be4610a2d153845e09429523Cd2", //fee 0.3%
  CronusFactory: "0x20570b7bff86b2f92068622d0805160f318554be", //fee 0.2%

  Uni2Factories: [
    "0xf24e36e53628c3086493b9efa785ab9dd85232eb",
    "0x6aBdDa34Fb225be4610a2d153845e09429523Cd2",
    "0x20570b7bff86b2f92068622d0805160f318554be",
  ],
  Uni2Fees: [2500, 3000, 2000],

  //UniV3Factory
  UniV3Factory: "0x0000000000000000000000000000000000000000",
  // Saddle Pool Registry
  SaddleRegistry: "0x9c560A6879E4D3a8a88C8f6f39ebf028Ad7860Ab",
  //CurveAddressProvider
  CurveAddressProvider: "0x0000000000000000000000000000000000000000",

  //CurveRegistry
  CurveStableRegistry: "0x0000000000000000000000000000000000000000",
  CurveCryptoRegistry: "0x0000000000000000000000000000000000000000",
  // get curve factory registry from exchange
  // registry -> only factory ele!=address(0) at idx=0
  CurveFactoryRegistry: "0x0000000000000000000000000000000000000000",
  // 2 coins
  CurveCryptoFactoryRegistry: "0x0000000000000000000000000000000000000000",

  //UniV3
  TickLens: "0x0000000000000000000000000000000000000000",

  //Should deploy contracts below
  //Approve
  Approve: "0x1D29C0819A6Bc066C859F6CDB05A0C7a4E00B9dd",

  //Adapter
  UniV2Adapter: "0xBb1d41241eec1AB17A4076720D30496f4148c88a",
  UniV3Adapter: "0x0000000000000000000000000000000000000000",
  // for curve
  CurveAdapter: "0x0000000000000000000000000000000000000000",
  // for kinesis swap
  CurveNoRegistrysAdapter: "0x10A4F4A39865b2c355Fb72460Cb3874e161122ac",
  // for saddle swap fork()
  StableSwapAdapter: "0x9711577F5f7F7162B8086567Ed7b0CcF58A68876",
  BalancerAdapter: "0x0000000000000000000000000000000000000000",

  //Viewer
  UniV2Viewer: "0x988cD67a8bcd6749e55Dd5fEc0D56321de0885C4",
  UniV3Viewer: "0x0000000000000000000000000000000000000000",
  CurveViewer: "0x0000000000000000000000000000000000000000",
  CurveNoRegistryViewer: "0x33dF7290ED46B714D45Fa21AF857799dA6eeb2b0",
  StableSwapViewer: "0x8c41C6BafbF61F6F749Ef9D5CfF2d18399e2539a",
  CurveCryptoViewer: "0x0000000000000000000000000000000000000000",
  BalancerViewer: "0x0000000000000000000000000000000000000000",
  TokenViewer: "0xEfbA9791DfDf14844a3Cb2b31F28365F8123193a",

  //Proxy
  RouteProxy: "0x11D910B51E862788789DE7E30136e8463Bb32004",
  ApproveProxy: "0x19f6f1e909A8F9E3d31C2eFcb5274f8f86226eb8",

  //Tokens
  Tokens: {
    ETH: { address: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee", decimals: 18 },
    WETH: { address: "0xc9bdeed33cd01541e1eed10f90519d2c06fe3feb", decimals: 18 },
    DAI: { address: "0xe3520349f477a5f6eb06107066048508498a291b", decimals: 18 },
    CRF: { address: "0x026dda7f0f0a2e42163c9c80d2a5b6958e35fc49", decimals: 18 },
    FRAX: { address: "0xda2585430fef327ad8ee44af8f1f989a2a91a3d2", decimals: 18 },
    PAD: { address: "0x885f8cf6e45bdd3fdcdc644efdcd0ac93880c781", decimals: 18 },
    PICKLE: { address: "0x291c8fceaca3342b29cc36171deb98106f712c66", decimals: 18 },
    USDC: { address: "0xb12bfca5a55806aaf64e99521918a4bf0fc40802", decimals: 6 },
    WBTC: { address: "0xf4eb217ba2454613b15dbdea6e5f22276410e89e", decimals: 8 },
    NEAR: { address: "0xc42c30ac6cc15fac9bd938618bcaa1a1fae8501d", decimals: 24 },
    MODA: { address: "0x74974575d2f1668c63036d51ff48dbaa68e52408", decimals: 18 },
    AURORA: { address: "0x8bec47865ade3b172a928df8f990bc7f2a3b9f79", decimals: 18 },
    ROSE: { address: "0xdcd6d4e2b3e1d1e1e6fa8c21c8a323dcbecff970", decimals: 18 },
    MNFT: { address: "0xd126b48c072f4668e944a8895bc74044d5f2e85b", decimals: 18 },
    WANNA: { address: "0x7faa64faf54750a2e3ee621166635feaf406ab22", decimals: 18 },
    USDT: { address: "0x4988a896b1227218e4a686fde5eabdcabd91571f", decimals: 6 },
    PLY: { address: "0x09c9d464b58d96837f8d8b6f4d9fe4ad408d3a4f", decimals: 18 },
    FLX: { address: "0xea62791aa682d455614eaa2a12ba3d9a2fd197af", decimals: 18 },
    SOLACE: { address: "0x501ace9c35e60f03a2af4d484f49f9b1efde9f40", decimals: 18 },
    atUST: { address: "0x5ce9f0b6afb36135b5ddbf11705ceb65e634a9dc", decimals: 18 },
    BSTN: { address: "0x9f1f933c660a1dc856f0e0fe058435879c5ccef0", decimals: 18 },
  },

  BalancerPools: [],
  CurvePools: [],
  // stable swap
  SaddlePools: [
    "0x1275203FB58Fc25bC6963B13C2a1ED1541563aF0",
    "0x21d4365834B7c61447e142ef6bCf01136cBD01c6",
    "0x81272C5c573919eF0C719D6d63317a4629F161da",
  ],
  // Only base pools(curve)
  KinesisCurvePools: ["0x49b97224655AaD13832296b8f6185231AFB8aaCc", "0xbBD5a7AE45a484BD8dAbdfeeeb33E4b859D2c95C"],
  KinesisCurvePoolsNum: [3, 3],
  UniswapV3Pools: [],
};

export { evmos_config as config };
