// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {WarToken} from "./Token.sol";
import {IWarLocker} from "interfaces/IWarLocker.sol";
import {IMintRatio} from "interfaces/IMintRatio.sol";
import {Owner} from "utils/Owner.sol";
import {Errors} from "utils/Errors.sol";

contract WarMinter is Owner {
  WarToken _war;
  IMintRatio _mintRatio;
  mapping(address => address) _locker;

  using SafeERC20 for IERC20;

  constructor(address war_, address mintRatio_) {
    if (war_ == address(0) || mintRatio_ == address(0)) revert Errors.ZeroAddress();
    _war = WarToken(war_);
    _mintRatio = IMintRatio(mintRatio_);
  }

  function warToken() external view returns (address) {
    return address(_war);
  }

  function mintRatio() external view returns (address) {
    return address(_mintRatio);
  }

  function setMintRatio(address mintRatio_) public onlyOwner {
    if (mintRatio_ == address(0)) revert Errors.ZeroAddress();
    _mintRatio = IMintRatio(mintRatio_);
  }

  function setLocker(address vlToken, address warLocker) public onlyOwner {
    if (vlToken == address(0)) revert Errors.ZeroAddress();
    if (warLocker == address(0)) revert Errors.ZeroAddress();
    address expectedToken = IWarLocker(warLocker).token();
    if (expectedToken != vlToken) revert Errors.MismatchingLocker(expectedToken, vlToken);
    _locker[vlToken] = warLocker;
  }

  // TODO handle reentrancy
  function mint(address vlToken, uint256 amount) public {
    mint(vlToken, amount, msg.sender);
  }

  function mint(address vlToken, uint256 amount, address receiver) public {
    if (amount == 0) revert Errors.ZeroValue();
    if (vlToken == address(0) || receiver == address(0)) revert Errors.ZeroAddress();
    if (_locker[vlToken] == address(0)) revert Errors.NoWarLocker();

    IWarLocker locker = IWarLocker(_locker[vlToken]);

    IERC20(vlToken).safeTransferFrom(msg.sender, address(this), amount);
    IERC20(vlToken).safeApprove(address(locker), amount);
    locker.lock(amount);

    uint256 mintAmount = IMintRatio(_mintRatio).getMintAmount(vlToken, amount);
    if (mintAmount == 0) revert Errors.ZeroMintAmount();
    _war.mint(receiver, mintAmount);
  }

  function mintMultiple(address[] calldata vlTokens, uint256[] calldata amounts, address receiver) public {
    if (vlTokens.length != amounts.length) revert Errors.DifferentSizeArrays(vlTokens.length, amounts.length);
    if (vlTokens.length == 0) revert Errors.EmptyArray();
    uint256 length = vlTokens.length;
    for (uint256 i; i < length;) {
      mint(vlTokens[i], amounts[i], receiver);
      unchecked {
        ++i;
      }
    }
  }

  function mintMultiple(address[] calldata vlTokens, uint256[] calldata amounts) public {
    mintMultiple(vlTokens, amounts, msg.sender);
  }
}
