import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { ethers } from "hardhat";

import type { Signers } from "../types";
import {
  fetchBalancerViewer,
  fetchCurveCryptoViewer,
  fetchCurveViewer,
  fetchTokenViewer,
  fetchUniV2Viewer,
  fetchUniV3Viewer,
} from "./viewers.behavior";
import { deployViewersFixture } from "./viewers.fixtures";

describe("Unit tests", function () {
  before(async function () {
    this.signers = {} as Signers;

    const signers: SignerWithAddress[] = await ethers.getSigners();
    this.signers.admin = signers[0];

    this.loadFixture = loadFixture;
  });

  describe("Viewers", function () {
    beforeEach(async function () {
      const { balancerViewer, curveViewer, curveCryptoViewer, uniV2Viewer, uniV3Viewer, tokenViewer } =
        await this.loadFixture(deployViewersFixture);
      this.tokenViewer = tokenViewer;
      this.balancerViewer = balancerViewer;
      this.curveViewer = curveViewer;
      this.curveCryptoViewer = curveCryptoViewer;
      this.uniV2Viewer = uniV2Viewer;
      this.uniV3Viewer = uniV3Viewer;
    });

    // fetchBalancerViewer();
    // fetchCurveViewer();
    // fetchCurveCryptoViewer();
    // fetchUniV2Viewer();
    // fetchUniV3Viewer();
    // fetchTokenViewer();
  });
});
