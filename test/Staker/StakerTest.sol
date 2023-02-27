// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "../../src/Staker.sol";
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

    // Deploying farmers
    cvxCrvFarmer = new WarCvxCrvFarmer(address(controller), address(staker));
    auraBalFarmer = new WarAuraBalFarmer(address(controller), address(staker));

    // Dealing depositors their respective tokens
    deal(address(pal), yieldDumper, 1e28);
    deal(address(weth), yieldDumper, 1e35);

    deal(address(war), controller, 1000e18); 

    // Linking farmers
    staker.setRewardFarmer(address(cvxCrv), address(cvxCrvFarmer));
    staker.setRewardFarmer(address(auraBal), address(auraBalFarmer));

    // Linking depositors
    staker.addRewardDepositor(controller);
    staker.addRewardDepositor(yieldDumper);

    vm.stopPrank();

    deal(address(war), alice, 100e18);
    vm.prank(alice);
    war.approve(address(staker), type(uint256).max);
  }
}
