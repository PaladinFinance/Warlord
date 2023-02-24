// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraLockerTest.sol";

contract SetDelegate is AuraLockerTest {
  function setUp() public override {
    AuraLockerTest.setUp();
    _assertNoPendingRewards();
    _mockMultipleLocks(1e25);
  }

  function testDefaultBehavior(address _delegatee) public {
    vm.assume(_delegatee != locker.delegatee() && _delegatee != zero && _delegatee != address(locker));
    vm.prank(admin);
    locker.setDelegate(_delegatee);
    assertEq(locker.delegatee(), _delegatee, "delegation value in contract has to be changed correctly");
    assertEq(
      registry.delegation(address(locker), "aurafinance.eth"), _delegatee, "the delegation registry has to change accordingly"
    );
  }
}
