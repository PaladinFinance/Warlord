// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ControllerTest.sol";

contract Harvest is UnexposedControllerTest {
  function testHarvestAuraBal() public {
      // Solidity is just amazing
      // https://github.com/ethereum/solidity/issues/3556
      bytes4 getReward = hex"7050ccd9";
      vm.expectCall(address(auraBalStaker), abi.encodeWithSelector(getReward, address(auraBalFarmer), true), 1);
      controller.harvest(address(auraBalFarmer));
  }

  function testHarvestCvxCrv() public {
      bytes4 getReward = hex"6b091695";
      vm.expectCall(address(convexCvxCrvStaker), abi.encodeWithSelector(getReward, address(cvxCrvFarmer), address(controller)), 1);
      controller.harvest(address(cvxCrvFarmer));
  }

  function testHarvestVlCvx() public {
      bytes4 getReward = hex"7050ccd9";
      vm.expectCall(address(vlCvx), abi.encodeWithSelector(getReward, address(cvxLocker), false), 1);
      controller.harvest(address(cvxLocker));
  }

  function testHarvestVlAura() public {
      bytes4 getReward = hex"7050ccd9";
      vm.expectCall(address(vlAura), abi.encodeWithSelector(getReward, address(auraLocker), false), 1);
      controller.harvest(address(auraLocker));
  }

  function testWhenNotPaused(address token) public {
    vm.prank(admin);
    controller.pause();

    vm.expectRevert("Pausable: paused");
    controller.harvest(token);
  }
}
