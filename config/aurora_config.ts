const aurora_config = {
  coin: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
  //WETH(WETH)
  WETH: "0xC9BdeEd33CD01541e1eeD10f90519d2C06Fe3feB",
  //lending address provider
  AAVEV2LendingAddressProvider: "0x0000000000000000000000000000000000000000",

  //flashloan from saddle finance(trisolaris usdt/usdc/usdn)
  FlashloanSwap: "0x458459E48dbAC0C8Ca83F8D0b7b29FEfE60c3970",

  //UniV2Factory
  AuroraSwapFactory: "0xC5E1DaeC2ad401eBEBdd3E32516d90Ab251A3aA3",
  WannaSwapFactory: "0x7928D4FeA7b2c90C732c10aFF59cf403f0C38246",
  NearpadFactory: "0x34484b4E416f5d4B45D4Add0B6eF6Ca08FcED8f1",
  TrisolarisFactory: "0xc66F594268041dB60507F00703b152492fb176E7",

  //UniV3Factory
  UniV3Factory: "0x0000000000000000000000000000000000000000",

  //CurveBasePool
  RoseCurveBasePool: "0xfF79D5bff48e1C01b722560D6ffDfCe9FC883587",

  //CurveAddressProvider
  CurveAddressProvider: "0x0000000022D53366457F9d5E68Ec105046FC4383",

  //CurveRegistry
  CurveStableRegistry: "0x5B5CFE992AdAC0C9D48E05854B2d91C73a003858",
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
  Approve: "0xcC59a96DDBd08bDA63163b0C4046326796cBE56c",

  //Adapter
  UniV2Adapter: "0xc75406f11cF2E638830f1f2822BC3ff12cAA0186",
  UniV3Adapter: "0x0000000000000000000000000000000000000000",
  // for curve
  CurveAdapter: "0xab98dbd0a6ba9a110a207263af1ff4b538584b6a",
  // for roseswap
  StableSwapNoRegistryAdapter: "0x107690e7827b9511969aB2F2587C82b33cA9483F",
  // for saddle swap fork()
  StableSwapAdapter: "0x8C34A04171DCf88F95d55403B3b411FfB563372d",
  BalancerAdapter: "0x0000000000000000000000000000000000000000",

  //Viewer
  UniV2Viewer: "0x416DEb7401bCb5CE1da7B7654505B29925EF7f17",
  UniV3Viewer: "0x0000000000000000000000000000000000000000",
  CurveViewer: "0xeD88594a23Be9f53E5958AEA54437A7719c1fb89",
  CurveNoRegistryViewer: "0x464B10C0e91CFe9F79d5c55017B92f9f90590DA3",
  StableSwapViewer: "0x8d7732602e006212A2eD1d244b0ab5C41EC8D7D8",
  CurveCryptoViewer: "0x0000000000000000000000000000000000000000",
  BalancerViewer: "0x0000000000000000000000000000000000000000",
  TokenViewer: "0x3734D23F3E6725fdAc0673EfaCA4b95Fd1c9E932",

  //Proxy
  RouteProxy: "0x10451448F015Db53f1674aAda83e2057e7BE90DD",
  ApproveProxy: "0xCd71c43aDcd144695deBcfC60B0838AE04A0836D",

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
  CurvePools: ["0xbF7E49483881C76487b0989CD7d9A8239B20CA41"],
  SaddlePools: [
    "0x458459E48dbAC0C8Ca83F8D0b7b29FEfE60c3970",
    "0x3CE7AAD78B9eb47Fd2b487c463A17AAeD038B7EC",
    "0x51d96EF6960cC7b4C884E1215564f926011A4064",
  ],
  // No registry Curve
  RoseCurvePools: [
    "0xc90dB0d8713414d78523436dC347419164544A3f",
    "0xa34315F1ef49392387Dd143f4578083A9Bd33E94",
    "0x8fe44f5cce02D5BE44e3446bBc2e8132958d22B8",
    "0xD6cb7Bb7D63f636d1cA72A1D3ed6f7F67678068a",
    "0x65a761136815B45A9d78d9781d22d47247B49D23",
    "0x79B0a67a4045A7a8DC04b17456F4fe15339cBA34",
  ],
  UniswapV3Pools: [],
};

export { aurora_config as config };
