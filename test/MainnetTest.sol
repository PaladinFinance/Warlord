// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract MainnetTest is Test {
  address immutable CVX = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
	address immutable vlCVX = 0x72a19342e8F1838460eBFCCEf09F6585e32db86E;
  address immutable AURA = 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF;
	address immutable vlAURA = 0x3Fa73f1E5d8A792C80F426fc8F84FBF7Ce9bBCAC;
  address immutable cvxCRV = 0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7;
  address immutable auraBAL = 0x616e8BfA43F920657B3497DBf40D6b1A02D4608d;

  function fork() public {
    vm.createSelectFork(vm.rpcUrl("mainnet"));
  }
}
