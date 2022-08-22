import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

import { config } from "../../config/matic_config";
import type { Approve } from "../../src/types/SmartRoute/Approve";
import type { ApproveProxy } from "../../src/types/SmartRoute/ApproveProxy.sol";
import type { RouteProxy } from "../../src/types/SmartRoute/proxies";
import type { ApproveProxy__factory } from "../../src/types/factories/SmartRoute/ApproveProxy.sol/ApproveProxy__factory";
import type { Approve__factory } from "../../src/types/factories/SmartRoute/Approve__factory";
import type { RouteProxy__factory } from "../../src/types/factories/SmartRoute/proxies/RouteProxy__factory";

task("deploy:Route").setAction(async function (taskArguments: TaskArguments, { ethers }) {
  const signers: SignerWithAddress[] = await ethers.getSigners();

  const approveFactory: Approve__factory = <Approve__factory>await ethers.getContractFactory("Approve");
  const approve: Approve = <Approve>await approveFactory.connect(signers[0]).deploy();
  await approve.deployed();
  console.log("Approve deployed to: ", approve.address);

  const approveProxyFactory: ApproveProxy__factory = <ApproveProxy__factory>(
    await ethers.getContractFactory("ApproveProxy")
  );
  const approveProxy: ApproveProxy = <ApproveProxy>(
    await approveProxyFactory.connect(signers[0]).deploy(approve.address)
  );
  await approveProxy.deployed();
  console.log("ApproveProxy deployed to: ", approveProxy.address);

  const RouteProxyFactory: RouteProxy__factory = <RouteProxy__factory>await ethers.getContractFactory("RouteProxy");
  const RouteProxy: RouteProxy = <RouteProxy>(
    await RouteProxyFactory.connect(signers[0]).deploy(
      approveProxy.address,
      config.AAVEV2LendingAddressProvider,
      config.WETH,
    )
  );
  await RouteProxy.deployed();
  console.log("RouteProxy deployed to: ", RouteProxy.address);
  await approve.init(signers[0].address, RouteProxy.address);
});
