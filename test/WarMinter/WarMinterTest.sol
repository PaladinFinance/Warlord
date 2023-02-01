// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../../src/WarToken.sol";
import "../../src/WarMinter.sol";
import "../MainnetTest.sol";
import {IWarLocker} from "interfaces/IWarLocker.sol";
import {vlMockLocker} from "mocks/vlMockLocker.sol";
import {MockMintRatio} from "mocks/MockMintRatio.sol";

contract WarMinterTest is MainnetTest {
  WarToken war;
  WarMinter minter;
  IWarLocker auraLocker;
  IWarLocker cvxLocker;
  IMintRatio mintRatio;
  address admin = makeAddr("admin");

  function setUp() public override {
    MainnetTest.setUp();
    fork();

    war = new WarToken(admin);
    auraLocker = new vlMockLocker(address(aura)); // TODO repalce with non mock implementation in due time
    cvxLocker = new vlMockLocker(address(cvx)); // TODO repalce with non mock implementation in due time
    minter = new WarMinter(address(war));
    minter.transferOwnership(admin);
    vm.prank(admin);
    minter.acceptOwnership();

    mintRatio = new MockMintRatio(); // TODO repalce with non mock implementation in due time
    MockMintRatio(address(mintRatio)).init();
    vm.prank(admin);
    minter.setMintRatio(address(mintRatio));

    vm.startPrank(admin);
    war.grantRole(keccak256("MINTER_ROLE"), address(minter));
    minter.setLocker(address(cvx), address(cvxLocker));
    minter.setLocker(address(aura), address(auraLocker));
    vm.stopPrank();

    deal(address(cvx), alice, 100 ether);
    deal(address(aura), alice, 100 ether);

    vm.startPrank(alice);
    cvx.approve(address(minter), 100 ether);
    aura.approve(address(minter), 100 ether);
    vm.stopPrank();
  }
}
