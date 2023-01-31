// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../../src/WarToken.sol";
import "../../src/WarMinter.sol";
import "../MainnetTest.sol";
import {vlTokenLocker} from "interfaces/vlTokenLocker.sol";
import {vlMockLocker} from "../../src/vlMockLocker.sol";

contract WarTokenTest is MainnetTest {
  WarToken war;
  WarMinter minter;
  vlTokenLocker auraLocker;
  vlTokenLocker cvxLocker;
  address admin = makeAddr("admin");

  function setUp() public {
    war = new WarToken(admin);
    auraLocker = new vlMockLocker(address(aura));
    cvxLocker = new vlMockLocker(address(cvx));
    minter = new WarMinter(address(war), address(cvxLocker), address(auraLocker));
    war.grantRole(keccak256("MINTER_ROLE"), address(minter));
  }
}
