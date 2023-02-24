// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraLockerTest.sol";

contract SetDelegate is AuraLockerTest {
  function setUp() public override {
    AuraLockerTest.setUp();
    _assertNoPendingRewards();
    _mockMultipleLocks(1e25);
  }

  function testDefaultBehavior() public {
    vm.prank(admin);
    locker.setDelegate(delegatee);
    assertEq(locker.delegatee(), delegatee, "delegation value in contract has to be changed correctly");
    assertEq(
      registry.delegation(address(locker), "aurafinance.eth"),
      delegatee,
      "the delegation registry has to change accordingly"
    );
    assertEq(vlAura.delegates(address(locker)), delegatee, "onchain delegation should be assigned to the right address");
  }
}
