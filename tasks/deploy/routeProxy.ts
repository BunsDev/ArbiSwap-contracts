import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

import { config } from "../../config/matic_config";
import type { RouteProxy } from "../../src/types/SmartRoute/proxies";
import type { RouteProxy__factory } from "../../src/types/factories/SmartRoute/proxies/RouteProxy__factory";

task("deploy:RouteProxy").setAction(async function (taskArguments: TaskArguments, { ethers }) {
  const signers: SignerWithAddress[] = await ethers.getSigners();

  const RouteProxyFactory: RouteProxy__factory = <RouteProxy__factory>await ethers.getContractFactory("RouteProxy");
  const RouteProxy: RouteProxy = <RouteProxy>(
    await RouteProxyFactory.connect(signers[0]).deploy(
      config.ApproveProxy,
      config.AAVEV2LendingAddressProvider,
      config.WETH,
    )
  );
  await RouteProxy.deployed();
  console.log("RouteProxy deployed to: ", RouteProxy.address);
});
