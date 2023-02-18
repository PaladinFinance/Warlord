// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../../src/CvxLocker.sol";
import "../../src/Token.sol";
import "../../src/Minter.sol";
import "../../src/MintRatio.sol";
import "../mocks/MockRedeemModule.sol";
import "../MainnetTest.sol";
import "interfaces/external/IDelegateRegistry.sol";

contract CvxLockerTest is MainnetTest {
  WarCvxLocker locker;
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
    locker = new WarCvxLocker(controller, address(redeemModule), address(minter), delegatee);

    deal(address(cvx), address(minter), 100e18);

    vm.startPrank(address(minter));
    cvx.approve(address(locker), cvx.balanceOf(address(minter)));
    vm.stopPrank();
  }
}
