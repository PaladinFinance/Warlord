// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ControllerTest.sol";

contract ProcessMultiple is UnexposedControllerTest {
  address[] tokens;

  function setUp() public override {
    UnexposedControllerTest.setUp();
    tokens.push(address(cvxCrv));
    tokens.push(address(cvx));
    tokens.push(address(auraBal));
    tokens.push(address(aura));
  }

  function testDefaultBehavior(uint256 amount) public {
    vm.assume(amount > 1 && amount < 1e33);

    deal(address(cvx), address(controller), amount);
    deal(address(aura), address(controller), amount);
    controller.processMultiple(tokens);

    assertEqDecimal(
      IERC20(cvx).balanceOf(address(controller)), 0, 18, "All the cvx received should have been converted to war"
    );
    assertEqDecimal(
      IERC20(aura).balanceOf(address(controller)), 0, 18, "All the aura received should have been converted to war"
    );
  }

  function testWhenNotPaused() public {
    vm.prank(admin);
    controller.pause();

    vm.expectRevert("Pausable: paused");
    controller.harvestMultiple(tokens);
  }
}
