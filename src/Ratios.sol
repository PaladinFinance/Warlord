// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IRatios} from "interfaces/IRatios.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {Errors} from "utils/Errors.sol";
import {Owner} from "utils/Owner.sol";

contract WarRatios is IRatios, Owner {
  uint256 private constant UNIT = 1e18;
  uint256 private constant MAX_WAR_SUPPLY_PER_TOKEN = 10_000 * 1e18;

  mapping(address => uint256) public warPerToken;

  function addTokenWithSupply(address token, uint256 maxSupply) external onlyOwner {
    if (token == address(0)) revert Errors.ZeroAddress();
    if (maxSupply == 0) revert Errors.ZeroValue();
    if (warPerToken[token] != 0) revert Errors.SupplyAlreadySet();

    warPerToken[token] = MAX_WAR_SUPPLY_PER_TOKEN * UNIT / maxSupply;
  }

  function getMintAmount(address token, uint256 amount) external view returns (uint256 mintAmount) {
    if (token == address(0)) revert Errors.ZeroAddress();
    if (amount == 0) revert Errors.ZeroValue();

    mintAmount = amount * warPerToken[token] / UNIT;
  }

  function getBurnAmount(address token, uint256 burnAmount) external view returns (uint256 redeemAmount) {
    if (token == address(0)) revert Errors.ZeroAddress();
    if (burnAmount == 0) revert Errors.ZeroValue();

    redeemAmount = burnAmount * UNIT / warPerToken[token];
  }
}
