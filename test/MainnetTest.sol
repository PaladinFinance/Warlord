// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./BaseTest.sol";
import "interfaces/external/convex/vlCvx.sol";
import "interfaces/external/aura/vlAura.sol";
import "interfaces/external/aura/AuraDepositor.sol";
import "interfaces/external/WETH.sol";
import {CvxCrvStaking} from "interfaces/external/convex/CvxCrvStaking.sol";
import {CrvDepositor} from "interfaces/external/convex/CrvDepositor.sol";
import {BaseRewardPool} from "interfaces/external/aura/AuraBalStaker.sol";

contract MainnetTest is BaseTest {
  uint256 constant CVX_MAX_SUPPLY = 100_000_000e18;
  uint256 constant AURA_MAX_SUPPLY = 100_000_000e18;

  uint256 constant CVX_MINT_RATIO = 1e18;
  uint256 constant AURA_MINT_RATIO = 0.5e18;

  WETH9 constant weth = WETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);


  // Curve
  IERC20 constant crv = IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);
  IERC20 constant threeCrv = IERC20(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);

  // Balancer
  IERC20 constant bal = IERC20(0xba100000625a3754423978a60c9317c58a424e3D);
  IERC20 constant bbAUsd = IERC20(0xA13a9247ea42D743238089903570127DdA72fE44);

  // Convex
  // - Cvx contracts
  IERC20 constant cvx = IERC20(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
  CvxLockerV2 constant vlCvx = CvxLockerV2(0x72a19342e8F1838460eBFCCEf09F6585e32db86E);
  // - cvxCRV contracts
  CrvDepositor private constant crvDepositor = CrvDepositor(0x8014595F2AB54cD7c604B00E9fb932176fDc86Ae);
  IERC20 constant cvxCrv = IERC20(0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7);
  CvxCrvStaking constant convexCvxCrvStaker = CvxCrvStaking(0xaa0C3f5F7DFD688C6E646F66CD2a6B66ACdbE434);
  // - cvxFXS
  IERC20 constant fxs = IERC20(0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0);
  IERC20 constant cvxFxs = IERC20(0xFEEf77d3f69374f66429C91d732A244f074bdf74);

  // Aura
  // - Aura contracts
  IERC20 constant aura = IERC20(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);
  AuraLocker constant vlAura = AuraLocker(0x3Fa73f1E5d8A792C80F426fc8F84FBF7Ce9bBCAC);
  // - AuraBal contracts
  CrvDepositorWrapper constant balDepositor = CrvDepositorWrapper(0x68655AD9852a99C87C0934c7290BB62CFa5D4123);
  IERC20 constant auraBal = IERC20(0x616e8BfA43F920657B3497DBf40D6b1A02D4608d);
  BaseRewardPool constant auraBalStaker = BaseRewardPool(0x00A7BA8Ae7bca0B10A32Ea1f8e2a1Da980c6CAd2);

  // Paladin
  IERC20 constant pal = IERC20(0xAB846Fb6C81370327e784Ae7CbB6d6a6af6Ff4BF);
  IERC20 constant hPal = IERC20(0x624D822934e87D3534E435b83ff5C19769Efd9f6);

  function setUp() public virtual {
    vm.label(address(crv), "crv");
    vm.label(address(cvx), "cvx");
    vm.label(address(cvxCrv), "cvxCrv");
    vm.label(address(cvxFxs), "cvxFxs");
    vm.label(address(fxs), "fxs");

    vm.label(address(bal), "bal");
    vm.label(address(aura), "aura");
    vm.label(address(auraBal), "auraBal");

    vm.label(address(vlCvx), "vlCvx");
    vm.label(address(convexCvxCrvStaker), "convexCvxCrvStaker");

    vm.label(address(vlAura), "vlAura");
    vm.label(address(balDepositor), "balDepositor");
    vm.label(address(auraBalStaker), "auraBalStaker");

    vm.label(address(threeCrv), "3Crv");
    vm.label(address(bbAUsd), "bbAUsd");

    vm.label(address(weth), "weth");
    vm.label(address(pal), "pal");
  }

  function fork() public {
    vm.createSelectFork(vm.rpcUrl("ethereum_alchemy"), 16_791_458);
  }

  function randomVlToken(uint256 seed) public pure returns (address token) {
    token = randomBinaryAddress(address(cvx), address(aura), seed);
  }

  function randomFarmableToken(uint256 seed) public pure returns (address token) {
    token = randomBinaryAddress(address(cvxCrv), address(auraBal), seed);
  }
}
