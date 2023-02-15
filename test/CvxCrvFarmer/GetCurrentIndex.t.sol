// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./CvxCrvFarmerTest.sol";

contract GetCurrentIndex is CvxCrvFarmerTest {
  function testDefaultBehvior(uint256 amount1, uint256 amount2, uint256 amount3) public {
    vm.assume(amount1 < 1e18 && amount2 < 1e18 && amount3 < 1e18 && amount1 + amount2 + amount3 < 1e18);
    uint256[] memory amount = new uint256[](3);
    amount[0] = amount1;
    amount[1] = amount2;
    amount[2] = amount3;
    uint256 totalStakedAmount;

    vm.startPrank(controller);
    for (uint256 i; i < 3; ++i) {
      uint256 currentAmount = amount[i];
      if (currentAmount > 0) {
        warCvxCrvFarmer.stake(address(crv), currentAmount);
        totalStakedAmount += currentAmount;
      }
      assertEq(warCvxCrvFarmer.getCurrentIndex(), totalStakedAmount);
    }
    vm.stopPrank();

    // Index doesn't change when sending tokens
    vm.startPrank(address(warStaker));
    for (uint256 i; i < 3; ++i) {
      uint256 currentAmount = amount[i];
      if (currentAmount > 0) {
        warCvxCrvFarmer.sendTokens(alice, currentAmount);
      }
      assertEq(warCvxCrvFarmer.getCurrentIndex(), totalStakedAmount);
    }
    vm.stopPrank();

    vm.startPrank(address(controller));
    for (uint256 i; i < 3; ++i) {
      uint256 currentAmount = amount[i];
      if (currentAmount > 0) {
        warCvxCrvFarmer.stake(address(crv), currentAmount);
        totalStakedAmount += currentAmount;
      }
      assertEq(warCvxCrvFarmer.getCurrentIndex(), totalStakedAmount);
    }
    vm.stopPrank();
  }
}
