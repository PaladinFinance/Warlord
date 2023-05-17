// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "forge-std/Script.sol";
import "test/MainnetTest.sol";

// Token
import {WarToken} from "src/Token.sol";

// Lockers
import {WarAuraLocker} from "src/AuraLocker.sol";
import {WarCvxLocker} from "src/CvxLocker.sol";

// Farmers
import {WarAuraBalFarmer} from "src/AuraBalFarmer.sol";
import {WarCvxCrvFarmer} from "src/CvxCrvFarmer.sol";

// Enter/Exit
import {WarZap} from "src/Zap.sol";
import {WarMinter} from "src/Minter.sol";
import {WarRedeemer} from "src/Redeemer.sol";

// Infrastructure
import {WarController} from "src/Controller.sol";
import {HolyPaladinDistributor} from "src/Distributor.sol";
import {WarRatios} from "src/Ratios.sol";
import {WarRatiosV2} from "src/RatiosV2.sol";
import {WarStaker} from "src/Staker.sol";

contract Deployment is Script, MainnetTest {
  // WarToken roles
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

  // Delegation
  address auraDelegate = makeAddr("auraDelegate");
  address cvxDelegate = makeAddr("cvxDelegate");

  // Fees
  address redemptionFeeReceiver = makeAddr("redemptionFeeReceiver");
  address protocolFeeReceiver = makeAddr("protocolFeeReceiver");

  // Multisig/Protocol's admins
  address swapper = makeAddr("swapper");
  address incentivesClaimer = makeAddr("incentivesClaimer");
  address distributionManager = makeAddr("distributionManager");

  // Initial values
  uint256 constant REDEMPTION_FEE = 200;

  // Token
  WarToken war;

  // Lockers
  WarAuraLocker auraLocker;
  WarCvxLocker cvxLocker;

  // Farmers
  WarAuraBalFarmer auraBalFarmer;
  WarCvxCrvFarmer cvxCrvFarmer;

  // Enter/Exit
  WarZap zap;
  WarMinter minter;
  WarRedeemer redeemer;

  // Infrastracture
  WarController controller;
  HolyPaladinDistributor distributor;
  WarRatios ratios;
  WarRatiosV2 ratiosV2;
  WarStaker staker;

  function run() public {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    deploy();

    vm.stopBroadcast();
  }

  function deploy() public {
    war = new WarToken();
    ratios = new WarRatios();
    ratiosV2 = new WarRatiosV2();
    minter = new WarMinter(address(war), address(ratios));
    redeemer = new WarRedeemer(address(war), address(ratios), redemptionFeeReceiver, REDEMPTION_FEE);

    // Setting up permissions
    war.grantRole(MINTER_ROLE, address(minter));
    war.grantRole(BURNER_ROLE, address(redeemer));

    staker = new WarStaker(address(war));
    controller =
      new WarController(address(war), address(minter), address(staker), swapper, incentivesClaimer, protocolFeeReceiver);
    auraLocker = new WarAuraLocker(address(controller), address(redeemer), address(minter), auraDelegate);
    cvxLocker = new WarCvxLocker(address(controller), address(redeemer), address(minter), cvxDelegate);

    // CVX mint config
    minter.setLocker(address(cvx), address(cvxLocker));
    ratios.addTokenWithSupply(address(cvx), CVX_MAX_SUPPLY);
    ratiosV2.addTokenWithSupply(address(cvx), CVX_MINT_RATIO);

    // AURA mint config
    minter.setLocker(address(aura), address(auraLocker));
    ratios.addTokenWithSupply(address(aura), AURA_MAX_SUPPLY);
    ratiosV2.addTokenWithSupply(address(aura), AURA_MINT_RATIO);

    auraBalFarmer = new WarAuraBalFarmer(address(controller), address(staker));
    cvxCrvFarmer = new WarCvxCrvFarmer(address(controller), address(staker));

    // Controller config
    controller.setLocker(address(aura), address(auraLocker));
    controller.setLocker(address(cvx), address(cvxLocker));

    controller.setFarmer(address(auraBal), address(auraBalFarmer));
    controller.setFarmer(address(cvxCrv), address(cvxCrvFarmer));

    controller.setDistributionToken(address(war), true);
    controller.setDistributionToken(address(weth), true);
    controller.setDistributionToken(address(pal), true);
    controller.setDistributionToken(address(cvxFxs), true);

    // Redeemer config
    redeemer.setLocker(address(aura), address(auraLocker));
    redeemer.setLocker(address(cvx), address(cvxLocker));

    // Staker config
    staker.setRewardFarmer(address(cvxCrv), address(cvxCrvFarmer));
    staker.setRewardFarmer(address(auraBal), address(auraBalFarmer));

    staker.addRewardDepositor(address(controller));
    staker.addRewardDepositor(swapper);

    // Harvestable config
    auraBalFarmer.addReward(address(aura));
    auraBalFarmer.addReward(address(bbAUsd));
    auraBalFarmer.addReward(address(bal));

    cvxCrvFarmer.addReward(address(crv));
    cvxCrvFarmer.addReward(address(threeCrv));
    cvxCrvFarmer.addReward(address(cvx));

    cvxLocker.addReward(address(cvxCrv));
    cvxLocker.addReward(address(cvxFxs));
    cvxLocker.addReward(address(fxs));

    auraLocker.addReward(address(auraBal));

    // Zap
    zap = new WarZap(address(minter), address(staker), address(war));
  }
}
