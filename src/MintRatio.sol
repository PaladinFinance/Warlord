// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IMintRatio} from "interfaces/IMintRatio.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {Errors} from "utils/Errors.sol";
import {Owner} from "utils/Owner.sol";

contract WarMintRatio is IMintRatio, Owner {
  uint256 private constant UNIT = 1e18;
  uint256 private constant MAX_WAR_SUPPLY_PER_TOKEN = 10_000 * 1e18;

  mapping(address => uint256) public warPerToken;

  function addTokenWithSupply(address token, uint256 maxSupply) public onlyOwner {
    if (token == address(0)) revert Errors.ZeroAddress();
    if (maxSupply == 0) revert Errors.ZeroValue();
    if (warPerToken[token] != 0) revert Errors.SupplyAlreadySet();

    warPerToken[token] = MAX_WAR_SUPPLY_PER_TOKEN * UNIT / maxSupply;
  }

  function getMintAmount(address token, uint256 amount) public view returns (uint256 mintAmount) {
    if (token == address(0)) revert Errors.ZeroAddress();
    if (amount == 0) revert Errors.ZeroValue();

    mintAmount = amount * warPerToken[token] / UNIT;

    if (mintAmount > MAX_WAR_SUPPLY_PER_TOKEN) revert Errors.MintAmountBiggerThanSupply();
  }
}
