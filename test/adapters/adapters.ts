import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { ethers } from "hardhat";

import type { Signers } from "../types";
import { quoteBalancerAdapter, quoteCurveAdapter, quoteUniV2Adapter, quoteUniV3Adapter } from "./adapters.behavior";
import { deployAdaptersFixture } from "./adapters.fixtures";

describe("Unit tests", function () {
  before(async function () {
    this.signers = {} as Signers;

    const signers: SignerWithAddress[] = await ethers.getSigners();
    this.signers.admin = signers[0];

    this.loadFixture = loadFixture;
  });

  describe("Adapters", function () {
    beforeEach(async function () {
      const { balancerAdapter, curveAdapter, uniV2Adapter, uniV3Adapter } = await this.loadFixture(
        deployAdaptersFixture,
      );
      this.balancerAdapter = balancerAdapter;
      this.curveAdapter = curveAdapter;
      this.uniV2Adapter = uniV2Adapter;
      this.uniV3Adapter = uniV3Adapter;
    });

    quoteBalancerAdapter();
    quoteCurveAdapter();
    quoteUniV2Adapter();
    quoteUniV3Adapter();
  });
});
