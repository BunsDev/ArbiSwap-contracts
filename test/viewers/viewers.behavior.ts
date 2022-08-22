import { expect } from "chai";
import { ethers } from "hardhat";

import { config } from "../../config/matic_config";
import { logger } from "../logger";

export function fetchTokenViewer(): void {
  it("TokenViewer fetch token info of WMATIC", async function () {
    logger.log("TokenViewer:WMATIC");
    logger.log(await this.tokenViewer.getTokenMetadata(config.WETH));
  });
}

export function fetchUniV3Viewer(): void {
  it("UniV3Viewer fetch pool info of WMATIC-USDC fee 0.05%", async function () {
    logger.log("UniV3Viewer:UniV3");
    logger.log(
      await this.uniV3Viewer.connect(this.signers.admin).getPoolInfo("0xA374094527e1673A86dE625aa59517c5dE346d32"),
    );
  });
}

export function fetchCurveViewer(): void {
  it("CurveViewer fetch pool info of WMATIC-stMATIC", async function () {
    logger.log("CurveViewer:Curve");
    logger.log(
      await this.curveViewer.connect(this.signers.admin).getPoolInfo("0xFb6FE7802bA9290ef8b00CA16Af4Bc26eb663a28"),
    );
  });
}

export function fetchCurveCryptoViewer(): void {
  it("CurveCryptoViewer fetch pool info of DAI-USDC-USDT-WBTC-WETH", async function () {
    logger.log("CurveCryptoViewer:Curve");
    logger.log(
      await this.curveCryptoViewer
        .connect(this.signers.admin)
        .getPoolInfo("0x92215849c439E1f8612b6646060B4E3E5ef822cC"),
    );
  });
  0;
}
export function fetchBalancerViewer(): void {
  it("BalancerViewer fetch pool info of WMATIC-USDC", async function () {
    logger.log("BalancerViewer:Balancer");
    logger.log(
      await this.balancerViewer.connect(this.signers.admin).getPoolInfo("0x0297e37f1873D2DAb4487Aa67cD56B58E2F27875"),
    );
  });
}

export function fetchUniV2Viewer(): void {
  it("UniV2 fetch pool info of WMATIC-USDC", async function () {
    logger.log("UniV2:Mad Meerkat");
    logger.log(
      await this.uniV2Viewer.connect(this.signers.admin).getPoolInfo("0xb965c131f1C48d89B1760860b782D2aCDF87273b"),
    );

    logger.log("UniV2:Quick");
    logger.log(
      await this.uniV2Viewer.connect(this.signers.admin).getPoolInfo("0x6e7a5fafcec6bb1e78bae2a1f0b612012bf14827"),
    );

    logger.log("UniV2:Mesh");
    logger.log(
      await this.uniV2Viewer.connect(this.signers.admin).getPoolInfo("0x6Ffe747579eD4E807Dec9B40dBA18D15226c32dC"),
    );

    logger.log("UniV2:Sushi");
    logger.log(
      await this.uniV2Viewer.connect(this.signers.admin).getPoolInfo("0xcd353F79d9FADe311fC3119B841e1f456b54e858"),
    );
  });
}
