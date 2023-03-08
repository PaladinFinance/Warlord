// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "../../src/BaseFarmer.sol";
import {WarStaker} from "../../src/Staker.sol";
import "../../src/Token.sol";

contract BaseFarmerTest is MainnetTest {
  address controller = makeAddr("controller");
  WarToken war;
  WarStaker warStaker;
  WarBaseFarmer dummyFarmer;

  event SetController(address controller);
  event SetWarStaker(address warStaker);
  event Staked(uint256 amount);

  function setUp() public virtual override {
    MainnetTest.setUp();
    fork();

    vm.startPrank(admin);
    war = new WarToken();
    warStaker = new WarStaker(address(war));
    dummyFarmer = new WarDummyFarmer(controller, address(warStaker));
    vm.stopPrank();
  }
}

contract WarDummyFarmer is WarBaseFarmer {
  constructor(address _controller, address _warStaker) WarBaseFarmer(_controller, _warStaker) {}

  function _stake(address, /* _token*/ uint256 /*_amount*/ ) internal pure override returns (uint256) {
    return 0;
  }

  function _harvest() internal pure override {}
  function _sendTokens(address receiver, uint256 amount) internal pure override {}
  function _migrate(address receiver) internal pure override {}
  function token() external view returns (address) {}

  function rewardTokens() external pure returns (address[] memory) {
    address[] memory tokens = new address[](1);
    return tokens;
  }

  function _isTokenSupported(address /*_token*/ ) internal pure override returns (bool) {
    return true;
  }

  function _stakedBalance() internal override returns (uint256) {}
}
