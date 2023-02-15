// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarMinterTest.sol";

contract SetLocker is WarMinterTest {
  function testDefaultBehavior(uint256 amount, uint256 ratio) public {
    vm.assume(amount > 0 && amount < 1e27);
    vm.assume(ratio > 0 && ratio < 1e27);
    IERC20 newToken = IERC20(address(new MockERC20()));
    deal(address(newToken), alice, amount);
    IWarLocker newLocker = new vlMockLocker(address(newToken));
    MockMintRatio(address(mintRatio)).setRatio(address(newToken), ratio);
    vm.prank(admin);
    minter.setLocker(address(newToken), address(newLocker));
    vm.startPrank(alice);
    newToken.approve(address(minter), amount);
    minter.mint(address(newToken), amount);
    assertEq(war.balanceOf(alice), amount * ratio);
    vm.stopPrank();
  }

  function testCantAddZeroAddressAsToken(address randomAddress) public {
    vm.assume(randomAddress > zero);
    vm.prank(admin);
    vm.expectRevert(Errors.ZeroAddress.selector);
    minter.setLocker(zero, randomAddress);
  }

  function testCantAddZeroAddressAsLocker(address randomAddress) public {
    vm.assume(randomAddress > zero);
    vm.prank(admin);
    vm.expectRevert(Errors.ZeroAddress.selector);
    minter.setLocker(randomAddress, zero);
  }

  function testCantAddZeroAddresses() public {
    vm.prank(admin);
    vm.expectRevert(Errors.ZeroAddress.selector);
    minter.setLocker(zero, zero);
  }

  function testOnlyAdminCanCall() public {
    vm.prank(alice);
    vm.expectRevert("Ownable: caller is not the owner");
    minter.setLocker(address(cvx), address(cvxLocker));
  }

  function testCantSetMismatchingLocker(address notToken) public {
    IERC20 mockToken = IERC20(address(new MockERC20()));
    IWarLocker newLocker = new vlMockLocker(address(mockToken));
    vm.assume(notToken != zero && notToken != address(mockToken) && notToken != address(newLocker));
    vm.expectRevert(abi.encodeWithSelector(Errors.MismatchingLocker.selector, newLocker.token(), notToken));
    vm.prank(admin);
    minter.setLocker(notToken, address(newLocker));
  }
}
