// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {DelegationAddressTest} from "./ControllerTest.sol";
import "src/IncentivizedLocker.sol";

contract ClaimDelegationRewards is DelegationAddressTest {
  function testDefaultBehavior() public {
    // https://etherscan.io/tx/0x869e684381f31a6282779a453bbc4e89352f7c4400890d29747108a5ccf5ce70

    IncentivizedLocker l = deployLockerAt(0xE5350E927B904FdB4d2AF55C566E269BB3df1941);

    address distributor = 0x997523eF97E0b0a5625Ed2C197e61250acF4e5F1;

    IDelegationDistributor.ClaimParams[] memory claimParams = new IDelegationDistributor.ClaimParams[](1);

    claimParams[0].merkleProof = new bytes32[](6);

    claimParams[0].merkleProof[0] = 0x233fffcbf36f6a60940eeb592e014bc010bf4c6840d44c46501f83ba83a0ddad;
    claimParams[0].merkleProof[1] = 0x41ad1401f6c3565a457a29eca32a74755af62ff76b04c6a4235a2024e25763df;
    claimParams[0].merkleProof[2] = 0x8550195b76c891207a234e6c014211abe45fc1b2570682c8d4ba60115d3ea6a7;
    claimParams[0].merkleProof[3] = 0xd595e25a38b5cefe42176bf8dc4a0222ef74cbefadc87e4645e2c96e67d9da17;
    claimParams[0].merkleProof[4] = 0xabb841d75c678d2efcda826777a884fb041ed1fe36c73f9ae6fd06adfd9bd7cf;
    claimParams[0].merkleProof[5] = 0x54cdb8674a8dbbd959dfa0543f3acc52f8e94657a4214e708d7b070bd9971412;

    claimParams[0].token = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    claimParams[0].index = 29;
    claimParams[0].amount = 8_810_896_435;

    vm.prank(incentivesClaimer);
    controller.claimDelegationRewards(address(l), distributor, claimParams);
  }

  function testWhenNotPaused(
    address locker,
    address distributor,
    IDelegationDistributor.ClaimParams[] memory claimParams
  ) public {
    vm.prank(admin);
    controller.pause();

    vm.expectRevert("Pausable: paused");
    controller.claimDelegationRewards(locker, distributor, claimParams);
  }

  function testOnlyIncentivesClaimer(
    address locker,
    address distributor,
    IDelegationDistributor.ClaimParams[] memory claimParams
  ) public {
    vm.expectRevert(Errors.CallerNotAllowed.selector);
    controller.claimDelegationRewards(locker, distributor, claimParams);
  }
}
