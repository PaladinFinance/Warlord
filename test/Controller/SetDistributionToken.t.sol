// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ControllerTest.sol";

contract SetDistributionToken is ControllerTest {
  function testDefaultBehavior(address token) public {
    vm.assume(token != zero);
    bool distribution = randomBoolean(uint256(uint160(token)));

    vm.prank(admin);
    controller.setDistributionToken(token, distribution);
    assertEq(controller.distributionTokens(token), distribution, "distribution should be set accordingly");
  }

  function testZeroAddressToken(bool distribution) public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    controller.setDistributionToken(zero, distribution);
  }

  function testListedLocker(address token, address farmer) public {
    vm.assume(token != zero);
    vm.assume(farmer != zero);

    vm.prank(admin);
    controller.setLocker(token, farmer);

    bool distribution = randomBoolean(uint256(uint160(token)));

    vm.expectRevert(Errors.ListedLocker.selector);

    vm.prank(admin);
    controller.setDistributionToken(token, distribution);
  }

  function testListedFarmer(address token, address farmer) public {
    vm.assume(token != zero);
    vm.assume(farmer != zero);

    vm.prank(admin);
    controller.setFarmer(token, farmer);

    bool distribution = randomBoolean(uint256(uint160(token)));

    vm.expectRevert(Errors.ListedFarmer.selector);

    vm.prank(admin);
    controller.setDistributionToken(token, distribution);
  }

  function testOnlyOwner(address token) public {
    vm.assume(token != zero);
    bool distribution = randomBoolean(uint256(uint160(token)));

    vm.expectRevert("Ownable: caller is not the owner");

    controller.setDistributionToken(token, distribution);
  }
}
