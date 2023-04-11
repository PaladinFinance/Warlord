// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ZapTest.sol";

contract ZapMutiple is ZapTest {
  function testDefaultBehavior(uint256 amountCvx, uint256 amountAura) public {
    vm.assume(amountCvx > 1e4 && amountCvx < cvx.balanceOf(alice));
    vm.assume(amountAura > 1e4 && amountAura < aura.balanceOf(alice));

    address[] memory tokens = new address[](2);
    tokens[0] = address(cvx);
    tokens[1] = address(aura);
    uint256[] memory amounts = new uint256[](2);
    amounts[0] = amountCvx;
    amounts[1] = amountAura;

    uint256 prevWarSupply = war.totalSupply();
    assertEq(war.balanceOf(alice), 0);
    assertEq(war.balanceOf(address(zap)), 0);

    uint256 initialStakedAmount = staker.balanceOf(alice);
    uint256 initialBalanceStaker = war.balanceOf(address(staker));

    assertEq(initialStakedAmount, 0, "initial staked balance should be zero");

    uint256 expectedMintAmount;
    expectedMintAmount += ratios.getMintAmount(address(cvx), amountCvx);
    expectedMintAmount += ratios.getMintAmount(address(aura), amountAura);

    vm.startPrank(alice);
    cvx.approve(address(zap), amountCvx);
    aura.approve(address(zap), amountAura);
    uint256 stakedAmount = zap.zapMultiple(tokens, amounts, alice);

    vm.stopPrank();

    assertEq(stakedAmount, expectedMintAmount);

    assertEq(cvx.balanceOf(address(zap)), 0);
    assertEq(aura.balanceOf(address(zap)), 0);

    assertEq(war.totalSupply(), prevWarSupply + expectedMintAmount);
    assertEq(war.balanceOf(alice), 0);
    assertEq(war.balanceOf(address(zap)), 0);

    assertEq(war.balanceOf(alice), 0);
    assertEq(
      war.balanceOf(address(staker)),
      initialBalanceStaker + expectedMintAmount,
      "contract should have received sender's war tokens"
    );
    assertEq(
      staker.balanceOf(alice),
      initialStakedAmount + expectedMintAmount,
      "receiver should have a corresponding amount of staked tokens"
    );
  }

  function testArrayEmpty() public {
    address[] memory tokens = new address[](0);
    uint256[] memory amounts = new uint256[](0);

    vm.expectRevert(Errors.EmptyArray.selector);
    zap.zapMultiple(tokens, amounts, alice);
  }

  function testArraySizeDifferent() public {
    address[] memory tokens = new address[](2);
    tokens[0] = address(cvx);
    tokens[1] = address(aura);
    uint256[] memory amounts = new uint256[](1);
    amounts[0] = 1e18;

    vm.expectRevert(abi.encodeWithSelector(Errors.DifferentSizeArrays.selector, tokens.length, amounts.length));
    zap.zapMultiple(tokens, amounts, alice);
  }

  function testZeroAmount1() public {
    address[] memory tokens = new address[](2);
    tokens[0] = address(cvx);
    tokens[1] = address(aura);
    uint256[] memory amounts = new uint256[](2);
    amounts[0] = 0;
    amounts[1] = 1e18;

    vm.startPrank(alice);
    cvx.approve(address(zap), type(uint256).max);
    aura.approve(address(zap), type(uint256).max);

    vm.expectRevert(Errors.ZeroValue.selector);
    zap.zapMultiple(tokens, amounts, alice);

    vm.stopPrank();
  }

  function testZeroAmount2() public {
    address[] memory tokens = new address[](2);
    tokens[0] = address(cvx);
    tokens[1] = address(aura);
    uint256[] memory amounts = new uint256[](2);
    amounts[0] = 1e18;
    amounts[1] = 0;

    vm.startPrank(alice);
    cvx.approve(address(zap), type(uint256).max);
    aura.approve(address(zap), type(uint256).max);

    vm.expectRevert(Errors.ZeroValue.selector);
    zap.zapMultiple(tokens, amounts, alice);

    vm.stopPrank();
  }

  function testAddressZeroToken1() public {
    address[] memory tokens = new address[](2);
    tokens[0] = zero;
    tokens[1] = address(aura);
    uint256[] memory amounts = new uint256[](2);
    amounts[0] = 1e18;
    amounts[1] = 1e18;

    vm.startPrank(alice);
    cvx.approve(address(zap), type(uint256).max);
    aura.approve(address(zap), type(uint256).max);

    vm.expectRevert(Errors.ZeroAddress.selector);
    zap.zapMultiple(tokens, amounts, alice);

    vm.stopPrank();
  }

  function testAddressZeroToken2() public {
    address[] memory tokens = new address[](2);
    tokens[0] = address(cvx);
    tokens[1] = zero;
    uint256[] memory amounts = new uint256[](2);
    amounts[0] = 1e18;
    amounts[1] = 1e18;

    vm.startPrank(alice);
    cvx.approve(address(zap), type(uint256).max);
    aura.approve(address(zap), type(uint256).max);

    vm.expectRevert(Errors.ZeroAddress.selector);
    zap.zapMultiple(tokens, amounts, alice);

    vm.stopPrank();
  }

  function testAddressZeroReceiver() public {
    address[] memory tokens = new address[](2);
    tokens[0] = address(cvx);
    tokens[1] = address(aura);
    uint256[] memory amounts = new uint256[](2);
    amounts[0] = 1e18;
    amounts[1] = 1e18;

    vm.expectRevert(Errors.ZeroAddress.selector);
    zap.zapMultiple(tokens, amounts, zero);
  }
}
