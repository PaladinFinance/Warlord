// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {WarToken} from "./WarToken.sol";
import {IWarLocker} from "interfaces/IWarLocker.sol";
import {IMintRatio} from "interfaces/IMintRatio.sol";
import {Owner} from "utils/Owner.sol";
import {Errors} from "utils/Errors.sol";

contract WarMinter is Owner {
  WarToken public war;
  IMintRatio mintRatio;
  mapping(address => address) _locker;

  constructor(address _war, address _mintRatio) {
    if (_war == address(0)) revert Errors.ZeroAddress();
    if (_mintRatio == address(0)) revert Errors.ZeroAddress();
    war = WarToken(_war);
    mintRatio = IMintRatio(_mintRatio);
  }

  function setMintRatio(address _mintRatio) public onlyOwner {
    if (_mintRatio == address(0)) revert Errors.ZeroAddress();
    mintRatio = IMintRatio(_mintRatio);
  }

  function setLocker(address vlToken, address warLocker) public onlyOwner {
    if (vlToken == address(0)) revert Errors.ZeroAddress();
    if (warLocker == address(0)) revert Errors.ZeroAddress();
    address expectedToken = IWarLocker(warLocker).token();
    if (expectedToken != vlToken) revert Errors.MismatchingLocker(expectedToken, vlToken);
    _locker[vlToken] = warLocker;
  }

  function mint(address vlToken, uint256 amount) public {
    mint(vlToken, amount, msg.sender);
  }

  function mint(address vlToken, uint256 amount, address receiver) public {
    if (amount == 0) revert Errors.ZeroValue();
    if (vlToken == address(0) || receiver == address(0)) revert Errors.ZeroAddress();
    if (_locker[vlToken] == address(0)) revert Errors.NoWarLocker();

    IWarLocker locker = IWarLocker(_locker[vlToken]);

    ERC20(vlToken).transferFrom(msg.sender, address(this), amount);
    ERC20(vlToken).approve(address(locker), amount);
    locker.lock(amount);

    uint256 mintAmount = IMintRatio(mintRatio).computeMintAmount(vlToken, amount);
    if (mintAmount == 0) revert Errors.ZeroMintAmount();
    war.mint(receiver, mintAmount);
  }

  function mintMultiple(address[] calldata vlTokens, uint256[] calldata amounts, address receiver) public {
    if (vlTokens.length != amounts.length) revert Errors.DifferentSizeArrays(vlTokens.length, amounts.length);
    if (vlTokens.length == 0) revert Errors.EmptyArray();
    for (uint256 i = 0; i < vlTokens.length; ++i) {
      // TODO should ++i be unchecked ?
      mint(vlTokens[i], amounts[i], receiver);
    }
  }

  function mintMultiple(address[] calldata vlTokens, uint256[] calldata amounts) public {
    mintMultiple(vlTokens, amounts, msg.sender);
  }
}
