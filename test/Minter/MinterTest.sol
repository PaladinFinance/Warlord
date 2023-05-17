// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "src/Token.sol";
import "src/Minter.sol";
import "../MainnetTest.sol";
import {IWarLocker} from "interfaces/IWarLocker.sol";
import {WarRatios} from "src/Ratios.sol";
import {WarCvxLocker} from "src/CvxLocker.sol";

contract DummyLocker is IWarLocker {
  address _token;

  constructor(address token_) {
    _token = token_;
  }

  function token() external view returns (address) {
    return _token;
  }

  function lock(uint256 amount) external {}
  function harvest() external {}

  function rewardTokens() external pure returns (address[] memory) {
    address[] memory tokens = new address[](1);
    return tokens;
  }

  function getCurrentLockedTokens() external pure override returns (uint256) {
    return 324089;
  }
}

contract MinterTest is MainnetTest {
  uint256 constant cvxMaxSupply = 100_000_000e18;
  uint256 constant auraMaxSupply = 100_000_000e18;

  WarToken war;
  WarMinter minter;
  IWarLocker auraLocker;
  IWarLocker cvxLocker;
  IRatios ratios;

  event MintRatioUpdated(address oldMintRatio, address newMintRatio);

  function setUp() public override {
    MainnetTest.setUp();
    fork();

    vm.prank(admin);
    war = new WarToken();
    auraLocker = new DummyLocker(address(aura));
    cvxLocker = new DummyLocker(address(cvx));

    // Mint ratio set up
    ratios = new WarRatios();
    ratios.addTokenWithSupply(address(cvx), cvxMaxSupply);
    ratios.addTokenWithSupply(address(aura), auraMaxSupply);

    minter = new WarMinter(address(war), address(ratios));
    minter.transferOwnership(admin);
    vm.prank(admin);
    minter.acceptOwnership();

    vm.startPrank(admin);
    war.grantRole(keccak256("MINTER_ROLE"), address(minter));
    minter.setLocker(address(cvx), address(cvxLocker));
    minter.setLocker(address(aura), address(auraLocker));
    vm.stopPrank();

    deal(address(cvx), alice, 100e18);
    deal(address(aura), alice, 100e18);

    vm.startPrank(alice);
    cvx.approve(address(minter), 100e18);
    aura.approve(address(minter), 100e18);
    vm.stopPrank();
  }
}
