import { ethers } from "hardhat";

import { config } from "../../config/matic_config";
import type {
  BalancerViewer,
  CurveCryptoViewer,
  CurveViewer,
  TokenViewer,
  UniV2Viewer,
  UniV3Viewer,
} from "../../src/types/Viewer/index";
import type {
  BalancerViewer__factory,
  CurveCryptoViewer__factory,
  CurveViewer__factory,
  TokenViewer__factory,
  UniV2Viewer__factory,
  UniV3Viewer__factory,
} from "../../src/types/factories/Viewer/index";
import { logger } from "../logger";

export async function deployViewersFixture(): Promise<{
  balancerViewer: BalancerViewer;
  curveViewer: CurveViewer;
  curveCryptoViewer: CurveCryptoViewer;
  uniV2Viewer: UniV2Viewer;
  uniV3Viewer: UniV3Viewer;
  tokenViewer: TokenViewer;
}> {
  const balancerViewerFactory: BalancerViewer__factory = <BalancerViewer__factory>(
    await ethers.getContractFactory("BalancerViewer")
  );
  const balancerViewer: BalancerViewer = <BalancerViewer>balancerViewerFactory.attach(config.BalancerViewer);
  logger.log("BalancerViewer", "using contract", config.BalancerViewer);
  const curveViewerFactory: CurveViewer__factory = <CurveViewer__factory>await ethers.getContractFactory("CurveViewer");
  const curveViewer: CurveViewer = <CurveViewer>curveViewerFactory.attach(config.CurveViewer);
  logger.log("CurveViewer", "using contract", config.CurveViewer);

  const curveCryptoViewerFactory: CurveCryptoViewer__factory = <CurveCryptoViewer__factory>(
    await ethers.getContractFactory("CurveCryptoViewer")
  );
  const curveCryptoViewer: CurveCryptoViewer = <CurveCryptoViewer>(
    curveCryptoViewerFactory.attach(config.CurveCryptoViewer)
  );
  logger.log("CurveCryptoViewer", "using contract", config.CurveCryptoViewer);

  const uniV2ViewerFactory: UniV2Viewer__factory = <UniV2Viewer__factory>await ethers.getContractFactory("UniV2Viewer");
  const uniV2Viewer: UniV2Viewer = <UniV2Viewer>uniV2ViewerFactory.attach(config.UniV2Viewer);
  logger.log("UniV2Viewer", "using contract", config.UniV2Viewer);

  const uniV3ViewerFactory: UniV3Viewer__factory = <UniV3Viewer__factory>await ethers.getContractFactory("UniV3Viewer");
  const uniV3Viewer: UniV3Viewer = <UniV3Viewer>uniV3ViewerFactory.attach(config.UniV3Viewer);
  logger.log("UniV3Viewer", "using contract", config.UniV3Viewer);

  const tokenViewerFactory: TokenViewer__factory = <TokenViewer__factory>await ethers.getContractFactory("TokenViewer");
  const tokenViewer: TokenViewer = <TokenViewer>tokenViewerFactory.attach(config.TokenViewer);
  logger.log("TokenViewer", "using contract", config.TokenViewer);

  return { balancerViewer, curveViewer, curveCryptoViewer, uniV2Viewer, uniV3Viewer, tokenViewer };
}
