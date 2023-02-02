// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IMintRatio} from "interfaces/IMintRatio.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract MintRatio is IMintRatio {
  function computeMintAmount(address token, uint256 amount) public view returns (uint256) {
    // TODO handle this with some math library probably
    uint256 tokenSupply = ERC20(token).totalSupply();
    uint256 mintRatio = amount / tokenSupply;
    uint256 mintAmount = amount * mintRatio;
    return mintAmount;
  }
}
