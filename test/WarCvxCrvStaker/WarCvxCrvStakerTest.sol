// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "../../src/WarCvxCrvStaker.sol";
import "../../src/WarStaker.sol";
import "../../src/WarToken.sol";

contract WarCvxCrvStakerTest is MainnetTest {
  address controller = makeAddr("controller");
  WarToken war;
  WarStaker warStaker;
  WarCvxCrvStaker cvxCrvStaker;

  function setUp() public override {
    vm.startPrank(admin);
    war = new WarToken();
    warStaker = new WarStaker(address(war));
    cvxCrvStaker = new WarCvxCrvStaker(controller, address(warStaker));
    vm.stopPrank();
  }
}
