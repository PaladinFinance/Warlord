// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {HiddenHandTest} from "./ControllerTest.sol";
import "src/IncentivizedLocker.sol";

contract ClaimDelegationRewards is HiddenHandTest {
  function testDefaultBehavior() public {
    // https://etherscan.io/tx/0xda4319f4f8f1da3c46a26073191c28017066c13309e38afcb28e7a7f0cf58371

    IncentivizedLocker l = deployLockerAt(0x43e49750A2Ac66dCE8D35bb4bE8Cbd458Dc91736);

    address distributor = 0x0b139682D5C9Df3e735063f46Fb98c689540Cf3A;

    IHiddenHandDistributor.Claim[] memory claimParams = new IHiddenHandDistributor.Claim[](1);
    claimParams[0].merkleProof = new bytes32[](11);

    claimParams[0].merkleProof[0] = 0x13b65923196b7070cde8629e79c15348a1547fc0b5f5d620ccc5ccd64aa39fae;
    claimParams[0].merkleProof[1] = 0xa1201ecf76fb9aa2ba060d106196adc10b5151bd489798972f1bc0f27e42a823;
    claimParams[0].merkleProof[2] = 0xbb75724834485ed056021643567a12ad91b4956ed037d15e38bdfa3fcdf87e23;
    claimParams[0].merkleProof[3] = 0xe799155e60287379f6720f59aa13c6c9bdfde8d4d997fc8b9e6876807b82f1de;
    claimParams[0].merkleProof[4] = 0xb8ba9253b589586d8aed5ce72734b62819a140e3683361d5d276aa356a3c20e3;
    claimParams[0].merkleProof[5] = 0x0a7b04c11ec4d69e7119f46b001c436c278e0b3f0c4dc3b2ccefcd7369d28d4e;
    claimParams[0].merkleProof[6] = 0x659bf9c67b3341fc65bae36b8c2c7c7fe22c0a2065e24ce3ecc2e20800d5fcb0;
    claimParams[0].merkleProof[7] = 0x9ffd460afbd4057e31e634715cad2e62d11402f437c73c761ef3cb34b910732a;
    claimParams[0].merkleProof[8] = 0xfd19484fe93e0c1d91330e33456d1de3e359c42004290bce6022d8a43549412f;
    claimParams[0].merkleProof[9] = 0x3218a10e42653f25263e2ee265306bcf326dbc3550e57653bf177c2c7c63acb3;
    claimParams[0].merkleProof[10] = 0xa1b5de8f8be45db1236068006c4e9683279c3d0fab99c8fc31c447bf2133b2bc;

    claimParams[0].identifier = 0x8eee07e6aecfd58a059e9c795e092747309d76151e2ab9562faf60b2d64673fd;
    claimParams[0].account = 0x43e49750A2Ac66dCE8D35bb4bE8Cbd458Dc91736;
    claimParams[0].amount = 49_974_316_119_848_575_671;

    vm.prank(incentivesClaimer);
    controller.claimHiddenHandRewards(address(l), distributor, claimParams);
  }

  // TODO
  function testWhenNotPaused() public {}
  function testOnlyIncentivesClaimer() public {}
}
