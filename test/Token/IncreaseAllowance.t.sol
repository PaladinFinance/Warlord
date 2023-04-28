// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./TokenTest.sol";

contract IncreaseAllowance is TokenTest {
    function testDefaultBehavior(uint256 increaseAmount) public {
        vm.assume(increaseAmount <= type(uint256).max / 2);

        uint256 previousAllowance = war.allowance(alice, bob);

        vm.prank(alice);
        war.increaseAllowance(bob, increaseAmount);

        assertEq(war.allowance(alice, bob), previousAllowance + increaseAmount);
    }

    function testWithPreviousAllowance(uint256 previousAllowance, uint256 increaseAmount) public {
      unchecked {
        vm.assume(previousAllowance + increaseAmount > previousAllowance);
        vm.assume(previousAllowance + increaseAmount > increaseAmount);
        vm.assume(previousAllowance + increaseAmount <= type(uint256).max);
      }

        vm.prank(alice);
        war.approve(bob, previousAllowance);

        vm.prank(alice);
        war.increaseAllowance(bob, increaseAmount);

        assertEq(war.allowance(alice, bob), previousAllowance + increaseAmount);
    }
}
