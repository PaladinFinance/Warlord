// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseLockerTest.sol";

contract SetRedeemModule is BaseLockerTest {
  function testDefaultBehavior(address newRedeemModule) public {
    vm.assume(newRedeemModule != zero && newRedeemModule != address(redeemModule));
    vm.prank(admin);

    vm.expectEmit(false, false, false, true);
    emit SetRedeemModule(newRedeemModule);

    dummyLocker.setRedeemModule(newRedeemModule);

    assertEq(address(dummyLocker.redeemModule()), newRedeemModule, "newRedeemModule should be the new redeem module");
  }

  function testRevertWithZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    vm.prank(admin);
    dummyLocker.setRedeemModule(zero);
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    dummyLocker.setRedeemModule(alice);
  }

  function testSameValue() public {
    vm.expectRevert(Errors.AlreadySet.selector);
    vm.prank(admin);
    dummyLocker.setRedeemModule(address(redeemModule));
  }
}
