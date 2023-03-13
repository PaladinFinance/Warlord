// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "../../src/Token.sol";
import {WarStaker} from "../../src/Staker.sol";
import {WarMintRatio} from "../../src/MintRatio.sol";
import {WarMinter} from "../../src/Minter.sol";
import "../../src/Controller.sol";

contract ControllerTest is MainnetTest {
  address swapper = makeAddr("swapper");
  address incentivesClaimer = makeAddr("incentivesClaimer");

  WarToken war;
  WarMintRatio mintRatio;
  WarMinter minter;
  WarStaker staker;
  Controller controller;

  function setUp() public virtual override {
    vm.startPrank(admin);

    war = new WarToken();
    mintRatio = new WarMintRatio();
    minter = new WarMinter(address(war), address(mintRatio));
    staker = new WarStaker(address(war));
    controller = new Controller(address(war), address(minter), address(staker), swapper, incentivesClaimer);

    vm.stopPrank();
  }
}
