// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "../../src/WarAuraBalFarmer.sol";
import {WarStaker} from "../../src/WarStaker.sol";
import "../../src/WarToken.sol";

contract WarAuraBalFarmerTest is MainnetTest {
  address controller = makeAddr("controller");
  WarToken war;
  WarStaker warStaker;
  WarAuraBalFarmer warAuraBalFarmer;

  event SetController(address controller);
  event SetWarStaker(address warStaker);
  event Staked(uint256 amount, uint256 index);

  function setUp() public virtual override {
    MainnetTest.setUp();
    fork();

    vm.startPrank(admin);
    war = new WarToken();
    warStaker = new WarStaker(address(war));
    warAuraBalFarmer = new WarAuraBalFarmer(controller, address(warStaker));
    vm.stopPrank();

    // dealing around 1.5m dollars in bal
    deal(address(bal), controller, 150_000e18);
    deal(address(auraBal), controller, 150_000e18);

    vm.startPrank(controller);
    bal.approve(address(warAuraBalFarmer), bal.balanceOf(controller));
    auraBal.approve(address(warAuraBalFarmer), auraBal.balanceOf(controller));
    vm.stopPrank();
  }

  function _getRewards() internal view returns (uint256 rewards) {
    // TODO something is wrong since multiple rewards
    rewards = auraBalStaker.earned(address(warAuraBalFarmer));
  }

  function _assertNoPendingRewards() internal {
    uint256 rewards = _getRewards();
    assertEq(rewards, 0);
  }
}
