// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "src/AuraBalFarmer.sol";
import {WarStaker} from "src/Staker.sol";
import "src/Token.sol";

// Useful to precompute the amount of aura that will be minted when harvesting rewards
interface IDeposit {
  function isShutdown() external view returns (bool);
  function balanceOf(address _account) external view returns (uint256);
  function totalSupply() external view returns (uint256);
  function poolInfo(uint256) external view returns (address, address, address, address, address, bool);
  function rewardClaimed(uint256, address, uint256) external;
  function withdrawTo(uint256, uint256, address) external;
  function claimRewards(uint256, address) external returns (bool);
  function rewardArbitrator() external returns (address);
  function setGaugeRedirect(uint256 _pid) external returns (bool);
  function owner() external returns (address);
  function deposit(uint256 _pid, uint256 _amount, bool _stake) external returns (bool);
  function getRewardMultipliers(address) external view returns (uint256);
  function minter() external view returns (address);
}

contract AuraBalFarmerTest is MainnetTest {
  address controller = makeAddr("controller");
  WarToken war;
  WarStaker warStaker;
  WarAuraBalFarmer auraBalFarmer;

  uint256 constant setUpBalBalance = 150_000e18;
  uint256 constant setUpAuraBalBalance = 150_000e18;

  event SetSlippage(uint256 oldSlippage, uint256 newSlippage);

  function setUp() public virtual override {
    MainnetTest.setUp();
    fork();

    vm.startPrank(admin);
    war = new WarToken();
    warStaker = new WarStaker(address(war));
    auraBalFarmer = new Exposed_WarAuraBalFarmer(controller, address(warStaker));
    vm.stopPrank();

    // dealing around 1.5m dollars in bal
    deal(address(bal), controller, setUpBalBalance);
    deal(address(auraBal), controller, setUpAuraBalBalance);

    vm.startPrank(controller);
    bal.approve(address(auraBalFarmer), bal.balanceOf(controller));
    auraBal.approve(address(auraBalFarmer), auraBal.balanceOf(controller));
    vm.stopPrank();
  }

  function _getAuraRewards(uint256 _amount) internal view returns (uint256 amount) {
    /// From 0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF
    uint256 INIT_MINT_AMOUNT = 5e25;
    uint256 totalCliffs = 500;
    uint256 EMISSIONS_MAX_SUPPLY = 5e25;
    uint256 reductionPerCliff = EMISSIONS_MAX_SUPPLY / totalCliffs;
    // the infamous variable
    uint256 minterMinted = 0;

    uint256 emissionsMinted = aura.totalSupply() - INIT_MINT_AMOUNT - minterMinted;
    uint256 cliff = emissionsMinted / reductionPerCliff;

    if (cliff < totalCliffs) {
      uint256 reduction = ((totalCliffs - cliff) * 5 / 2) + 700;
      amount = _amount * reduction / totalCliffs;
      uint256 amtTillMax = EMISSIONS_MAX_SUPPLY - emissionsMinted;
      if (amount > amtTillMax) {
        amount = amtTillMax;
      }
    }
  }

  function _getRewards() internal view returns (uint256 balRewards, uint256 auraRewards, uint256 bbAUsdRewards) {
    balRewards = auraBalStaker.earned(address(auraBalFarmer));
    auraRewards = _getAuraRewards(balRewards);
    bbAUsdRewards = IRewards(auraBalStaker.extraRewards(0)).earned(address(auraBalFarmer));
  }

  function _assertNoPendingRewards() internal {
    (uint256 balRewards, uint256 auraRewards, uint256 bbAUsdRewards) = _getRewards();
    assertEq(balRewards, 0);
    assertEq(auraRewards, 0);
    assertEq(bbAUsdRewards, 0);
  }

  function expose(WarAuraBalFarmer farmer) public pure returns (Exposed_WarAuraBalFarmer) {
    return Exposed_WarAuraBalFarmer(address(farmer));
  }
}

contract Exposed_WarAuraBalFarmer is WarAuraBalFarmer {
  constructor(address _controller, address _warStaker) WarAuraBalFarmer(_controller, _warStaker) {}

  function e_isTokenSupported(address _token) public pure returns (bool) {
    return _isTokenSupported(_token);
  }

  function e_stake(address _token, uint256 _amount) public returns (uint256) {
    return _stake(_token, _amount);
  }

  function e_harvest() public {
    _harvest();
  }

  function e_stakedBalance() public view returns (uint256) {
    return _stakedBalance();
  }

  function e_sendTokens(address receiver, uint256 amount) public {
    _sendTokens(receiver, amount);
  }

  function e_migrate(address receiver) public {
    _migrate(receiver);
  }
}
