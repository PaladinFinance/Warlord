// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import {WarStaker} from "../../src/Staker.sol";
import "../../src/BaseFarmer.sol";
import "../../src/Token.sol";
import "../../src/MintRatio.sol";
import {WarCvxCrvFarmer} from "../../src/CvxCrvFarmer.sol";
import {WarAuraBalFarmer} from "../../src/AuraBalFarmer.sol";

contract StakerTest is MainnetTest {
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
  WarMintRatio mintRatio;
  WarCvxCrvFarmer cvxCrvFarmer;
  WarAuraBalFarmer auraBalFarmer;

  address controller = makeAddr("controller");
  address yieldDumper = makeAddr("yieldDumper");

  function setUp() public virtual override {
    MainnetTest.setUp();
    fork();

    // Deploying base contracts
    vm.startPrank(admin);
    war = new WarToken();
    staker = new WarStaker(address(war));

    /*
    // Deploying farmers
    cvxCrvFarmer = new WarCvxCrvFarmer(address(controller), address(staker));
    auraBalFarmer = new WarAuraBalFarmer(address(controller), address(staker));

    // Dealing depositors their respective tokens
    deal(address(weth), yieldDumper, 1e35);

    deal(address(pal), controller, 1e28);
    deal(address(war), controller, 1000e18);
    deal(address(cvxFxs), controller, 1e28);

    // Linking farmers
    staker.setRewardFarmer(address(cvxCrv), address(cvxCrvFarmer));
    staker.setRewardFarmer(address(auraBal), address(auraBalFarmer));

    // Linking depositors
    staker.addRewardDepositor(controller);
    staker.addRewardDepositor(yieldDumper);

    TODO use this later for other tests
    */
    vm.stopPrank();
  }

  function randomRewardDepositor(uint256 seed) public view returns (address) {
    return randomBinaryAddress(controller, yieldDumper, seed);
  }

  function randomQueueableReward(uint256 seed) public returns (address sender, address reward) {
    address[] memory controllerRewards = new address[](3);
    controllerRewards[0] = address(pal);
    controllerRewards[1] = address(war);
    if (seed % 2 == 0) {
      sender = controller;
      reward = randomAddress(controllerRewards, seed);
    } else {
      sender = yieldDumper;
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

  function stake(address _token, uint256 _amount) external {}
  function harvest() external {}
  function sendTokens(address receiver, uint256 amount) external {}
  function migrate(address receiver) external override {}

  function token() external view returns (address) {
    return token_;
  }
}
