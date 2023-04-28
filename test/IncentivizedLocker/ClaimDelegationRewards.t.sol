// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {DelegationAddressTest} from "./IncentivizedLockerTest.sol";
import "src/IncentivizedLocker.sol";

contract ClaimDelegationRewards is DelegationAddressTest {
  error MerkleRootNotUpdated();
  error AlreadyClaimed();
  error InvalidProof();

  function testDefaultBehavior() public {
    // https://etherscan.io/tx/0x869e684381f31a6282779a453bbc4e89352f7c4400890d29747108a5ccf5ce70

    IncentivizedLocker l = deployLockerAt(0xE5350E927B904FdB4d2AF55C566E269BB3df1941);

    address distributor = 0x997523eF97E0b0a5625Ed2C197e61250acF4e5F1;

    bytes32[] memory merkleProof = new bytes32[](6);

    merkleProof[0] = 0x233fffcbf36f6a60940eeb592e014bc010bf4c6840d44c46501f83ba83a0ddad;
    merkleProof[1] = 0x41ad1401f6c3565a457a29eca32a74755af62ff76b04c6a4235a2024e25763df;
    merkleProof[2] = 0x8550195b76c891207a234e6c014211abe45fc1b2570682c8d4ba60115d3ea6a7;
    merkleProof[3] = 0xd595e25a38b5cefe42176bf8dc4a0222ef74cbefadc87e4645e2c96e67d9da17;
    merkleProof[4] = 0xabb841d75c678d2efcda826777a884fb041ed1fe36c73f9ae6fd06adfd9bd7cf;
    merkleProof[5] = 0x54cdb8674a8dbbd959dfa0543f3acc52f8e94657a4214e708d7b070bd9971412;

    vm.prank(controller);
    l.claimDelegationRewards(
      distributor,
      0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, // token
      29, // index
      0xE5350E927B904FdB4d2AF55C566E269BB3df1941, // account
      8_810_896_435, // amount
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
    dummyLocker.claimDelegationRewards(distributor, token, index, account, amount, merkleProof);
  }
}
