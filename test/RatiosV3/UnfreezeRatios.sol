// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./RatiosV3Test.sol";

contract FreezeRatios is RatiosV3Test {
    function testDefaultBehavior() public {
    vm.prank(admin);
    ratiosV3.freezeRatios();
  
    assertEq(ratiosV3.isFrozen(), true);

    vm.prank(admin);
    ratiosV3.unfreezeRatios();

    assertEq(ratiosV3.isFrozen(), false);
  }

  function testOnlyAdmin() public {
    vm.expectRevert();
    ratiosV3.unfreezeRatios();
  }
}