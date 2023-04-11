// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ZapTest.sol";

contract Zap is ZapTest {
  address receiver = makeAddr("receiver");

  function testDefaultBehavior(uint256 amount) public {
    vm.assume(amount > 1e4 && amount < aura.balanceOf(alice));
    IERC20 token = IERC20(randomVlToken(amount));

    uint256 prevWarSupply = war.totalSupply();
    assertEqDecimal(war.balanceOf(alice), 0, 18, "war balance at the beginning should be zero");
    assertEqDecimal(
      war.balanceOf(address(zap)), 0, 18, "war balance of the zap contract at the beginning should be zero"
    );

    uint256 initialStakedAmount = staker.balanceOf(receiver);
    uint256 initialBalanceStaker = war.balanceOf(address(staker));

    assertEqDecimal(initialStakedAmount, 0, 18, "initial staked balance should be zero");

    uint256 expectedMintAmount = ratios.getMintAmount(address(token), amount);

    vm.startPrank(alice);

    token.approve(address(zap), amount);

    vm.expectEmit(true, true, false, true);
    emit Zap(alice, receiver, expectedMintAmount);

    uint256 stakedAmount = zap.zap(address(token), amount, receiver);

    vm.stopPrank();

    assertEqDecimal(
      stakedAmount, expectedMintAmount, 18, "The amount staked should correspond to the ratios expected amount"
    );
    assertEqDecimal(
      staker.balanceOf(receiver),
      initialStakedAmount + expectedMintAmount,
      18,
      "receiver should have a corresponding amount of staked tokens"
    );

    assertEqDecimal(token.balanceOf(address(zap)), 0, 18, "The zap contract shouldn't have any vltoken after zap");

    assertEqDecimal(
      war.totalSupply(),
      prevWarSupply + expectedMintAmount,
      18,
      "the war total supply should have increased accordingly"
    );
    assertEqDecimal(war.balanceOf(alice), 0, 18, "alice shouldn't have any war after zap");
    assertEqDecimal(war.balanceOf(address(zap)), 0, 18, "the zap contract shoulnd't have any war token after zap");

    assertEqDecimal(war.balanceOf(alice), 0, 18, "alice shouldn't have any unstaked war after zap");
    assertEqDecimal(
      war.balanceOf(address(staker)),
      initialBalanceStaker + expectedMintAmount,
      18,
      "contract should have received sender's war tokens"
    );
  }

  function testZeroAmount() public {
    vm.expectRevert(Errors.ZeroValue.selector);
    zap.zap(address(aura), 0, address(this));

    vm.expectRevert(Errors.ZeroValue.selector);
    zap.zap(address(cvx), 0, address(this));
  }

  function testAddressZeroToken() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    zap.zap(zero, 1e18, address(this));
  }

  function testAddressZeroReceiver() public {
    vm.expectRevert(Errors.ZeroAddress.selector);
    zap.zap(address(aura), 1e18, zero);

    vm.expectRevert(Errors.ZeroAddress.selector);
    zap.zap(address(cvx), 1e18, zero);
  }

  function testWhenNotPaused(uint256 amount) public {
    vm.prank(admin);
    zap.pause();

    IERC20 token = IERC20(randomVlToken(amount));

    vm.expectRevert("Pausable: paused");
    zap.zap(address(token), amount, receiver);
  }
}
