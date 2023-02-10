// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarCvxLockerTest.sol";

contract Harvest is WarCvxLockerTest {
  function setUp() public override {
    WarCvxLockerTest.setUp();
    uint256 amountToStake = cvx.balanceOf(address(minter));
    vm.prank(address(minter));
    locker.lock(amountToStake);
  }

  function testDefaultBehavior() public {
    locker.harvest();
  }
}
