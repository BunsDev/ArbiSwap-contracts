import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";
import { ethers } from "hardhat";

import type { Signers } from "../types";
import { testUnitGetMultiHopSingleSwapOut } from "./swap.behavior";
import { deploySwapsFixture } from "./swap.fixtures";

describe("Unit tests", function () {
  before(async function () {
    this.signers = {} as Signers;

    const signers: SignerWithAddress[] = await ethers.getSigners();
    this.signers.admin = signers[0];

    this.loadFixture = loadFixture;
  });

  describe("Swap", function () {
    beforeEach(async function () {
      const { routeProxy } = await this.loadFixture(deploySwapsFixture);
      this.routeProxy = routeProxy;
    });

    testUnitGetMultiHopSingleSwapOut();
  });
});
