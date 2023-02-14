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

  function setUp() public virtual override {
    MainnetTest.setUp();
    fork();

    vm.startPrank(admin);
    war = new WarToken();
    warStaker = new WarStaker(address(war));
    warAuraBalFarmer = new WarAuraBalFarmer(controller, address(warStaker));
    vm.stopPrank();

    deal(address(bal), controller, 100e18);
    deal(address(auraBal), controller, 100e18);

    vm.startPrank(controller);
    bal.approve(address(warAuraBalFarmer), bal.balanceOf(controller));
    auraBal.approve(address(warAuraBalFarmer), auraBal.balanceOf(controller));
    vm.stopPrank();
  }

  /*
  function _getRewards() internal returns (uint256 _crv, uint256 _cvx, uint256 _threeCrv) {
    CvxCrvStaking.EarnedData[] memory list = convexCvxCrvStaker.earned(address(warCvxCrvFarmer));
    _crv = list[0].amount;
    _cvx = list[1].amount;
    _threeCrv = list[2].amount;
  }

  function _assertNoPendingRewards() internal {
    (uint256 crvRewards, uint256 cvxRewards, uint256 threeCrvRewards) = _getRewards();
    assertEq(crvRewards, 0);
    assertEq(cvxRewards, 0);
    assertEq(threeCrvRewards, 0);
  }
  */
}
