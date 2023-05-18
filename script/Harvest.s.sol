// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {WarController} from "src/Controller.sol";
import "forge-std/Script.sol";
import {MainnetTest} from "test/MainnetTest.sol";
import {WarStaker} from "src/Staker.sol";
import {WarToken} from "src/Token.sol";

contract Harvest is Script, MainnetTest {
  WarToken war;

  function run() public {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    vm.startBroadcast(deployerPrivateKey);

    string memory json = vm.readFile("./deployment_report.json");
    WarController controller = WarController(vm.parseJsonAddress(json, ".WarController"));
    
    // address deployer = 0x60e868ca88198664Ce10a1F5cf7F007b2811f283;
    // controller.setSwapper(deployer);
    // print(string.concat("bbAUsd ", vm.toString(bbAUsd.balanceOf(controller.swapper()))));


    // WarToken war = WarToken(vm.parseJsonAddress(json, ".WarToken"));
    // WarStaker stkWar = WarStaker(vm.parseJsonAddress(json, ".WarStaker"));
    // uint256 wethFromVlCvxDelegation = 93 * 1e17; // 0.05 usdc * 341 000 vlCvx = 17050 usdc ~= 9.3 ether
    // uint256 wethFromVlAuraDelegation = 35 * 1e17; // 0.04 usdc * 160 500 vlAura = 6420 usdc ~= 3.5 ether
    // uint256 wethRewards = wethFromVlCvxDelegation + wethFromVlAuraDelegation;
    // print(vm.toString(controller.swapperAmounts(address(weth))));
    // controller.setDistributionToken(address(war), true);
    // controller.setDistributionToken(address(weth), true);
    // controller.setDistributionToken(address(pal), true);
    // controller.setDistributionToken(address(cvxFxs), true);

    // weth.deposit{value: wethRewards}();
    // weth.transfer(address(controller), wethRewards);
    controller.process(address(cvx));
    controller.process(address(aura));

    // address[] memory 
    // controller.setFarmer(address(auraBal), address(auraBalFarmer));
    // controller.setFarmer(address(cvxCrv), address(cvxCrvFarmer));
    // print(vm.toString(cvxCrv.balanceOf(address(controller))));
    vm.stopBroadcast();
  }
}

