// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarMinterTest.sol";

contract SetLocker is WarMinterTest {
  function testCantAddZeroAddressAsToken() public {
    vm.prank(admin);
    vm.expectRevert(Errors.ZeroAddress.selector);
    minter.setLocker(address(0), address(cvxLocker));
  }

  function testCantAddZeroAddressAsLocker() public {
    vm.prank(admin);
    vm.expectRevert(Errors.ZeroAddress.selector);
    minter.setLocker(address(cvx), address(0));
  }

  function testCantAddZeroAddresses() public {
    vm.prank(admin);
    vm.expectRevert(Errors.ZeroAddress.selector);
    minter.setLocker(address(0), address(0));
  }

  function testOnlyAdminCanCall() public {
    vm.prank(bob);
    // Not using errors because oz implementation
    vm.expectRevert("Ownable: caller is not the owner");
    minter.setLocker(address(cvx), address(cvxLocker));
  }

  function testCantSetMismatchingLocker(address notToken) public {
    vm.assume(notToken != address(0));
    IWarLocker newLocker = new vlMockLocker(address(new MockERC20()));
    vm.expectRevert(abi.encodeWithSelector(Errors.MismatchingLocker.selector, newLocker.token(), notToken));
    vm.prank(admin);
    minter.setLocker(notToken, address(newLocker));
  }

  function testAddNewLocker() public {
    ERC20 newToken = new MockERC20();
    deal(address(newToken), alice, 100 ether);
    IWarLocker newLocker = new vlMockLocker(address(newToken));
    vm.prank(admin);
    minter.setLocker(address(newToken), address(newLocker));
    vm.startPrank(alice);
    newToken.approve(address(minter), 1 ether);
    minter.mint(address(newToken), 1 ether);
    vm.stopPrank();
  }
}
