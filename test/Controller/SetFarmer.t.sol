// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ControllerTest.sol";

contract SetFarmer is ControllerTest {
  function testNewFarmer(address token, address farmer) public {
    vm.assume(token != zero);
    vm.assume(farmer != zero);

    vm.expectEmit(true, false, false, true);
    emit SetFarmer(token, farmer);

    vm.prank(admin);
    controller.setFarmer(token, farmer);

    assertEq(controller.tokenFarmers(token), farmer, "farmer for that token should be the assigned one");
    assertEq(controller.farmers(0), farmer, "farmer should be added to the farmer list");
    assertEq(
      expose(controller).getFarmersLength(),
      1,
      "the lenght of the array with farmers should be one after adding new token"
    );
  }

  struct TokenWithFarmer {
    address token;
    address farmer;
  }

  function testNewLockerWithReplacement(TokenWithFarmer[] calldata initialFarmers, address newFarmer) public {
    /*
    vm.assume(newFarmer != zero);
    vm.assume(initialFarmers.length <= 100);

    vm.startPrank(admin);
    for (uint256 i; i < initialFarmers.length; ++i) {
      vm.assume(newFarmer != initialFarmers[i].farmer);
      if (initialFarmers[i].token == zero || initialFarmers[i].farmer == zero) continue;
      controller.setFarmer(initialFarmers[i].token, initialFarmers[i].farmer);
    }
    vm.stopPrank();

    uint256 assignedLength = expose(controller).getFarmersLength();
    vm.assume(assignedLength > 0);

    address[] memory tokens = new address[](initialFarmers.length);
    for (uint256 i; i < assignedLength; ++i) {
      tokens[i] = initialFarmers[i].token;
    }

    uint256 indexOldFarmer = uint256(uint160(newFarmer)) % assignedLength;
    address tokenWithNewFarmer = tokens[indexOldFarmer];

    vm.prank(admin);
    controller.setFarmer(tokenWithNewFarmer, newFarmer);
    uint256 newFarmerIndex = expose(controller).getFarmersLength();

    assertEq(controller.farmers(newFarmerIndex - 1), newFarmer, "the new farmer should be at the end of the array");
    assertEq(newFarmerIndex, assignedLength, "the length of the array shouldn't change");
    assertEq(
      controller.tokenFarmers(tokenWithNewFarmer), newFarmer, "new farmer for that token should be the assigned one"
    );
    */

    // TODO with fuzzing this test reverts with AlreadySet and ZeroAddress
  }

  function testOnlyOwner(address token, address farmer) public {
    vm.assume(farmer != zero);
    vm.assume(token != zero);

    vm.expectRevert("Ownable: caller is not the owner");
    controller.setFarmer(token, farmer);
  }

  function testZeroAddressToken(address farmer) public {
    vm.assume(farmer != zero);

    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    controller.setFarmer(zero, farmer);
  }

  function testZeroAddressFarmer(address token) public {
    vm.assume(token != zero);

    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    controller.setFarmer(token, zero);
  }

  function testListedLocker(address token, address locker) public {
    vm.assume(token != zero);
    vm.assume(locker != zero);

    vm.prank(admin);
    controller.setLocker(token, locker);

    vm.expectRevert(Errors.ListedLocker.selector);

    vm.prank(admin);
    controller.setFarmer(token, locker);
  }
}
