// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseTest.sol";
import "interfaces/external/vlCvx.sol";
import "interfaces/external/vlAura.sol";
import "interfaces/external/AuraDepositor.sol";

contract MainnetTest is BaseTest {
  // Curve
  ERC20 immutable crv = ERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);

  // Balancer
  ERC20 immutable bal = ERC20(0xba100000625a3754423978a60c9317c58a424e3D);

  // Convex
  ERC20 immutable cvx = ERC20(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
  CvxLockerV2 immutable vlCvx = CvxLockerV2(0x72a19342e8F1838460eBFCCEf09F6585e32db86E);
  ERC20 cvxCrv = ERC20(0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7);

  // Aura
  CrvDepositorWrapper auraDepositor = CrvDepositorWrapper(0x68655AD9852a99C87C0934c7290BB62CFa5D4123);
  ERC20 immutable aura = ERC20(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);
  AuraLocker immutable vlAura = AuraLocker(0x3Fa73f1E5d8A792C80F426fc8F84FBF7Ce9bBCAC);
  ERC20 immutable auraBal = ERC20(0x616e8BfA43F920657B3497DBf40D6b1A02D4608d);

  function setUp() public virtual {
    vm.label(address(cvx), "cvx");
    vm.label(address(aura), "aura");
  }

  function fork() public {
    vm.createSelectFork(vm.rpcUrl("mainnet"), 16_519_119);
  }
}
