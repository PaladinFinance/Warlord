// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ControllerTest.sol";

contract PullMultipleToken is UnexposedControllerTest {
  function testDefaultBehavior(uint256 seed, uint256 rewardsLength) public {
    vm.assume(rewardsLength > 0 && rewardsLength <= 10);

    uint256[] memory amounts = new uint256[](rewardsLength);
    MockERC20[] memory mocks = new MockERC20[](rewardsLength);
    address[] memory mocksAddress = new address[](rewardsLength);
    uint256[] memory initialBalances = new uint256[](rewardsLength);
    
    amounts = generateNumberArrayFromHash2(seed, rewardsLength, 1e5, 1e60);

    for(uint256 i; i < rewardsLength; i++) {
      mocks[i] = new MockERC20();
      mocksAddress[i] = address(mocks[i]);
      
      deal(address(mocks[i]), address(controller), amounts[i]);
      
      uint256 fee = computeFee(amounts[i]);
      amounts[i] -= fee;
    }

    controller.processMultiple(mocksAddress);

    for(uint256 i; i < rewardsLength; i++) {
      assertGt(controller.swapperAmounts(mocksAddress[i]), 0, "Sanity check doesn't pass");

      initialBalances[i] = mocks[i].balanceOf(address(swapper));
    }

    for(uint256 i; i < rewardsLength; i++) {
      vm.expectEmit();
    emit PullTokens(swapper, mocksAddress[i], amounts[i]);
    }
    vm.prank(swapper);
    controller.pullMultipleTokens(mocksAddress);

    for(uint256 i; i < rewardsLength; i++) {
      uint256 deltaBalance = mocks[i].balanceOf(address(swapper)) - initialBalances[i];

      assertEqDecimal(controller.swapperAmounts(mocksAddress[i]), 0, 18, "swapper amount should be put back to zero");
      assertEqDecimal(deltaBalance,  amounts[i], 18, "The amount without fees has been correctly pulled");
    }
  }

  function testEmptyArray() public {
    vm.expectRevert(Errors.EmptyArray.selector);

    vm.prank(swapper);
    controller.pullMultipleTokens(new address[](0));
  }
}
