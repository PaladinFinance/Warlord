pragma solidity 0.8.16;
//SPDX-License-Identifier: Unlicensed

library Errors {
  // Argument validation
  error ZeroAddress();
  error ZeroValue();
  error DifferentSizeArrays(uint256 size1, uint256 size2);
  error EmptyArray();
  error AlreadySet();

  // Ownership
  error CannotBeOwner();
  error CallerNotPendingOwner();
  error CallerNotAllowed();

  // Locker
  error NoWarLocker(); // _locker[token] == 0x0
  error MismatchingLocker(address expected, address actual);

  // Minter
  error MintAmountBiggerThanSupply();

  // Staker
  error AlreadyListedDepositor();
  error NotListedDepositor();
  error AlreadySetFarmer();

  // MintRatio
  error ZeroMintAmount();
  error SupplyAlreadySet();

  // IFarmer
  error IncorrectToken();
  error UnstakingMoreThanBalance();

  // Maths
  error NumberExceed128Bits();

  // AuraBalFarmer
  error SlippageTooHigh();
}
