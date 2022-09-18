import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

import { config } from "../../config/evmos_config";
import type {
  BalancerViewer,
  CurveCryptoViewer,
  CurveNoRegistryViewer,
  CurveViewer,
  StableSwapViewer,
  TokenViewer,
  UniV2Viewer,
  UniV3Viewer,
} from "../../src/types/Viewer/index";
import type {
  BalancerViewer__factory,
  CurveCryptoViewer__factory,
  CurveNoRegistryViewer__factory,
  CurveViewer__factory,
  StableSwapViewer__factory,
  TokenViewer__factory,
  UniV2Viewer__factory,
  UniV3Viewer__factory,
} from "../../src/types/factories/Viewer/index";

task("deploy:Viewers").setAction(async function (taskArguments: TaskArguments, { ethers }) {
  const signers: SignerWithAddress[] = await ethers.getSigners();
  // const balancerViewerFactory: BalancerViewer__factory = <BalancerViewer__factory>(
  //   await ethers.getContractFactory("BalancerViewer")
  // );
  // const balancerViewer: BalancerViewer = <BalancerViewer>await balancerViewerFactory.connect(signers[0]).deploy();
  // await balancerViewer.deployed();
  // console.log("BalancerViewer deployed to: ", balancerViewer.address);

  // const curveViewerFactory: CurveViewer__factory = <CurveViewer__factory>await ethers.getContractFactory("CurveViewer");
  // const curveViewer: CurveViewer = <CurveViewer>(
  //   await curveViewerFactory.connect(signers[0]).deploy(config.CurveStableRegistry, config.CurveFactoryRegistry)
  // );
  // await curveViewer.deployed();
  // console.log("CurveViewer deployed to: ", curveViewer.address);

  const stableSwapViewerFactory: StableSwapViewer__factory = <StableSwapViewer__factory>(
    await ethers.getContractFactory("StableSwapViewer")
  );
  const stableSwapViewer: StableSwapViewer = <StableSwapViewer>(
    await stableSwapViewerFactory.connect(signers[0]).deploy()
  );
  await stableSwapViewer.deployed();
  console.log("StableSwapViewer deployed to: ", stableSwapViewer.address);

  const curveNoRegistryViewerFactory: CurveNoRegistryViewer__factory = <CurveNoRegistryViewer__factory>(
    await ethers.getContractFactory("CurveNoRegistryViewer")
  );
  const curveNoRegistryViewer: CurveNoRegistryViewer = <CurveNoRegistryViewer>(
    await curveNoRegistryViewerFactory.connect(signers[0]).deploy(config.KinesisCurvePools)
  );
  await curveNoRegistryViewer.deployed();
  console.log("CurveNoRegistryViewer deployed to: ", curveNoRegistryViewer.address);

  // const curveCryptoViewerFactory: CurveCryptoViewer__factory = <CurveCryptoViewer__factory>(
  //   await ethers.getContractFactory("CurveCryptoViewer")
  // );
  // const curveCryptoViewer: CurveCryptoViewer = <CurveCryptoViewer>(
  //   await curveCryptoViewerFactory
  //     .connect(signers[0])
  //     .deploy(config.CurveCryptoRegistry, config.CurveCryptoFactoryRegistry)
  // );
  // await curveCryptoViewer.deployed();
  // console.log("CurveCryptoViewer deployed to: ", curveCryptoViewer.address);

  const uniV2ViewerFactory: UniV2Viewer__factory = <UniV2Viewer__factory>await ethers.getContractFactory("UniV2Viewer");
  const uniV2Viewer: UniV2Viewer = <UniV2Viewer>(
    await uniV2ViewerFactory.connect(signers[0]).deploy(config.Uni2Factories, config.Uni2Fees)
  );
  await uniV2Viewer.deployed();
  console.log("UniV2Viewer deployed to: ", uniV2Viewer.address);

  // const uniV3ViewerFactory: UniV3Viewer__factory = <UniV3Viewer__factory>await ethers.getContractFactory("UniV3Viewer");
  // const uniV3Viewer: UniV3Viewer = <UniV3Viewer>await uniV3ViewerFactory.connect(signers[0]).deploy(config.TickLens);
  // await uniV3Viewer.deployed();
  // console.log("UniV3Viewer deployed to: ", uniV3Viewer.address);

  const tokenViewerFactory: TokenViewer__factory = <TokenViewer__factory>await ethers.getContractFactory("TokenViewer");
  const tokenViewer: TokenViewer = <TokenViewer>await tokenViewerFactory.connect(signers[0]).deploy();
  await tokenViewer.deployed();
  console.log("TokenViewer deployed to: ", tokenViewer.address);
});
