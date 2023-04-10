// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./ZapTest.sol";

contract ZapCvx is ZapTest {
    function testDefaultBehavior(uint256 amount) public {
        vm.assume(amount > 1e4 && amount < cvx.balanceOf(alice));
        
        uint256 prevWarSupply = war.totalSupply();
        assertEq(war.balanceOf(alice), 0);
        assertEq(war.balanceOf(address(zap)), 0);

        uint256 initialStakedAmount = staker.balanceOf(alice);
        uint256 initialBalanceStaker = war.balanceOf(address(staker));

        assertEq(initialStakedAmount, 0, "initial staked balance should be zero");

        uint256 expectedMintAmount = ratios.getMintAmount(address(cvx), amount);

        vm.startPrank(alice);
        cvx.approve(address(zap), amount);
        uint256 stakedAmount = zap.zap(address(cvx), amount, alice);

        vm.stopPrank();

        assertEq(stakedAmount, expectedMintAmount);

        assertEq(cvx.balanceOf(address(zap)), 0);

        assertEq(war.totalSupply(), prevWarSupply + expectedMintAmount);
        assertEq(war.balanceOf(alice), 0);
        assertEq(war.balanceOf(address(zap)), 0);

        assertEq(war.balanceOf(alice), 0);
        assertEq(war.balanceOf(address(staker)), initialBalanceStaker + expectedMintAmount, "contract should have received sender's war tokens");
        assertEq(staker.balanceOf(alice), initialStakedAmount + expectedMintAmount, "receiver should have a corresponding amount of staked tokens");
    }

    function testZeroAmount() public {
        vm.expectRevert(Errors.ZeroValue.selector);
        zap.zap(address(cvx), 0, alice);
    }

    function testAddressZeroToken() public {
        vm.expectRevert(Errors.ZeroAddress.selector);
        zap.zap(zero, 1e18, alice);
    }

    function testAddressZeroReceiver() public {
        vm.expectRevert(Errors.ZeroAddress.selector);
        zap.zap(address(cvx), 1e18, zero);
    }
}