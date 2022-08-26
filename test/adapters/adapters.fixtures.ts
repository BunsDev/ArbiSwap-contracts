import { ethers } from "hardhat";

import { config } from "../../config/matic_config";
import type {
  BalancerAdapter,
  CurveAdapter,
  UniV2Adapter,
  UniV3Adapter,
} from "../../src/types/SmartRoute/adapter/index";
import type {
  BalancerAdapter__factory,
  CurveAdapter__factory,
  UniV2Adapter__factory,
  UniV3Adapter__factory,
} from "../../src/types/factories/SmartRoute/adapter/index";
import { logger } from "../logger";

export async function deployAdaptersFixture(): Promise<{
  balancerAdapter: BalancerAdapter;
  curveAdapter: CurveAdapter;
  uniV2Adapter: UniV2Adapter;
  uniV3Adapter: UniV3Adapter;
}> {
  const balancerAdapterFactory: BalancerAdapter__factory = <BalancerAdapter__factory>(
    await ethers.getContractFactory("BalancerAdapter")
  );
  const balancerAdapter: BalancerAdapter = <BalancerAdapter>balancerAdapterFactory.attach(config.BalancerAdapter);
  logger.log("BalancerAdapter", "using contract", config.BalancerAdapter);
  const curveAdapterFactory: CurveAdapter__factory = <CurveAdapter__factory>(
    await ethers.getContractFactory("CurveAdapter")
  );
  const curveAdapter: CurveAdapter = <CurveAdapter>curveAdapterFactory.attach(config.CurveAdapter);
  logger.log("CurveAdapter", "using contract", config.CurveAdapter);

  const uniV2AdapterFactory: UniV2Adapter__factory = <UniV2Adapter__factory>(
    await ethers.getContractFactory("UniV2Adapter")
  );
  const uniV2Adapter: UniV2Adapter = <UniV2Adapter>uniV2AdapterFactory.attach(config.UniV2Adapter);
  logger.log("UniV2Adapter", "using contract", config.UniV2Adapter);

  const uniV3AdapterFactory: UniV3Adapter__factory = <UniV3Adapter__factory>(
    await ethers.getContractFactory("UniV3Adapter")
  );
  const uniV3Adapter: UniV3Adapter = <UniV3Adapter>uniV3AdapterFactory.attach(config.UniV3Adapter);
  logger.log("UniV3Adapter", "using contract", config.UniV3Adapter);

  return { balancerAdapter, curveAdapter, uniV2Adapter, uniV3Adapter };
}
