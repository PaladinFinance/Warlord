// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./AuraLockerTest.sol";

contract SetDelegate is AuraLockerTest {
  address newDelegate = makeAddr("newDelegatee");

  function testDefaultBehavior() public {
    vm.prank(admin);
    locker.setDelegate(newDelegate);

    assertEq(
      registry.delegation(address(locker), "aurafinance.eth"),
      newDelegate,
      "the delegation registry should change accordingly"
    );
  }
}
