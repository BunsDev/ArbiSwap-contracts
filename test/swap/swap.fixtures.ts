import { ethers } from "hardhat";

import { config } from "../../config/evmos_config";
import type { RouteProxy } from "../../src/types/SmartRoute/proxies/RouteProxy";
import type { RouteProxy__factory } from "../../src/types/factories/SmartRoute/proxies/index";
import { logger } from "../logger";

export async function deploySwapsFixture(): Promise<{
  routeProxy: RouteProxy;
}> {
  const routeProxyFactory: RouteProxy__factory = <RouteProxy__factory>await ethers.getContractFactory("RouteProxy");
  const routeProxy: RouteProxy = <RouteProxy>routeProxyFactory.attach(config.RouteProxy);
  logger.log("RouteProxy", "using contract", config.RouteProxy);

  return { routeProxy };
}
