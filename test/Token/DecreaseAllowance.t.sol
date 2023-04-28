// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./TokenTest.sol";

contract DecreaseAllowance is TokenTest {

    uint256 startingAllowance = 50_000 * 1e18;

    function setUp() public override {
        TokenTest.setUp();

        vm.prank(alice);
        war.approve(bob, startingAllowance);
    }

    function testDefaultBehavior(uint256 decreaseAmount) public {
        vm.assume(decreaseAmount <= startingAllowance);

        uint256 previousAllowance = war.allowance(alice, bob);

        vm.prank(alice);
        war.decreaseAllowance(bob, decreaseAmount);

        assertEq(war.allowance(alice, bob), previousAllowance - decreaseAmount);
    }

    function testUnderflow(uint256 decreaseAmount) public {
        vm.assume(decreaseAmount > startingAllowance);

        vm.startPrank(alice);
        
        vm.expectRevert(Errors.AllowanceUnderflow.selector);
        war.decreaseAllowance(bob, decreaseAmount);

        vm.stopPrank();
    }
}
