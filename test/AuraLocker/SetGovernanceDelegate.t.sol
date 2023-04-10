// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraLockerTest.sol";

contract SetGovernanceDelegate is AuraLockerTest {
  address newDelegate = makeAddr("newDelegatee");

  modifier withLock() {
    _mockMultipleLocks(1e25);

    _;
  }

  function testDefaultBehavior() public withLock {
    assertEq(vlAura.getVotes(newDelegate), 0, "untill a week a passed the delegatee shouldn't have voting power");

    vm.prank(admin);
    locker.setGovernanceDelegate(newDelegate);

    assertEq(
      vlAura.delegates(address(locker)), newDelegate, "onchain delegation should be assigned to the right address"
    );

    // It may take up to a week to update the delegation power
    vm.warp(block.timestamp + 7 days);

    assertGt(vlAura.getVotes(newDelegate), 0, "after a week has passed the delegatee should have his voting power");
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    locker.setDelegate(newDelegate);
  }

  function testDelegationRequiresLock() public {
    vm.expectRevert(Errors.DelegationRequiresLock.selector);

    vm.prank(admin);
    locker.setGovernanceDelegate(newDelegate);
  }
}
