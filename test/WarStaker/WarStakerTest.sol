// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "../../src/WarStaker.sol";
import "../../src/WarToken.sol";

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

  address admin = makeAddr("admin");

  WarStaker staker;
  WarToken war;

  function setUp() public override {
    MainnetTest.setUp();
    fork();

    war = new WarToken(admin);
    vm.prank(admin);
    staker = new WarStaker(address(war));

    deal(address(war), alice, 100 ether);
    vm.prank(alice);
    war.approve(address(staker), 100 ether);
  }
}
