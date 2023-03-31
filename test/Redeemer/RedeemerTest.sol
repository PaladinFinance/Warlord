// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../WarlordTest.sol";
import {DummyLocker} from "../Minter/MinterTest.sol";

contract RedeemerTest is WarlordTest {
  function setUp() public virtual override {
    WarlordTest.setUp();
  }

  event NewRedeemTicket(address indexed token, address indexed user, uint256 amount, uint256 redeemIndex);
  event Redeemed(address indexed token, address indexed user, address receiver, uint256 indexed ticketNumber);
  event SetWarLocker(address indexed token, address indexed locker);
  event RedeemFeeUpdated(uint256 oldRedeemFee, uint256 newRedeemFee);
  event MintRatioUpdated(address oldMintRatio, address newMintRatio);
  event FeeReceiverUpdated(address oldFeeReceiver, address newFeeReceiver);
}
