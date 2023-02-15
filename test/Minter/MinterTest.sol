// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../../src/Token.sol";
import "../../src/Minter.sol";
import "../MainnetTest.sol";
import {IWarLocker} from "interfaces/IWarLocker.sol";
import {vlMockLocker} from "mocks/vlMockLocker.sol";
import {MockMintRatio} from "mocks/MockMintRatio.sol";

contract MinterTest is MainnetTest {
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
    mintRatio = new MockMintRatio();
    MockMintRatio(address(mintRatio)).init();
    minter = new WarMinter(address(war), address(mintRatio));
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
