import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

import { config } from "../../config/matic_config";
import type {
  BalancerViewer,
  CurveCryptoViewer,
  CurveViewer,
  UniV2Viewer,
  UniV3Viewer,
} from "../../src/types/Viewer/index";
import type {
  BalancerViewer__factory,
  CurveCryptoViewer__factory,
  CurveViewer__factory,
  UniV2Viewer__factory,
  UniV3Viewer__factory,
} from "../../src/types/factories/Viewer/index";

task("deploy:Viewers").setAction(async function (taskArguments: TaskArguments, { ethers }) {
  const signers: SignerWithAddress[] = await ethers.getSigners();
  const balancerViewerFactory: BalancerViewer__factory = <BalancerViewer__factory>(
    await ethers.getContractFactory("BalancerViewer")
  );
  const balancerViewer: BalancerViewer = <BalancerViewer>await balancerViewerFactory.connect(signers[0]).deploy();
  await balancerViewer.deployed();
  console.log("BalancerViewer deployed to: ", balancerViewer.address);

  const curveViewerFactory: CurveViewer__factory = <CurveViewer__factory>await ethers.getContractFactory("CurveViewer");
  const curveViewer: CurveViewer = <CurveViewer>(
    await curveViewerFactory.connect(signers[0]).deploy(config.CurveStableRegistry)
  );
  await curveViewer.deployed();
  console.log("CurveViewer deployed to: ", curveViewer.address);

  const curveCryptoViewerFactory: CurveCryptoViewer__factory = <CurveCryptoViewer__factory>(
    await ethers.getContractFactory("CurveCryptoViewer")
  );
  const curveCryptoViewer: CurveCryptoViewer = <CurveCryptoViewer>(
    await curveCryptoViewerFactory.connect(signers[0]).deploy(config.CurveCryptoRegistry)
  );
  await curveCryptoViewer.deployed();
  console.log("CurveCryptoViewer deployed to: ", curveCryptoViewer.address);

  const uniV2ViewerFactory: UniV2Viewer__factory = <UniV2Viewer__factory>await ethers.getContractFactory("UniV2Viewer");
  const uniV2Viewer: UniV2Viewer = <UniV2Viewer>await uniV2ViewerFactory.connect(signers[0]).deploy();
  await uniV2Viewer.deployed();
  console.log("UniV2Viewer deployed to: ", uniV2Viewer.address);

  const uniV3ViewerFactory: UniV3Viewer__factory = <UniV3Viewer__factory>await ethers.getContractFactory("UniV3Viewer");
  const uniV3Viewer: UniV3Viewer = <UniV3Viewer>await uniV3ViewerFactory.connect(signers[0]).deploy(config.TickLens);
  await uniV3Viewer.deployed();
  console.log("UniV3Viewer deployed to: ", uniV3Viewer.address);
});
