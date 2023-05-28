// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "../WarlordTest.sol";
import {WarBaseFarmer} from "src/BaseFarmer.sol";

contract E2ETest is WarlordTest {
  address[] queueableRewards;

  struct RewardAndAmount {
    address reward;
    uint256 amount;
  }

  function setUp() public override {
    WarlordTest.setUp();

    queueableRewards.push(address(war));
    queueableRewards.push(address(pal));
    queueableRewards.push(address(weth));
    queueableRewards.push(address(cvxFxs));
  }

  function fuzzRewardsAndStakers(uint256 seed, uint256 numberOfStakers)
    public
    returns (address[] memory stakers, RewardAndAmount[] memory rewards)
  {
    stakers = fuzzStakers(seed, numberOfStakers);
    rewards = fuzzRewards(seed);
  }

  function fuzzRewards(uint256 seed) public returns (RewardAndAmount[] memory rewards) {
    return fuzzRewards(seed, true, true);
  }

  function fuzzRewards(uint256 seed, bool queue, bool index) public returns (RewardAndAmount[] memory rewards) {
    assertTrue(queue || index, "At least one type of reward should be selected");

    uint256 numberOfRewards;
    if (queue) {
      numberOfRewards += queueableRewards.length;
    }
    if (index) {
      numberOfRewards += 2;
    }
    uint256 REWARDS_UPPERBOUND = 1e55;

    rewards = new RewardAndAmount[](numberOfRewards);

    uint256[] memory rewardsAmount = generateNumberArrayFromHash(seed, numberOfRewards, REWARDS_UPPERBOUND);
    for (uint256 i; i < queueableRewards.length; ++i) {
      _queue(queueableRewards[i], rewardsAmount[i]);
      rewards[i].reward = queueableRewards[i];
      rewards[i].amount = rewardsAmount[i];
    }

    uint256 auraBalIndex = numberOfRewards - 2;
    _increaseIndex(address(auraBal), rewardsAmount[auraBalIndex]);
    rewards[auraBalIndex].reward = address(auraBal);
    assertGt(rewardsAmount[auraBalIndex], 0, "the amount of rewards should be bigger than zero");
    rewards[auraBalIndex].amount = rewardsAmount[auraBalIndex];

    uint256 cvxCrvIndex = numberOfRewards - 1;
    _increaseIndex(address(cvxCrv), rewardsAmount[cvxCrvIndex]);
    rewards[cvxCrvIndex].reward = address(cvxCrv);
    assertGt(rewardsAmount[cvxCrvIndex], 0, "the amount of rewards should be bigger than zero");
    rewards[cvxCrvIndex].amount = rewardsAmount[cvxCrvIndex];
  }

  function fuzzStakers(uint256 seed, uint256 numberOfStakers) public returns (address[] memory stakers) {
    vm.assume(numberOfStakers > 0);
    numberOfStakers = numberOfStakers % 100 + 1;
    // Using fixed seed for addresses to speedup fuzzing
    stakers = generateAddressArrayFromHash(seed, numberOfStakers);
    uint256[] memory amounts = generateNumberArrayFromHash(seed, numberOfStakers, 10_000e18 * 7e9 / numberOfStakers);
    for (uint256 i; i < numberOfStakers; ++i) {
      _stake(stakers[i], amounts[i]);
    }
  }

  function _queue(address rewards, uint256 amount) public {
    deal(rewards, swapper, amount);

    vm.startPrank(swapper);
    IERC20(rewards).transfer(address(staker), amount);
    staker.queueRewards(rewards, amount);
    vm.stopPrank();
  }

  function _stake(address _staker, uint256 amount) public {
    deal(address(war), _staker, amount);

    vm.startPrank(_staker);
    war.approve(address(staker), amount);
    staker.stake(amount, _staker);
    vm.stopPrank();
  }

  function _increaseIndex(address token, uint256 amount) public {
    WarBaseFarmer farmer = token == address(cvxCrv) ? WarBaseFarmer(cvxCrvFarmer) : WarBaseFarmer(auraBalFarmer);

    deal(address(token), address(controller), amount);

    vm.startPrank(address(controller));
    IERC20(token).approve(address(farmer), amount);
    farmer.stake(token, amount);
    vm.stopPrank();
  }
}
