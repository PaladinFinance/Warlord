// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../WarlordTest.sol";
import {DummyLocker} from "../Minter/MinterTest.sol";

contract RedeemerTest is WarlordTest {
  address _minter = makeAddr("minter");

  uint256 constant cvxMintAmount = 500e18;
  uint256 constant auraMintAmount = 1000e18;

  uint256 constant UNIT = 1e18;

  function setUp() public virtual override {
    WarlordTest.setUp();

    vm.startPrank(admin);
    war.grantRole(keccak256("MINTER_ROLE"), address(_minter));
    war.grantRole(keccak256("BURNER_ROLE"), address(redeemer));
    vm.stopPrank();

    deal(address(aura), address(admin), 10_000e18);
    deal(address(cvx), address(admin), 10_000e18);

    deal(address(aura), address(alice), 5000e18);
    deal(address(cvx), address(alice), 5000e18);

    address[] memory lockers = new address[](2);
    lockers[0] = address(cvx);
    lockers[1] = address(aura);
    uint256[] memory amounts = new uint256[](2);
    amounts[0] = cvxMintAmount;
    amounts[1] = auraMintAmount;

    vm.startPrank(alice);
    cvx.approve(address(minter), cvxMintAmount);
    aura.approve(address(minter), auraMintAmount);

    minter.mintMultiple(lockers, amounts, alice);
    vm.stopPrank();
    // We go through the minter so the Lockers have tokens and the weights can be calculated
  }

  event NewRedeemTicket(address indexed token, address indexed user, uint256 id, uint256 amount, uint256 redeemIndex);
  event Redeemed(address indexed token, address indexed user, address receiver, uint256 indexed ticketNumber);
  event SetWarLocker(address indexed token, address indexed locker);
  event RedeemFeeUpdated(uint256 oldRedeemFee, uint256 newRedeemFee);
  event MintRatioUpdated(address oldMintRatio, address newMintRatio);
  event FeeReceiverUpdated(address oldFeeReceiver, address newFeeReceiver);
}
