// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../../src/Token.sol";
import "../../src/Minter.sol";
import "../MainnetTest.sol";
import {IWarLocker} from "interfaces/IWarLocker.sol";
import {vlMockLocker} from "mocks/vlMockLocker.sol";
import {WarMintRatio} from "../../src/MintRatio.sol";

contract MinterTest is MainnetTest {
  uint256 constant cvxMaxSupply = 100_000_000e18;
  uint256 constant auraMaxSupply = 100_000_000e18;

  WarToken war;
  WarMinter minter;
  IWarLocker auraLocker;
  IWarLocker cvxLocker;
  IMintRatio mintRatio;

  function setUp() public override {
    MainnetTest.setUp();
    fork();

    vm.prank(admin);
    war = new WarToken();
    auraLocker = new vlMockLocker(address(aura));
    cvxLocker = new vlMockLocker(address(cvx));

    // Mint ratio set up
    mintRatio = new WarMintRatio();
    mintRatio.addTokenWithSupply(address(cvx), cvxMaxSupply);
    mintRatio.addTokenWithSupply(address(aura), auraMaxSupply);

    minter = new WarMinter(address(war), address(mintRatio));
    minter.transferOwnership(admin);
    vm.prank(admin);
    minter.acceptOwnership();

    vm.startPrank(admin);
    war.grantRole(keccak256("MINTER_ROLE"), address(minter));
    minter.setLocker(address(cvx), address(cvxLocker));
    minter.setLocker(address(aura), address(auraLocker));
    vm.stopPrank();

    deal(address(cvx), alice, 100e18); // TODO always deal max supply in this kind of tests
    deal(address(aura), alice, 100e18);

    vm.startPrank(alice);
    cvx.approve(address(minter), 100e18);
    aura.approve(address(minter), 100e18);
    vm.stopPrank();
  }
}
