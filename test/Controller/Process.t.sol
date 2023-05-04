// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ControllerTest.sol";

contract Process is UnexposedControllerTest {
  function testWhenNotPaused(address reward) public {
    vm.prank(admin);
    controller.pause();

    vm.expectRevert("Pausable: paused");
    controller.process(reward);
  }

  function testZeroAddress() public {
    // TODO vm.expectCall when new version available
    IERC20 mock = IERC20(address(new MockERC20()));
    vm.expectCall(address(mock), abi.encodeCall(mock.balanceOf, address(controller)), 0);
    controller.process(zero);
  }

  function testZeroBalance() public {
    // TODO vm.expectCall when new version available
    IERC20 mock = IERC20(address(new MockERC20()));
    controller.process(address(mock));
  }

  function computeFee(uint256 balance) public view returns (uint256) {
    return (balance * controller.feeRatio()) / 10_000;
  }

  function testLocker(/*uint256 amount*/) public {
    uint256 amount = 10000000;
    uint256 fee = computeFee(amount);

    address token = randomVlToken(amount);
    deal(token, address(controller), amount);

    uint256 initialQueuedWar = war.balanceOf(address(staker));

    controller.process(token);
    console.log(controller.tokenLockers(address(cvx)));

    uint256 warDelta = war.balanceOf(address(staker)) - initialQueuedWar;
    assertEqDecimal(warDelta, amount - fee, 18, "Fee should have taken from queued amount");
  }

  function testFarmer() public {
  }
  function testDirectDistribution() public {
  }
  function testSwapToken() public {
  }
}
