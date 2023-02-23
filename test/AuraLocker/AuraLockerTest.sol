// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../../src/AuraLocker.sol";
import "../../src/Token.sol";
import "../../src/Minter.sol";
import "../../src/MintRatio.sol";
import "../mocks/MockRedeemModule.sol";
import "../MainnetTest.sol";
import "interfaces/external/IDelegateRegistry.sol";

contract AuraLockerTest is MainnetTest {
  WarAuraLocker locker;
  address delegatee = makeAddr("delegatee");
  address controller = makeAddr("controller");
  WarMinter minter;
  WarToken war;
  WarMintRatio mintRatio;
  MockRedeem redeemModule;
  IDelegateRegistry registry = IDelegateRegistry(0x469788fE6E9E9681C6ebF3bF78e7Fd26Fc015446);

  using SafeERC20 for IERC20;

  function setUp() public virtual override {
    MainnetTest.setUp();
    fork();

    war = new WarToken();
    mintRatio = new WarMintRatio();
    minter = new WarMinter(address(war), address(mintRatio));

    redeemModule = new MockRedeem();
    vm.prank(admin);
    locker = new WarAuraLocker(controller, address(redeemModule), address(minter), delegatee);

    deal(address(aura), address(minter), 1e30);

    vm.startPrank(address(minter));
    aura.approve(address(locker), type(uint256).max);
    vm.stopPrank();
  }

  function _getRewards() internal view returns (uint256 cvxCrvRewards, uint256 cvxFxsRewards) {
    /* CvxLockerV2.EarnedData[] memory rewards = vlCvx.claimableRewards(address(locker));
    cvxCrvRewards = rewards[0].amount;
    cvxFxsRewards = rewards[1].amount; */
  }

  function _assertNoPendingRewards() internal {
    (uint256 cvxCrvRewards, uint256 cvxFxsRewards) = _getRewards();
    assertEq(cvxCrvRewards, 0);
    assertEq(cvxFxsRewards, 0);
  }
}
