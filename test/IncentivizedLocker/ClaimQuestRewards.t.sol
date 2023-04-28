// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./IncentivizedLockerTest.sol";

contract ClaimQuestRewards is IncentivizedLockerTest {
  error MerkleRootNotUpdated();
  error AlreadyClaimed();
  error InvalidProof();

  function testDefaultBehavior() public {
    // The goal of this test is to simulate this transaction
    // by pretending that the contract is the claimer
    // https://etherscan.io/tx/0x69748ad386d6455d1c0c2d1fa0f63ca1c025b0c2787f0911ac032f93250dc52e
    vm.roll(16_852_914);
    vm.warp(1_679_121_539);

    IncentivizedLocker l = deployLockerAt(address(0x387ACB7f56A6f29137a21d7Eb755A3F638cab45B));

    address distributor = 0xce6dc32252d85e2e955Bfd3b85660917F040a933;

    bytes32[] memory merkleProof = new bytes32[](7);

    merkleProof[0] = 0x2d1b692efadf2bb31414dc265cc22593c293c4b3f37f3f8f7326c324c0c278ef;
    merkleProof[1] = 0x5e0521e702c24cf6c9a4cb8ff4f637d247e3cb64fa156e882a1610aec18fc4b5;
    merkleProof[2] = 0xec20353b89cf572e84ad420b82d5c92c9f6cb44c33f1fe920b438f765fb6a8ad;
    merkleProof[3] = 0x195fef060d7ff23e94107969d34d237d5010b132d9622be921ee3f092587d256;
    merkleProof[4] = 0x83eefef2c7b3b2a79d81a8bcaa1e20e501ef9cb050d28d289f82c0d3f7f78690;
    merkleProof[5] = 0x6932185c40c92cbc9fcd8ecd135c24e052933c955831935d9be6861f75228581;
    merkleProof[6] = 0xe7bec982a6f472ed8a4f23dc8c04f591464d8b26a8f9c92551248c17de579dae;

    vm.prank(controller);
    l.claimQuestRewards(
      distributor,
      11, // quest id
      1_678_320_000, // period
      78, // index
      0x387ACB7f56A6f29137a21d7Eb755A3F638cab45B, // account
      1_284_345_628_780_223_838_366, // amount
      merkleProof
    );
  }

  function testOnlyController(
    address distributor,
    uint256 questID,
    uint256 period,
    uint256 index,
    address account,
    uint256 amount,
    bytes32[] calldata merkleProof
  ) public {
    vm.expectRevert(Errors.CallerNotAllowed.selector);
    dummyLocker.claimQuestRewards(distributor, questID, period, index, account, amount, merkleProof);
  }
}
