// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./RedeemerTest.sol";

contract NotifyUnlock is RedeemerTest {
  struct TokenIndex {
    uint256 queueIndex;
    uint256 redeemIndex;
  }

  function testDefaultBehavior(address token, uint256 amount) public {
    vm.assume(token != zero);

    DummyLocker locker = new DummyLocker(token);

    vm.prank(admin);
    redeemer.setLocker(token, address(locker));

    vm.prank(address(locker));
    redeemer.notifyUnlock(token, amount);
    (, uint256 redeemIndex) = redeemer.tokenIndexes(token);
    assertEq(redeemIndex, amount, "redeemIndex should have increased by amount");
  }

  function testNotListedLocker(address token, uint256 amount) public {
    vm.expectRevert(Errors.NotListedLocker.selector);

    redeemer.notifyUnlock(token, amount);
  }

  function testWhenNotPaused(address token, uint256 amount) public {
    vm.prank(admin);
    redeemer.pause();

    vm.expectRevert("Pausable: paused");

    redeemer.notifyUnlock(token, amount);
  }

  function testNotifyAlreadyUpdatedIndex(address token, uint256 previousAmount, uint256 amount) public {
    vm.assume(token != zero);
    vm.assume(previousAmount <= (type(uint256).max/2) && amount <= (type(uint256).max/2));

    DummyLocker locker = new DummyLocker(token);

    vm.prank(admin);
    redeemer.setLocker(token, address(locker));

    vm.prank(address(locker));
    redeemer.notifyUnlock(token, previousAmount);

    
    (, uint256 previousRedeemIndex) = redeemer.tokenIndexes(token);

    vm.prank(address(locker));
    redeemer.notifyUnlock(token, amount);
    (, uint256 redeemIndex) = redeemer.tokenIndexes(token);
    assertEq(redeemIndex, previousRedeemIndex + amount, "redeemIndex should have increased by amount");
  }
}
