// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ControllerTest.sol";

contract PullToken is UnexposedControllerTest {
  function testDefaultBehavior(uint256 amount) public {
    vm.assume(amount > 1e5 && amount < 1e60);

    MockERC20 mock = new MockERC20();

    deal(address(mock), address(controller), amount);

    uint256 fee = computeFee(amount);
    amount -= fee;

    controller.process(address(mock));

    assertGt(controller.swapperAmounts(address(mock)), 0, "Sanity check doesn't pass");

    uint256 initialBalance = mock.balanceOf(address(swapper));
    vm.expectEmit();
    emit PullTokens(swapper, address(mock), amount);
    vm.prank(swapper);
    controller.pullToken(address(mock));
    uint256 deltaBalance = mock.balanceOf(address(swapper)) - initialBalance;

    assertEqDecimal(controller.swapperAmounts(address(mock)), 0, 18, "swapper amount should be put back to zero");
    assertEqDecimal(deltaBalance, amount, 18, "The amount without fees has been correctly pulled");
  }

  function testWhenNotPaused() public {
    vm.prank(admin);
    controller.pause();

    MockERC20 mock = new MockERC20();

    vm.expectRevert("Pausable: paused");
    vm.prank(swapper);
    controller.pullToken(address(mock));
  }

  function testOnlySwapper(address token) public {
    vm.expectRevert(Errors.CallerNotAllowed.selector);
    controller.pullToken(token);
  }
}
