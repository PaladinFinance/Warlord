// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./WarAuraBalFarmerTest.sol";

contract Stake is WarAuraBalFarmerTest {
  function _stake(address source, uint256 amount) internal {
    uint256 initialTokenBalance = IERC20(source).balanceOf(address(controller));

    // Can't deposit more than actual balance
    vm.assume(amount <= initialTokenBalance);

    // Initial balance for the staked auraBal is 0
    assertEq(auraBalStaker.balanceOf(address(warAuraBalFarmer)), 0);

    // Initial index is 0
    assertEq(warAuraBalFarmer.getCurrentIndex(), 0);

    // Testing the emissions
    vm.expectEmit(true, true, false, false); // TODO preciser errors
    emit Staked(auraBalStaker.balanceOf(address(warAuraBalFarmer)), warAuraBalFarmer.getCurrentIndex());

    vm.startPrank(controller);
    warAuraBalFarmer.stake(source, amount);
    vm.stopPrank();

    // Make sure the minimum amount was respected
    uint256 minOut = balDepositor.getMinOut(amount, warAuraBalFarmer.slippageBps());
    assertGe(warAuraBalFarmer.getCurrentIndex(), minOut);

    // If auraBal is already minted no zap needed so we can expect exact amounts
    if (source == address(auraBal)) {
      assertEq(auraBalStaker.balanceOf(address(warAuraBalFarmer)), amount);
    }
    // If bal is minted we just expected the balance to have increase from zero
    if (source == address(bal)) {
      assertGt(auraBalStaker.balanceOf(address(warAuraBalFarmer)), 0);
    }

    // Index increases accordingly
    assertEq(warAuraBalFarmer.getCurrentIndex(), auraBalStaker.balanceOf(address(warAuraBalFarmer)));

    // Check balance was deducted correctly
    assertEq(IERC20(source).balanceOf(address(controller)), initialTokenBalance - amount);
  }

  function testDefaultBehaviorBal(uint256 amount) public {
    // Testing with different slippage values
    uint256 slippage = amount % 500 >= 50 ? amount % 500 : 50;
    vm.prank(admin);
    warAuraBalFarmer.setSlippage(slippage);

    // Minimum amount to prevent high slippage when zapping
    vm.assume(amount > 1e18);

    _stake(address(bal), amount);
  }

  function testDefaultBehaviorAuraBal(uint256 amount) public {
    vm.assume(amount > 0);

    _stake(address(auraBal), amount);
  }

  function testWrongSource(address source) public {
    vm.assume(source != address(auraBal) && source != address(bal));
    vm.prank(controller);
    vm.expectRevert(Errors.IncorrectToken.selector);
    warAuraBalFarmer.stake(source, 500);
  }

  function testZeroValue() public {
    vm.startPrank(controller);
    vm.expectRevert(Errors.ZeroValue.selector);
    warAuraBalFarmer.stake(address(bal), 0);
    vm.expectRevert(Errors.ZeroValue.selector);
    warAuraBalFarmer.stake(address(auraBal), 0);
    vm.stopPrank();
  }

  function testOnlyController() public {
    vm.prank(alice);
    vm.expectRevert(Errors.CallerNotAllowed.selector);
    warAuraBalFarmer.stake(address(bal), 0);
  }
}
