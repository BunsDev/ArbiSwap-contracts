import axios from "axios";
import { BigNumber, BigNumberish } from "ethers";
import { ethers } from "hardhat";

import { config } from "../../config/evmos_config";
import { logger } from "../logger";

export function testUnitGetMultiHopSingleSwapOut(): void {
  it("UniV2", async function () {
    logger.log("UnitGetMultiHopSingleSwapOut:UniV2(Mad Meerkat) getAmountOut EVMOS to OSMO");
    logger.log(
      await this.routeProxy
        .connect(this.signers.admin)
        .callStatic.getMultiHopSingleSwapOut(
          config.coin,
          ethers.utils.parseUnits("1", 18),
          config.Tokens.OSMO.address,
          [
            {
              fromToken: config.coin,
              amountIn: ethers.utils.parseUnits("1", 18),
              toToken: config.Tokens.OSMO.address,
              to: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
              pool: "0x60057bEF562A9FA391f5631baeC630a1c230878B",
              adapter: config.UniV2Adapter,
              poolEdition: 0,
            },
          ],
        ),
    );

    logger.log(
      await this.routeProxy.connect(this.signers.admin).callStatic.multiHopSingleSwap(
        config.coin,
        ethers.utils.parseUnits("1", 18),
        config.Tokens.OSMO.address,
        [
          {
            fromToken: config.coin,
            amountIn: ethers.utils.parseUnits("1", 18),
            toToken: config.Tokens.OSMO.address,
            to: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee",
            // pool: "0x123063D3432171B125D17CafE4fb45E01b016953",
            pool: "0x60057bEF562A9FA391f5631baeC630a1c230878B",
            adapter: config.UniV2Adapter,
            poolEdition: 0,
          },
        ],
        1,
        "1700000000000",
        [0, 0],
        {
          value: ethers.utils.parseUnits("1", 18),
        },
      ),
    );

    logger.log(
      await this.routeProxy.connect(this.signers.admin).callStatic.shieldSwap(
        config.coin,
        ethers.utils.parseUnits("1", 16),
        config.Tokens.OSMO.address,
        {
          fromToken: config.coin,
          amountIn: ethers.utils.parseUnits("1", 16),
          toToken: config.Tokens.OSMO.address,
          to: this.signers.admin.address,
          weights: [1],
          weightedSwaps: [
            [
              {
                fromToken: config.coin,
                amountIn: 0,
                toToken: config.Tokens.OSMO.address,
                to: config.RouteProxy,
                pools: ["0x123063D3432171B125D17CafE4fb45E01b016953"],
                weights: [1],
                adapters: [config.UniV2Adapter],
                poolEditions: [0],
              },
            ],
          ],
        },
        [],
        21666,
        "1700000000000",
        [0, 0],
        {
          value: ethers.utils.parseUnits("1", 16),
        },
      ),
    );
  });

  it("UniV2 - Run tx from quoteserver", async function () {
    logger.log("Getting metamask tx");
    const response = await axios.post("http://0.0.0.0:1080/v1/quote/calculate", {
      options: {
        tokenInAddr: config.coin,
        tokenOutAddr: config.Tokens.OSMO.address,
        from: this.signers.admin.address,
        amount: ethers.utils.parseUnits("1", 19).toString(),
        slippageBps: 100,
        maxEdge: 5,
        maxSplit: 20,
        withCycle: false,
      },
    });

    let best: BigNumber = BigNumber.from(0);
    for (const singleDexResult of response.data.singleDexes) {
      if (best.lt(singleDexResult.expectedAmountOut)) {
        best = BigNumber.from(singleDexResult.expectedAmountOut);
      }
    }

    const txBytes = response.data.metamaskSwapTransaction.data as string;
    const amountOutHex = await this.signers.admin.call({
      to: config.RouteProxy,
      from: this.signers.admin.address,
      gasLimit: 50000000,
      data: txBytes,
      value: ethers.utils.parseUnits("1", 19),
    });
    logger.log("Best single dex result: ", best.toString());
    logger.log("Aggregate result:       ", parseInt(amountOutHex));
  });

  // it("CurveV1", async function () {
  //   logger.log("UnitGetMultiHopSingleSwapOut:CurveAdapter: ren Curve amWBTC to renBTC");
  //   logger.log(
  //     await this.routeProxy
  //       .connect(this.signers.admin)
  //       .getMultiHopSingleSwapOut(
  //         config.Tokens.amWBTC.address,
  //         ethers.utils.parseUnits("1", 18),
  //         config.Tokens.renBTC.address,
  //         [
  //           {
  //             fromToken: config.Tokens.amWBTC.address,
  //             amountIn: ethers.utils.parseUnits("1", 18),
  //             toToken: config.Tokens.renBTC.address,
  //             to: "0x0000000000000000000000000000000000000000",
  //             pool: "0xC2d95EEF97Ec6C17551d45e77B590dc1F9117C67",
  //             adapter: config.CurveAdapter,
  //             poolEdition: 1,
  //           },
  //         ],
  //       ),
  //   );

  //   logger.log("UnitGetMultiHopSingleSwapOut:CurveAdapter: aave USD Curve amDAI to amUSDT");
  //   logger.log(
  //     await this.routeProxy.connect(this.signers.admin).getMultiHopSingleSwapOut(
  //       config.Tokens.amDAI.address,
  //       ethers.utils.parseUnits("1", 18),
  //       config.Tokens.amUSDT.address,

  //       [
  //         {
  //           fromToken: config.Tokens.amDAI.address,
  //           amountIn: ethers.utils.parseUnits("1", 18),
  //           toToken: config.Tokens.amUSDT.address,
  //           to: "0x0000000000000000000000000000000000000000",
  //           pool: "0x445FE580eF8d70FF569aB36e80c647af338db351",
  //           adapter: config.CurveAdapter,
  //           poolEdition: 1,
  //         },
  //       ],
  //     ),
  //   );

  //   logger.log("UnitGetMultiHopSingleSwapOut:CurveAdapter: USD Factory Curve axlUSDC to USDC");
  //   logger.log(
  //     await this.routeProxy.connect(this.signers.admin).getMultiHopSingleSwapOut(
  //       config.Tokens.axlUSDC.address,
  //       ethers.utils.parseUnits("1", 18),
  //       config.Tokens.USDC.address,

  //       [
  //         {
  //           fromToken: config.Tokens.axlUSDC.address,
  //           amountIn: ethers.utils.parseUnits("1", 18),
  //           toToken: config.Tokens.USDC.address,
  //           to: "0x0000000000000000000000000000000000000000",
  //           pool: "0xfBA3b7Bb043415035220b1c44FB4756434639392",
  //           adapter: config.CurveAdapter,
  //           poolEdition: 1,
  //         },
  //       ],
  //     ),
  //   );
  // });

  // it("CurveV2", async function () {
  //   logger.log("UnitGetMultiHopSingleSwapOut:CurveAdapter: Crypto Factory Curve stMatic to Matic");
  //   logger.log(
  //     await this.routeProxy
  //       .connect(this.signers.admin)
  //       .getMultiHopSingleSwapOut(config.Tokens.stMATIC.address, ethers.utils.parseUnits("1", 18), config.coin, [
  //         {
  //           fromToken: config.Tokens.stMATIC.address,
  //           amountIn: ethers.utils.parseUnits("1", 18),
  //           toToken: config.coin,
  //           to: "0x0000000000000000000000000000000000000000",
  //           pool: "0xFb6FE7802bA9290ef8b00CA16Af4Bc26eb663a28",
  //           adapter: config.CurveAdapter,
  //           poolEdition: 1,
  //         },
  //       ]),
  //   );

  //   logger.log("UnitGetMultiHopSingleSwapOut:CurveAdapter: Crypto V2 Curve amWETH to am3CRV");
  //   logger.log(
  //     await this.routeProxy
  //       .connect(this.signers.admin)
  //       .getMultiHopSingleSwapOut(
  //         config.Tokens.amWETH.address,
  //         ethers.utils.parseUnits("1", 18),
  //         config.Tokens.am3CRV.address,
  //         [
  //           {
  //             fromToken: config.Tokens.amWETH.address,
  //             amountIn: ethers.utils.parseUnits("1", 18),
  //             toToken: config.Tokens.am3CRV.address,
  //             to: "0x0000000000000000000000000000000000000000",
  //             pool: "0x92215849c439E1f8612b6646060B4E3E5ef822cC",
  //             adapter: config.CurveAdapter,
  //             poolEdition: 1,
  //           },
  //         ],
  //       ),
  //   );
  // });

  // it("Balancer", async function () {
  //   logger.log("UnitGetMultiHopSingleSwapOut:BalancerAdapter: getAmountOut WMATIC to USDC");
  //   logger.log(
  //     await this.routeProxy.connect(this.signers.admin).getMultiHopSingleSwapOut(
  //       config.coin,
  //       ethers.utils.parseUnits("1", 18),
  //       config.Tokens.USDC.address,

  //       [
  //         {
  //           fromToken: config.coin,
  //           amountIn: ethers.utils.parseUnits("1", 18),
  //           toToken: config.Tokens.USDC.address,
  //           to: "0x0000000000000000000000000000000000000000",
  //           pool: "0x0297e37f1873D2DAb4487Aa67cD56B58E2F27875",
  //           adapter: config.BalancerAdapter,
  //           poolEdition: 1,
  //         },
  //       ],
  //     ),
  //   );
  // });

  // it("UniV3", async function () {
  //   logger.log("UnitGetMultiHopSingleSwapOut:UniV3Adapter: getAmountOut WMATIC to USDC");
  //   logger.log(
  //     await this.routeProxy
  //       .connect(this.signers.admin)
  //       .getMultiHopSingleSwapOut(config.coin, ethers.utils.parseUnits("1", 18), config.Tokens.USDC.address, [
  //         {
  //           fromToken: config.coin,
  //           amountIn: ethers.utils.parseUnits("1", 18),
  //           toToken: config.Tokens.USDC.address,
  //           to: "0x0000000000000000000000000000000000000000",
  //           pool: "0xA374094527e1673A86dE625aa59517c5dE346d32",
  //           adapter: config.UniV3Adapter,
  //           poolEdition: 1,
  //         },
  //       ]),
  //   );
  // });
}
