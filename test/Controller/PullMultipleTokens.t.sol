// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ControllerTest.sol";

contract PullMultipleToken is UnexposedControllerTest {
  function testDefaultBehavior() public {
    // TODO
  }

  function testEmptyArray() public {
    vm.expectRevert(Errors.EmptyArray.selector);

    vm.prank(swapper);
    controller.pullMultipleTokens(new address[](0));
  }
}
