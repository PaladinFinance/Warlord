// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../MainnetTest.sol";
import "../../src/CvxCrvFarmer.sol";
import {WarStaker} from "../../src/Staker.sol";
import "../../src/Token.sol";

contract CvxCrvFarmerTest is MainnetTest {
  address controller = makeAddr("controller");
  WarToken war;
  WarStaker warStaker;
  WarCvxCrvFarmer cvxCrvFarmer; 

  function setUp() public virtual override {
    MainnetTest.setUp();
    fork();

    vm.startPrank(admin);
    war = new WarToken();
    warStaker = new WarStaker(address(war));
    cvxCrvFarmer = new WarCvxCrvFarmer(controller, address(warStaker));
    vm.stopPrank();

    // TODO deal bigger amounts
    deal(address(crv), controller, 100e18);
    deal(address(cvxCrv), controller, 100e18);

    vm.startPrank(controller);
    crv.approve(address(cvxCrvFarmer), crv.balanceOf(controller));
    cvxCrv.approve(address(cvxCrvFarmer), cvxCrv.balanceOf(controller));
    vm.stopPrank();
  }

  function _getRewards() internal returns (uint256 _crv, uint256 _cvx, uint256 _threeCrv) {
    CvxCrvStaking.EarnedData[] memory list = convexCvxCrvStaker.earned(address(cvxCrvFarmer));
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
}
