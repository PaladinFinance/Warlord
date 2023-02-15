// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "../../src/Staker.sol";
import "../../src/Token.sol";

contract WarStakerTest is MainnetTest {
  event Staked(address indexed caller, address indexed receiver, uint256 amount);
  event Unstaked(address indexed owner, address indexed receiver, uint256 amount);
  event Transfer(address indexed from, address indexed to, uint256 amount);
  event ClaimedRewards(address indexed reward, address indexed user, address indexed receiver, uint256 amount);
  event SetUserAllowedClaimer(address indexed user, address indexed claimer);
  event NewRewards(address indexed rewardToken, uint256 amount, uint256 endTimestamp);
  event AddedRewardDepositor(address indexed depositor);
  event RemovedRewardDepositor(address indexed depositor);
  event SetRewardFarmer(address indexed rewardToken, address indexed farmer);

  WarStaker staker;
  WarToken war;

  function setUp() public virtual override {
    MainnetTest.setUp();
    fork();

    vm.startPrank(admin);
    war = new WarToken();
    staker = new WarStaker(address(war));
    vm.stopPrank();

    deal(address(war), alice, 100e18);
    vm.prank(alice);
    war.approve(address(staker), 100e18);
  }
}
