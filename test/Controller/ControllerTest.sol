// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../WarlordTest.sol";
import "src/Token.sol";
import {WarStaker} from "src/Staker.sol";
import {WarRatios} from "src/Ratios.sol";
import {WarMinter} from "src/Minter.sol";
import "src/Controller.sol";

contract ControllerTest is WarlordTest {
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

  function setUp() public virtual override {
    WarlordTest.setUp();

    vm.startPrank(admin);
    controller =
    new Exposed_Controller(address(war), address(minter), address(staker), swapper, incentivesClaimer, protocolFeeReceiver);
    vm.stopPrank();
  }
}

contract Exposed_Controller is Controller {
  constructor(
    address _war,
    address _minter,
    address _staker,
    address _swapper,
    address _incentivesClaimer,
    address _feeReceiver
  ) Controller(_war, _minter, _staker, _swapper, _incentivesClaimer, _feeReceiver) {}

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
