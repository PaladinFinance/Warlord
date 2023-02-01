pragma solidity 0.8.16;
//SPDX-License-Identifier: Unlicensed

library Errors {
  // Argument validation
  error ZeroAddress();
  error ZeroValue(); // TODO more specific errors ?
  error DifferentSizeArrays(uint256 size1, uint256 size2);

  // Ownership
  error CannotBeOwner();
  error CallerNotPendingOwner();
  error CallerNotAllowed();

  // WarLocker
  error NoWarLocker(); // _locker[token] == 0x0
  error MismatchingLocker(address expected, address actual);

  // WarStaker
  error AlreadyListedDepositor();
  error NotListedDepositor();
  error AlreadySetFarmer();

  // Maths
  error NumberExceed128Bits();
}
