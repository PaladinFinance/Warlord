// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "../../src/Token.sol";
import {WarStaker} from "../../src/Staker.sol";
import {WarMintRatio} from "../../src/MintRatio.sol";
import {WarMinter} from "../../src/Minter.sol";
import "../../src/Controller.sol";

contract ControllerTest is MainnetTest {
  event PullTokens(address indexed swapper, address indexed token, uint256 amount);
  event SetMinter(address oldMinter, address newMinter);
  event SetStaker(address oldStaker, address newStaker);
  event SetSwapper(address oldSwapper, address newSwapper);
  event SetFeeReceiver(address oldFeeReceiver, address newFeeReceiver);
  event SetIncentivesClaimer(address oldIncentivesClaimer, address newIncentivesClaimer);
  event SetFeeRatio(uint256 oldFeeRatio, uint256 newFeeRatio);
  event SetLocker(address indexed token, address locker);
  event SetFarmer(address indexed token, address famer);
  event SetDistributionToken(address indexed token, bool distribution);

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
    controller = new Exposed_Controller(address(war), address(minter), address(staker), swapper, incentivesClaimer);

    vm.stopPrank();
  }
}

contract Exposed_Controller is Controller {
  constructor(address _war, address _minter, address _staker, address _swapper, address _incentivesClaimer)
    Controller(_war, _minter, _staker, _swapper, _incentivesClaimer)
  {}

  function getFarmersLength() public view returns (uint256) {
    return farmers.length;
  }

  function getLockersLength() public view returns (uint256) {
    return lockers.length;
  }
}

function expose(Controller c) pure returns (Exposed_Controller) {
  return Exposed_Controller(address(c));
}
