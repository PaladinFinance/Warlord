pragma solidity 0.8.16;
//SPDX-License-Identifier: Unlicensed

// Argument validation
error ZeroAddress();
error ZeroValue(); // TODO more specific errors ?
error DifferentSizeArrays(uint256 size1, uint256 size2);

// Ownership
error CannotBeOwner();
error CallerNotPendingOwner(); 

// WarLocker
error NoWarLocker(); // _locker[token] == 0x0

