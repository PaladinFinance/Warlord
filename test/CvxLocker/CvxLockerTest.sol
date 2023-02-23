// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../../src/CvxLocker.sol";
import "../../src/Token.sol";
import "../../src/Minter.sol";
import "../../src/MintRatio.sol";
import "../mocks/MockRedeemModule.sol";
import "../MainnetTest.sol";
import "interfaces/external/IDelegateRegistry.sol";

contract CvxLockerTest is MainnetTest {
  WarCvxLocker locker;
  address delegatee = makeAddr("delegatee");
  address controller = makeAddr("controller");
  WarMinter minter;
  WarToken war;
  WarMintRatio mintRatio;
  MockRedeem redeemModule;
  IDelegateRegistry registry = IDelegateRegistry(0x469788fE6E9E9681C6ebF3bF78e7Fd26Fc015446);

  using SafeERC20 for IERC20;

  function setUp() public virtual override {
    MainnetTest.setUp();
    fork();

    war = new WarToken();
    mintRatio = new WarMintRatio();
    minter = new WarMinter(address(war), address(mintRatio));

    redeemModule = new MockRedeem();
    vm.prank(admin);
    locker = new WarCvxLocker(controller, address(redeemModule), address(minter), delegatee);

    deal(address(cvx), address(minter), 1e30);

    vm.startPrank(address(minter));
    cvx.approve(address(locker), type(uint256).max);
    vm.stopPrank();
  }

  function _getRewards() internal view returns (uint256 cvxCrvRewards, uint256 cvxFxsRewards) {
    CvxLockerV2.EarnedData[] memory rewards = vlCvx.claimableRewards(address(locker));
    cvxCrvRewards = rewards[0].amount;
    cvxFxsRewards = rewards[1].amount;
  }

  function _assertNoPendingRewards() internal {
    (uint256 cvxCrvRewards, uint256 cvxFxsRewards) = _getRewards();
    assertEq(cvxCrvRewards, 0);
    assertEq(cvxFxsRewards, 0);
  }

  function _mockMultipleLocks(uint256 locksUpperBound) public {
    deal(address(cvx), address(minter), locksUpperBound * 1e10);
    uint256 totalLockAmount;

    // 112 days before locks start to expire, a new lock every day
    uint256[] memory lockAmounts = linspace(uint256(1e18), uint256(locksUpperBound), 114);
    vm.startPrank(address(minter));
    for (uint256 i; i < lockAmounts.length; ++i) {
      uint256 amount = lockAmounts[i];
      vm.warp(block.timestamp + 1 days);
      locker.lock(amount);
      totalLockAmount += amount;
    }
    vm.stopPrank();

    (, uint256 unlocked, uint256 locked,) = vlCvx.lockedBalances(address(locker));
    assertEq(unlocked, 0, "failed multiple locks setup");
    assertEq(locked, totalLockAmount, "failed multiple locks setup");
  }
}
