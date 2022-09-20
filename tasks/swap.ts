import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import axios from "axios";
import { BigNumber } from "ethers";
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
  const input = ethers.utils.parseUnits("5", 18).toString();
  const response = await axios.post(`${process.env.API_SERVER_ENDPOINT}/v1/quote/calculate`, {
    options: {
      tokenInAddr: config.coin,
      tokenOutAddr: config.coin,
      from: signers[0].address,
      amount: input,
      slippageBps: 50,
      maxEdge: 5,
      maxSplit: 5,
      withCycle: false,
    },
  });
  console.log(BigNumber.from(response.expectedAmountOut).div(ethers.utils.parseUnits("1", 18)));
  if (BigNumber.from(response.expectedAmountOut).gt(BigNumber.from(input).add(ethers.utils.parseUnits("1", 18)))) {
    const txBytes = response.data.metamaskSwapTransaction.data as string;
    const tx = await signers[0].sendTransaction({
      to: config.RouteProxy,
      from: signers[0].address,
      gasLimit: 10000000,
      data: txBytes,
      value: input,
    });
    console.log(await tx.wait());
  }
});
