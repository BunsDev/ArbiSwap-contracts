import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

import { config } from "../../config/evmos_config";
import type {
  BalancerAdapter,
  CurveAdapter,
  CurveNoRegistryAdapter,
  StableSwapAdapter,
  UniV2Adapter,
  UniV3Adapter,
} from "../../src/types/SmartRoute/adapter/index";
import type {
  BalancerAdapter__factory,
  CurveAdapter__factory,
  CurveNoRegistryAdapter__factory,
  StableSwapAdapter__factory,
  UniV2Adapter__factory,
  UniV3Adapter__factory,
} from "../../src/types/factories/SmartRoute/adapter/index";

task("deploy:Adapters").setAction(async function (taskArguments: TaskArguments, { ethers }) {
  const signers: SignerWithAddress[] = await ethers.getSigners();
  // const balancerAdapterFactory: BalancerAdapter__factory = <BalancerAdapter__factory>(
  //   await ethers.getContractFactory("BalancerAdapter")
  // );
  // const balancerAdapter: BalancerAdapter = <BalancerAdapter>await balancerAdapterFactory.connect(signers[0]).deploy();
  // await balancerAdapter.deployed();
  // console.log("BalancerAdapter deployed to: ", balancerAdapter.address);

  // const curveAdapterFactory: CurveAdapter__factory = <CurveAdapter__factory>(
  //   await ethers.getContractFactory("CurveAdapter")
  // );
  // const curveAdapter: CurveAdapter = <CurveAdapter>(
  //   await curveAdapterFactory
  //     .connect(signers[0])
  //     .deploy(
  //       config.WETH,
  //       config.CurveStableRegistry,
  //       config.CurveCryptoRegistry,
  //       config.CurveFactoryRegistry,
  //       config.CurveCryptoFactoryRegistry,
  //     )
  // );
  // await curveAdapter.deployed();
  // console.log("CurveAdapter deployed to: ", curveAdapter.address);

  // const curveNoRegistryAdapterFactory: CurveNoRegistryAdapter__factory = <CurveNoRegistryAdapter__factory>(
  //   await ethers.getContractFactory("CurveNoRegistryAdapter")
  // );
  // const curveNoRegistryAdapter: CurveNoRegistryAdapter = <CurveNoRegistryAdapter>(
  //   await curveNoRegistryAdapterFactory
  //     .connect(signers[0])
  //     .deploy(config.KinesisCurvePools, config.KinesisCurvePoolsNum)
  // );
  // await curveNoRegistryAdapter.deployed();
  // console.log("CurveNoRegistryAdapter deployed to: ", curveNoRegistryAdapter.address);

  // const stableSwapAdapterFactory: StableSwapAdapter__factory = <StableSwapAdapter__factory>(
  //   await ethers.getContractFactory("StableSwapAdapter")
  // );
  // const stableSwapAdapter: StableSwapAdapter = <StableSwapAdapter>(
  //   await stableSwapAdapterFactory.connect(signers[0]).deploy(config.WETH, config.SaddleRegistry)
  // );
  // await stableSwapAdapter.deployed();
  // console.log("StableSwapAdapter deployed to: ", stableSwapAdapter.address);

  const uniV2AdapterFactory: UniV2Adapter__factory = <UniV2Adapter__factory>(
    await ethers.getContractFactory("UniV2Adapter")
  );
  const uniV2Adapter: UniV2Adapter = <UniV2Adapter>(
    await uniV2AdapterFactory.connect(signers[0]).deploy(config.UniV2Viewer)
  );
  await uniV2Adapter.deployed();
  console.log("UniV2Adapter deployed to: ", uniV2Adapter.address);

  // const uniV3AdapterFactory: UniV3Adapter__factory = <UniV3Adapter__factory>(
  //   await ethers.getContractFactory("UniV3Adapter")
  // );
  // const uniV3Adapter: UniV3Adapter = <UniV3Adapter>await uniV3AdapterFactory.connect(signers[0]).deploy(config.WETH);
  // await uniV3Adapter.deployed();
  // console.log("UniV3Adapter deployed to: ", uniV3Adapter.address);
});
