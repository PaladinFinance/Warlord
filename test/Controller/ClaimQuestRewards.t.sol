// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {QuestTest} from "./ControllerTest.sol";
import "src/IncentivizedLocker.sol";

contract ClaimDelegationRewards is QuestTest {
  function testDefaultBehavior() public {
    // https://etherscan.io/tx/0x69748ad386d6455d1c0c2d1fa0f63ca1c025b0c2787f0911ac032f93250dc52e

    IncentivizedLocker l = deployLockerAt(0x387ACB7f56A6f29137a21d7Eb755A3F638cab45B);

    address distributor = 0xce6dc32252d85e2e955Bfd3b85660917F040a933;

    IQuestDistributor.ClaimParams[] memory claimParams = new IQuestDistributor.ClaimParams[](1);

    claimParams[0].questID = 11;
    claimParams[0].period = 1_678_320_000;
    claimParams[0].index = 78;
    claimParams[0].amount = 1_284_345_628_780_223_838_366;
    claimParams[0].merkleProof = new bytes32[](7);

    claimParams[0].merkleProof[0] = 0x2d1b692efadf2bb31414dc265cc22593c293c4b3f37f3f8f7326c324c0c278ef;
    claimParams[0].merkleProof[1] = 0x5e0521e702c24cf6c9a4cb8ff4f637d247e3cb64fa156e882a1610aec18fc4b5;
    claimParams[0].merkleProof[2] = 0xec20353b89cf572e84ad420b82d5c92c9f6cb44c33f1fe920b438f765fb6a8ad;
    claimParams[0].merkleProof[3] = 0x195fef060d7ff23e94107969d34d237d5010b132d9622be921ee3f092587d256;
    claimParams[0].merkleProof[4] = 0x83eefef2c7b3b2a79d81a8bcaa1e20e501ef9cb050d28d289f82c0d3f7f78690;
    claimParams[0].merkleProof[5] = 0x6932185c40c92cbc9fcd8ecd135c24e052933c955831935d9be6861f75228581;
    claimParams[0].merkleProof[6] = 0xe7bec982a6f472ed8a4f23dc8c04f591464d8b26a8f9c92551248c17de579dae;

    vm.prank(incentivesClaimer);
    controller.claimQuestRewards(address(l), distributor, claimParams);
  }

  function testWhenNotPaused(address locker, address distributor, IQuestDistributor.ClaimParams[] memory claimParams)
    public
  {
    vm.prank(admin);
    controller.pause();

    vm.expectRevert("Pausable: paused");
    controller.claimQuestRewards(locker, distributor, claimParams);
  }

  function testOnlyIncentivesClaimer(
    address locker,
    address distributor,
    IQuestDistributor.ClaimParams[] memory claimParams
  ) public {
    vm.expectRevert(Errors.CallerNotAllowed.selector);
    controller.claimQuestRewards(locker, distributor, claimParams);
  }
}
