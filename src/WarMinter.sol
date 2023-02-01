// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {WarToken} from "./WarToken.sol";
import {WarLocker} from "interfaces/WarLocker.sol";
import {Owner} from "lib/Warden-Quest/contracts/utils/Owner.sol";
import {ZeroAddress, DifferentSizeArrays, ZeroValue, NoWarLocker, MismatchingLocker} from "./Errors.sol";

contract WarMinter is Owner {
  WarToken public war;
  mapping(address => address) _locker;

  constructor(address _war) {
    if (_war == address(0)) revert ZeroAddress();
    war = WarToken(_war);
  }

  function setLocker(address vlToken, address warLocker) public onlyOwner {
    if (vlToken == address(0)) revert ZeroAddress();
    if (warLocker == address(0)) revert ZeroAddress();
    address expectedToken = WarLocker(warLocker).token();
    if (expectedToken != vlToken) revert MismatchingLocker(expectedToken, vlToken);
    _locker[vlToken] = warLocker;
  }

  function mint(address vlToken, uint256 amount) public {
    mint(vlToken, amount, msg.sender);
  }

  function mint(address vlToken, uint256 amount, address receiver) public {
    if (amount == 0) revert ZeroValue();
    if (receiver == address(0)) revert ZeroAddress();
    if (_locker[vlToken] == address(0)) revert NoWarLocker();

    WarLocker locker = WarLocker(_locker[vlToken]);

    ERC20(vlToken).transferFrom(msg.sender, address(this), amount);
    // aura.transferFrom(msg.sender, address(this), auraAmount);

    ERC20(vlToken).approve(address(locker), amount);
    locker.lock(amount);

    // TODO how to compute amounts to mint
    war.mint(receiver, amount);
  }

  //TODO check calldata
  function mintMultiple(address[] calldata vlTokens, uint256[] calldata amounts, address receiver) public {
    // TODO should I check if array size is 1?
    if (vlTokens.length != amounts.length) revert DifferentSizeArrays(vlTokens.length, amounts.length);
    for (uint256 i = 0; i < vlTokens.length; ++i) {
      mint(vlTokens[i], amounts[i], receiver);
    }
  }

  function mintMultiple(address[] calldata vlTokens, uint256[] calldata amounts) public {
    mintMultiple(vlTokens, amounts, msg.sender);
  }
}
