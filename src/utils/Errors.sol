pragma solidity 0.8.16;
//SPDX-License-Identifier: Unlicensed

library Errors {
  // Argument validation
  error ZeroAddress();
  error ZeroValue();
  error DifferentSizeArrays(uint256 size1, uint256 size2);
  error EmptyArray();
  error AlreadySet();
  error SameAddress();
  error InvalidParameter();

  // Ownership
  error CannotBeOwner();
  error CallerNotPendingOwner();
  error CallerNotAllowed();

  // Controller
  error ListedLocker();
  error ListedFarmer();
  error InvalidFeeRatio();

  // Locker
  error NoWarLocker(); // _locker[token] == 0x0
  error LockerShutdown();
  error MismatchingLocker(address expected, address actual);

  // Minter
  error MintAmountBiggerThanSupply();

  // Redeemer
  error NotListedLocker();
  error InvalidIndex();
  error CannotRedeemYet();
  error AlreadyRedeemed();
  error WeightOverflow();

  // Staker
  error AlreadyListedDepositor();
  error NotListedDepositor();
  error MismatchingFarmer();

  // MintRatio
  error ZeroMintAmount();
  error SupplyAlreadySet();

  // Harvestable
  error NotRewardToken();

  // IFarmer
  error IncorrectToken();
  error UnstakingMoreThanBalance();

  // Maths
  error NumberExceed128Bits();
  error NumberExceed48Bits();

  // AuraBalFarmer
  error SlippageTooHigh();

  // Admin
  error RecoverForbidden();

  // EscrowedToken
  error CannotTransfer();
  error VestingNotAllowed();
  error VestingNotFinished();
  error VestingAlreadyClaimed();
}
