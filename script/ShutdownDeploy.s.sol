// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "forge-std/Script.sol";

import {ShutdownMigrator} from "src/shutdown/ShutdownMigrator.sol";
import {ShutdownRedeemer} from "src/shutdown/ShutdownRedeemer.sol";
import {WarShutdownController} from "src/shutdown/ShutdownController.sol";

contract DeploymentShutdown is Script {
    ShutdownMigrator migrator;
    ShutdownRedeemer redeemer;
    //WarShutdownController controller;

    function run() external {
        uint256 deployerPrivateKey = uint256(vm.envBytes32("PRIVATE_KEY"));

        vm.startBroadcast(deployerPrivateKey);

        migrator = new ShutdownMigrator(
            0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B, // cvxToken
            0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF, // auraToken
            0x700d6d24A55512c6AEC08820B49da4e4193105B3, // cvxLocker
            0x7B90e043aaC79AdeA0Dbb0690E3c832757207a3B // auraLocker
        );
        redeemer = new ShutdownRedeemer(
            0xa8258deE2a677874a48F5320670A869D74f0cbC1, // war
            0x8C1D862c1FA91E0880dEEf621C7A17f9087Bf50C, // ratios
            0x44E133b1f4a1C521c9E360e9f2eCEa6518564deD, // feeReceiver
            address(migrator) // migrator
        );
        /*controller = new WarShutdownController(
            0xa8258deE2a677874a48F5320670A869D74f0cbC1, // war token
            0x144a689A8261F1863c89954930ecae46Bd950341, // minter
            0xA86c53AF3aadF20bE5d7a8136ACfdbC4B074758A, // staker
            0x44E133b1f4a1C521c9E360e9f2eCEa6518564deD, // manager
            0x1Ae6DCBc88d6f81A7BCFcCC7198397D776F3592E  // fee Receiver
        );*/

        redeemer.setLocker(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B, 0x700d6d24A55512c6AEC08820B49da4e4193105B3);
        redeemer.setLocker(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF, 0x7B90e043aaC79AdeA0Dbb0690E3c832757207a3B);

        migrator.setRedeemer(address(redeemer));

        migrator.transferOwnership(0x0792dCb7080466e4Bbc678Bdb873FE7D969832B8);
        redeemer.transferOwnership(0x0792dCb7080466e4Bbc678Bdb873FE7D969832B8);

        vm.stopBroadcast();
    }
}
