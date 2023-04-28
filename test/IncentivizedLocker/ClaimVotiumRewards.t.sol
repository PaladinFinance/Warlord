// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {VotiumTest} from "./IncentivizedLockerTest.sol";
import "src/IncentivizedLocker.sol";

contract ClaimQuestRewards is VotiumTest {
  error MerkleRootNotUpdated();
  error AlreadyClaimed();
  error InvalidProof();

  function testDefaultBehavior() public {
    // https://etherscan.io/tx/0x69748ad386d6455d1c0c2d1fa0f63ca1c025b0c2787f0911ac032f93250dc52e

    IncentivizedLocker l = deployLockerAt(0x58375A7A1A718d97faFB80C3E142cD64a4C4a8EA);

    address distributor = 0x378Ba9B73309bE80BF4C2c027aAD799766a7ED5A;

    bytes32[] memory merkleProof = new bytes32[](12);

    merkleProof[0] = 0x865f6040e06fc6445d600accd706c381626961622b2ab2c4269158bed1d4a659;
    merkleProof[1] = 0x951e751ecc5250d1bc872133b4838e5b34ef35b3880e7ffe0b7aa3c06874b54c;
    merkleProof[2] = 0x2b2dd7ba674866605cc5056722d84a0ae086e7aa99834634562340b89cb41cbe;
    merkleProof[3] = 0xb02867715dd3f9634541c8e3aae765d970b1c33679861950584006a1c8a5a625;
    merkleProof[4] = 0x4549654001637de8d82aebda0af5235ecc5160964aad4bb6975e4dc8a7cca015;
    merkleProof[5] = 0x8c3851dc149a80ed62b36b95448e03228d6abf5df0830b5aa7b76f6c4c971674;
    merkleProof[6] = 0x751359103adc4f26eab110686175ef1f8e950137b960d965f0bcc9ea744db808;
    merkleProof[7] = 0x0184d192c47f1b6ac73512cd8aebe09bb80f4ab351a869e4dcdb81ad877348a6;
    merkleProof[8] = 0xa60615887ce64bd31d2438153ddf8707e220932b6468734c51f52401a9cf671f;
    merkleProof[9] = 0xb5697c5490e167f1f07aa9bff4b9b154a88088dbd02f2d1f7deaf61d28e29ad2;
    merkleProof[10] = 0x9953204d68c8d7091c030cf6b2cc484febd0a4e3770d1ee7c06e6bcc1023151a;
    merkleProof[11] = 0x0ac3cce0bde11701cda41a4c977959a71d3aa1d170aeb281bf731d03184b38bc;

    vm.prank(controller);
    l.claimVotiumRewards(
      distributor,
      0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0, // token
      1185, // index
      0x58375A7A1A718d97faFB80C3E142cD64a4C4a8EA, // account
      8_748_599_481_841_859_584, // amount
      merkleProof
    );
  }

  function testOnlyController(
    address distributor,
    address token,
    uint256 index,
    address account,
    uint256 amount,
    bytes32[] calldata merkleProof
  ) public {
    vm.expectRevert(Errors.CallerNotAllowed.selector);
    dummyLocker.claimVotiumRewards(distributor, token, index, account, amount, merkleProof);
  }
}
