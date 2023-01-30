// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract BaseTest is Test {
  address alice = makeAddr("alice");
  address bob = makeAddr("bob");
}
