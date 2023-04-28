// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {HiddenHandTest} from "./IncentivizedLockerTest.sol";
import {IHiddenHandDistributor} from "interfaces/external/incentives/IIncentivesDistributors.sol";
import "src/IncentivizedLocker.sol";

contract ClaimHiddenHandRewards is HiddenHandTest {
  error MerkleRootNotUpdated();
  error AlreadyClaimed();
  error InvalidProof();

  function testDefaultBehavior() public {
    // https://etherscan.io/tx/0x69748ad386d6455d1c0c2d1fa0f63ca1c025b0c2787f0911ac032f93250dc52e

    IncentivizedLocker l = deployLockerAt(0x3A22107564513d257f79394C3E58eB8a0F54043C);

    address distributor = 0x0b139682D5C9Df3e735063f46Fb98c689540Cf3A;

    IHiddenHandDistributor.Claim[] memory claimParams = new IHiddenHandDistributor.Claim[](1);
    claimParams[0].merkleProof = new bytes32[](11);

    claimParams[0].merkleProof[0] = 0xcf9b4fc83d4082efc102c37f3f2e08655e660eeadeb0cda2ce326d2eedcaa934;
    claimParams[0].merkleProof[1] = 0x6598b4a6898d7c94c2db55c0e2f6c89b18116e4490de1dc7f996a04652766edc;
    claimParams[0].merkleProof[2] = 0x7c913d68ddce525652ab4ac5e8f7360eba9116046da75f7e02daffda27313c9c;
    claimParams[0].merkleProof[3] = 0x06c2ce0bdcb67eb4bc6c414c78d094cb9aa99f7e28c4be96a1c7ab35b7eaa76b;
    claimParams[0].merkleProof[4] = 0x0ca672a53a1fb1e8fadbc9d214f326f0360b003e810ce0609b7107baa2284565;
    claimParams[0].merkleProof[5] = 0xcc2502d705d0bd727eed5825a2b286b3b898f262bc58a12520c3e9766ceb616f;
    claimParams[0].merkleProof[6] = 0x77d1c62e7338a886204bea1861077ad43ed764bc2fb2c1a4d3326bb6a31ea2ac;
    claimParams[0].merkleProof[7] = 0x42bca385c587a99c6b19773d259d55e79210594809acbf0fb892724aa464d80b;
    claimParams[0].merkleProof[8] = 0xa17d664c961a7fb6e4da487f3b70389ec83609e3247d79f96e8862a31b370d70;
    claimParams[0].merkleProof[9] = 0x69980ec4b2600386e25a46b292de37779b25c9c5629dae807ff31678ab88abed;
    claimParams[0].merkleProof[10] = 0xa1b5de8f8be45db1236068006c4e9683279c3d0fab99c8fc31c447bf2133b2bc;

    claimParams[0].identifier = 0x8eee07e6aecfd58a059e9c795e092747309d76151e2ab9562faf60b2d64673fd;
    claimParams[0].account = 0x3A22107564513d257f79394C3E58eB8a0F54043C;
    claimParams[0].amount = 2_745_971_278_089_960_463_473;

    vm.prank(controller);
    l.claimHiddenHandRewards(distributor, claimParams);
  }
  /*
  function testOnlyController(
    address distributor,
    IHiddenHandDistributor.Claim[] calldata claimParams
  ) public {
    vm.assume(claimParams.length == 1);

    vm.expectRevert(Errors.CallerNotAllowed.selector);
    dummyLocker.claimHiddenHandRewards(distributor, claimParams);
  }

  function testWrongLength(
    address distributor,
    IHiddenHandDistributor.Claim[] calldata claimParams
  ) public {
    vm.assume(claimParams.length != 1);
    
    vm.expectRevert();

    vm.prank(controller);
    dummyLocker.claimHiddenHandRewards(distributor, claimParams);
  }
  */
}
