// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraLockerTest.sol";

contract SetDelegate is AuraLockerTest {
  address newDelegatee = makeAddr("newDelegatee");

  function setUp() public override {
    AuraLockerTest.setUp();
  }

  function testWithVotingPower() public {
    _assertNoPendingRewards();
    _mockMultipleLocks(1e25);

    assertEq(vlAura.getVotes(newDelegatee), 0, "untill a week a passed the delegatee shouldn't have voting power");

    vm.prank(admin);
    locker.setDelegate(newDelegatee);

    // It may take up to a week to update the delegation power
    vm.warp(block.timestamp + 7 days);

    assertGt(vlAura.getVotes(newDelegatee), 0, "after a week has passed the delegatee should have his voting power");

    assertEq(locker.delegatee(), newDelegatee, "delegation value in contract has to be changed correctly");
    assertEq(
      registry.delegation(address(locker), "aurafinance.eth"),
      newDelegatee,
      "the delegation registry has to change accordingly"
    );
    assertEq(
      vlAura.delegates(address(locker)), newDelegatee, "onchain delegation should be assigned to the right address"
    );
  }

  function testWithoutVotingPower() public {
    vm.prank(admin);
    locker.setDelegate(newDelegatee);

    assertEq(locker.delegatee(), newDelegatee, "delegation value in contract has to be changed correctly");

    assertEq(
      registry.delegation(address(locker), "aurafinance.eth"),
      newDelegatee,
      "the delegation registry has to change accordingly"
    );
  }

  function testWithSameDelegateeOnSnapshot() public {
    _assertNoPendingRewards();
    _mockMultipleLocks(1e25);

    assertEq(vlAura.getVotes(delegatee), 0, "untill a week a passed the delegatee shouldn't have voting power");

    vm.prank(admin);
    locker.setDelegate(delegatee);

    // It may take up to a week to update the delegation power
    vm.warp(block.timestamp + 7 days);

    assertGt(vlAura.getVotes(delegatee), 0, "after a week has passed the delegatee should have his voting power");

    assertEq(locker.delegatee(), delegatee, "delegation value in contract has to be changed correctly");
    assertEq(
      registry.delegation(address(locker), "aurafinance.eth"),
      delegatee,
      "the delegation registry has to change accordingly"
    );
    assertEq(vlAura.delegates(address(locker)), delegatee, "onchain delegation should be assigned to the right address");
  }
}
