import { expect } from "chai";
import { ethers } from "hardhat";

import { config } from "../../config/matic_config";
import { logger } from "../logger";

export function quoteUniV3Adapter(): void {
  it("UniV3Adapter getAmountOut WMATIC to USDC", async function () {
    logger.log("UniV3Adapter:UniV3");
    logger.log(
      await this.uniV3Adapter
        .connect(this.signers.admin)
        .getAmountOut(
          config.WETH,
          ethers.utils.parseUnits("1000", 18),
          config.Tokens.USDC.address,
          "0xA374094527e1673A86dE625aa59517c5dE346d32",
        ),
    );
  });
}

export function quoteCurveAdapter(): void {
  it("CurveAdapter getAmountOut WMATIC to stMATIC", async function () {
    logger.log("CurveAdapter:Curve WMATIC to stMATIC");
    logger.log(
      await this.curveAdapter
        .connect(this.signers.admin)
        .getAmountOut(
          config.Tokens.amWBTC.address,
          ethers.utils.parseUnits("1000", 18),
          config.Tokens.renBTC.address,
          "0xC2d95EEF97Ec6C17551d45e77B590dc1F9117C67",
        ),
    );
  });
  it("CurveAdapter getAmountOut amWETH to amUSDC", async function () {
    //test error
    logger.log("CurveAdapter getAmountOut amWETH to amUSDC");

    logger.log(
      await this.curveAdapter
        .connect(this.signers.admin)
        .getAmountOut(
          config.Tokens.amWETH.address,
          ethers.utils.parseUnits("1000", 18),
          config.Tokens.amUSDC.address,
          "0x751B1e21756bDbc307CBcC5085c042a0e9AaEf36",
        ),
    );
  });
}
export function quoteBalancerAdapter(): void {
  it("BalancerAdapter getAmountOut WMATIC to USDC", async function () {
    logger.log("BalancerAdapter:Balancer");
    logger.log(
      await this.balancerAdapter
        .connect(this.signers.admin)
        .getAmountOut(
          config.WETH,
          ethers.utils.parseUnits("1000", 18),
          config.Tokens.USDC.address,
          "0x0297e37f1873D2DAb4487Aa67cD56B58E2F27875",
        ),
    );
  });
}

export function quoteUniV2Adapter(): void {
  it("UniV2 getAmountOut WMATIC to USDC", async function () {
    logger.log("UniV2:Mad Meerkat");
    logger.log(
      await this.uniV2Adapter
        .connect(this.signers.admin)
        .getAmountOut(
          config.WETH,
          ethers.utils.parseUnits("1000", 18),
          config.Tokens.USDC.address,
          "0xb965c131f1C48d89B1760860b782D2aCDF87273b",
        ),
    );

    logger.log("UniV2:Quick");
    logger.log(
      await this.uniV2Adapter
        .connect(this.signers.admin)
        .getAmountOut(
          config.WETH,
          ethers.utils.parseUnits("1000", 18),
          config.Tokens.USDC.address,
          "0x6e7a5fafcec6bb1e78bae2a1f0b612012bf14827",
        ),
    );

    logger.log("UniV2:Mesh");
    logger.log(
      await this.uniV2Adapter
        .connect(this.signers.admin)
        .getAmountOut(
          config.WETH,
          ethers.utils.parseUnits("1000", 18),
          config.Tokens.USDC.address,
          "0x6Ffe747579eD4E807Dec9B40dBA18D15226c32dC",
        ),
    );

    logger.log("UniV2:Sushi");
    logger.log(
      await this.uniV2Adapter
        .connect(this.signers.admin)
        .getAmountOut(
          config.WETH,
          ethers.utils.parseUnits("1000", 18),
          config.Tokens.USDC.address,
          "0xcd353F79d9FADe311fC3119B841e1f456b54e858",
        ),
    );
  });
}
