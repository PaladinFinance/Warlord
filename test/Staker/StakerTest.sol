// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../WarlordTest.sol";
import {WarStaker} from "src/Staker.sol";
import {WarBaseFarmer} from "src/BaseFarmer.sol";
import {Harvestable} from "src/Harvestable.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract StakerTest is WarlordTest {
  event Staked(address indexed caller, address indexed receiver, uint256 amount);
  event Unstaked(address indexed owner, address indexed receiver, uint256 amount);
  event Transfer(address indexed from, address indexed to, uint256 amount);
  event ClaimedRewards(address indexed reward, address indexed user, address indexed receiver, uint256 amount);
  event SetUserAllowedClaimer(address indexed user, address indexed claimer);
  event NewRewards(address indexed rewardToken, uint256 amount, uint256 endTimestamp);
  event AddedRewardDepositor(address indexed depositor);
  event RemovedRewardDepositor(address indexed depositor);
  event SetRewardFarmer(address indexed rewardToken, address indexed farmer);

  uint256 constant CLAIM_REWARDS_PRECISION_LOSS = 1e6;
  address[] queueableRewards;

  struct RewardAndAmount {
    address reward;
    uint256 amount;
  }

  function fuzzRewards(uint256 seed) public returns (RewardAndAmount[] memory rewards) {
    return fuzzRewards(seed, true, true);
  }

  function fuzzRewards(uint256 seed, bool queue, bool index) public returns (RewardAndAmount[] memory rewards) {
    assertTrue(queue && index, "At least one type of reward should be selected");

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
    rewards[auraBalIndex].amount = rewardsAmount[auraBalIndex];

    uint256 cvxCrvIndex = numberOfRewards - 1;
    _increaseIndex(address(cvxCrv), rewardsAmount[cvxCrvIndex]);
    rewards[cvxCrvIndex].reward = address(cvxCrv);
    rewards[cvxCrvIndex].amount = rewardsAmount[cvxCrvIndex];
  }

  function fuzzStakers(uint256 seed, uint256 numberOfStakers) public returns (address[] memory stakers) {
    vm.assume(numberOfStakers > 0);
    numberOfStakers = numberOfStakers % 100 + 1;
    // Using fixed seed for addresses to speedup fuzzing
    stakers = generateAddressArrayFromHash(12_345, numberOfStakers);
    uint256[] memory amounts =
      generateNumberArrayFromHash(seed, numberOfStakers, WAR_SUPPLY_UPPER_BOUND / numberOfStakers);
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

  function setUp() public virtual override {
    WarlordTest.setUp();

    // Rewards list for testing
    queueableRewards.push(address(war));
    queueableRewards.push(address(pal));
    queueableRewards.push(address(weth));
    queueableRewards.push(address(cvxFxs));
  }

  function randomRewardDepositor(uint256 seed) public view returns (address) {
    return randomBinaryAddress(address(controller), swapper, seed);
  }

  function randomQueueableReward(uint256 seed) public returns (address sender, address reward) {
    address[] memory controllerRewards = new address[](2);
    controllerRewards[0] = address(pal);
    controllerRewards[1] = address(war);
    if (seed % 2 == 0) {
      sender = address(controller);
      reward = randomAddress(controllerRewards, seed);
    } else {
      sender = swapper;
      reward = address(weth);
    }
    deal(reward, sender, 1e35);
  }
}

contract WarDummyFarmerWithToken is WarBaseFarmer {
  address constant _controller = address(92_345_378);
  address constant _warStaker = address(9_298_435);
  address token_;

  constructor(address _token) WarBaseFarmer(_controller, _warStaker) {
    token_ = _token;
  }

  function token() external view returns (address) {
    return token_;
  }

  function _isTokenSupported(address /*_token*/ ) internal pure override returns (bool) {
    return true;
  }

  function _stakedBalance() internal override returns (uint256) {}

  function _stake(address, /* _token*/ uint256 /*_amount*/ ) internal pure override returns (uint256) {
    return 0;
  }

  function _harvest() internal override {}
  function _sendTokens(address receiver, uint256 amount) internal override {}
  function _migrate(address receiver) internal override {}
}
