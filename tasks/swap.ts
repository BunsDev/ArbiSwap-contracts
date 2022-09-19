import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import axios from "axios";
import { task } from "hardhat/config";
import type { TaskArguments } from "hardhat/types";

import { config } from "../config/evmos_config";
import type {
  BalancerAdapter,
  CurveAdapter,
  CurveNoRegistryAdapter,
  StableSwapAdapter,
  UniV2Adapter,
  UniV3Adapter,
} from "../src/types/SmartRoute/adapter/index";
import type {
  BalancerAdapter__factory,
  CurveAdapter__factory,
  CurveNoRegistryAdapter__factory,
  StableSwapAdapter__factory,
  UniV2Adapter__factory,
  UniV3Adapter__factory,
} from "../src/types/factories/SmartRoute/adapter/index";

task("swap:test").setAction(async function (taskArguments: TaskArguments, { ethers }) {
  const signers: SignerWithAddress[] = await ethers.getSigners();

  const response = await axios.post("http://0.0.0.0:1080/v1/quote/calculate", {
    options: {
      tokenInAddr: config.coin,
      tokenOutAddr: config.Tokens.OSMO.address,
      from: signers[0].address,
      amount: ethers.utils.parseUnits("1", 16).toString(),
      slippageBps: 100,
      maxEdge: 3,
      maxSplit: 5,
      withCycle: false,
    },
  });

  const txBytes = response.data.metamaskSwapTransaction.data as string;
  const tx = await signers[0].sendTransaction({
    to: config.RouteProxy,
    from: signers[0].address,
    gasLimit: 10000000,
    data: txBytes,
    value: ethers.utils.parseUnits("1", 16),
  });
  console.log(await tx.wait());
});
