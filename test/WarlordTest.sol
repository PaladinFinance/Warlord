// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./MainnetTest.sol";

// Token
import {WarToken} from "../src/Token.sol";

// Lockers
import {WarAuraLocker} from "../src/AuraLocker.sol";
import {WarCvxLocker} from "../src/CvxLocker.sol";

// Farmers
import {WarAuraBalFarmer} from "../src/AuraBalFarmer.sol";
import {WarCvxCrvFarmer} from "../src/CvxCrvFarmer.sol";

// Enter/Exit
import {WarMinter} from "../src/Minter.sol";
import {Redeemer} from "../src/Redeemer.sol";

// Infrastructure
import {Controller} from "../src/Controller.sol";
import {HolyPaladinDistributor} from "../src/Distributor.sol";
import {WarMintRatio} from "../src/MintRatio.sol";
import {WarStaker} from "../src/Staker.sol";

contract WarlordTest is MainnetTest {
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
  uint256 constant REDEMPTION_FEE = 500;

  // Token
  WarToken war;

  // Lockers
  WarAuraLocker auraLocker;
  WarCvxLocker cvxLocker;

  // Farmers
  WarAuraBalFarmer auraBalFarmer;
  WarCvxCrvFarmer cvxCrvFarmer;

  // Enter/Exit
  WarMinter minter;
  Redeemer redeemer;

  // Infrastracture
  Controller controller;
  HolyPaladinDistributor distributor;
  WarMintRatio mintRatio;
  WarStaker staker;

  function setUp() public virtual override {
    MainnetTest.setUp();
    fork();

    // Deploy the whole protocol
    vm.startPrank(admin);
    war = new WarToken();
    mintRatio = new WarMintRatio();
    minter = new WarMinter(address(war), address(mintRatio));
    redeemer = new Redeemer(address(war), address(mintRatio), redemptionFeeReceiver, REDEMPTION_FEE);
    staker = new WarStaker(address(war));
    controller =
      new Controller(address(war), address(minter), address(staker), swapper, incentivesClaimer, protocolFeeReceiver);
    auraLocker = new WarAuraLocker(address(controller), address(redeemer), address(minter), auraDelegate);
    cvxLocker = new WarCvxLocker(address(controller), address(redeemer), address(minter), cvxDelegate);

    // CVX mint config
    minter.setLocker(address(cvx), address(cvxLocker));
    mintRatio.addTokenWithSupply(address(cvx), CVX_MAX_SUPPLY);

    // AURA mint config
    minter.setLocker(address(aura), address(auraLocker));
    mintRatio.addTokenWithSupply(address(aura), AURA_MAX_SUPPLY);

    auraBalFarmer = new WarAuraBalFarmer(address(controller), address(staker));
    cvxCrvFarmer = new WarCvxCrvFarmer(address(controller), address(staker));

    // Config lockers
    controller.setLocker(address(aura), address(auraLocker));
    controller.setLocker(address(cvx), address(cvxLocker));

    // Config farmers
    controller.setFarmer(address(auraBal), address(auraLocker));
    controller.setFarmer(address(cvxCrv), address(cvxLocker));

    distributor = new HolyPaladinDistributor(address(hPal), address(war), distributionManager);

    vm.stopPrank();
  }
}
