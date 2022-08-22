import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";

import type {
  BalancerAdapter,
  CurveAdapter,
  CurveCryptoAdapter,
  UniV2Adapter,
  UniV3Adapter,
} from "../src/types/SmartRoute/adapter/index";
import type {
  BalancerViewer,
  CurveCryptoViewer,
  CurveViewer,
  TokenViewer,
  UniV2Viewer,
  UniV3Viewer,
} from "../src/types/Viewer/index";

type Fixture<T> = () => Promise<T>;

declare module "mocha" {
  export interface Context {
    balancerAdapter: BalancerAdapter;
    curveAdapter: CurveAdapter;
    curveCryptoAdapter: CurveCryptoAdapter;
    uniV2Adapter: UniV2Adapter;
    uniV3Adapter: UniV3Adapter;
    balancerViewer: BalancerViewer;
    curveViewer: CurveViewer;
    curveCryptoViewer: CurveCryptoViewer;
    uniV2Viewer: UniV2Viewer;
    uniV3Viewer: UniV3Viewer;
    tokenViewer: TokenViewer;
    loadFixture: <T>(fixture: Fixture<T>) => Promise<T>;
    signers: Signers;
  }
}

export interface Signers {
  admin: SignerWithAddress;
}
