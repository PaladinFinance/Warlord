// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ZapTest.sol";

contract Recover is ZapTest {
  function testDefaultBehavior(uint256 amount) public {
    vm.assume(amount > 0 && amount < 15_000e18);
    deal(address(crv), address(admin), amount);

    vm.startPrank(admin);
    crv.transfer(address(zap), amount);

    uint256 prevBalance = crv.balanceOf(address(admin));

    zap.recoverERC20(address(crv));

    vm.stopPrank();

    assertEq(crv.balanceOf(admin), prevBalance + amount);
    assertEq(crv.balanceOf(address(zap)), 0);
  }

  function testZeroBalance() public {
    vm.expectRevert(Errors.ZeroValue.selector);
    vm.prank(admin);
    zap.recoverERC20(address(crv));
  }

  function testAddressZeroToken() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    zap.recoverERC20(zero);
  }

  function testOnlyOwner(address caller) public {
    vm.assume(caller != admin);
    vm.expectRevert("Ownable: caller is not the owner");
    vm.prank(caller);
    zap.recoverERC20(address(crv));
  }
}
