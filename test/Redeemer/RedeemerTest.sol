// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../WarlordTest.sol";
import {DummyLocker} from "../Minter/MinterTest.sol";

contract RedeemerTest is WarlordTest {
  address _minter = makeAddr("minter");

  function setUp() public virtual override {
    WarlordTest.setUp();

    vm.startPrank(admin);
    war.grantRole(keccak256("MINTER_ROLE"), address(_minter));
    war.grantRole(keccak256("BURNER_ROLE"), address(redeemer));
    vm.stopPrank();

    deal(address(aura), address(admin), 50_000e18);
    deal(address(cvx), address(admin), 50_000e18);
  }

  event NewRedeemTicket(address indexed token, address indexed user, uint256 id, uint256 amount, uint256 redeemIndex);
  event Redeemed(address indexed token, address indexed user, address receiver, uint256 indexed ticketNumber);
  event SetWarLocker(address indexed token, address indexed locker);
  event RedeemFeeUpdated(uint256 oldRedeemFee, uint256 newRedeemFee);
  event MintRatioUpdated(address oldMintRatio, address newMintRatio);
  event FeeReceiverUpdated(address oldFeeReceiver, address newFeeReceiver);
}
