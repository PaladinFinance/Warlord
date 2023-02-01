// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "interfaces/IMintRatio.sol";
import "utils/Owner.sol";
import {Errors} from "utils/Errors.sol";
import "../MainnetTest.sol";

contract MockMintRatio is IMintRatio, MainnetTest {
  mapping(address => uint256) _ratios;

  function init() public {
    setRatio(address(cvx), 15);
    setRatio(address(aura), 22);
  }

  function setRatio(address token, uint256 ratio) public {
    _ratios[token] = ratio;
  }

  function computeMintAmount(address token, uint256 amount) public view returns (uint256) {
    uint256 mintRatio = _ratios[token];
    uint256 mintAmount = amount * mintRatio;
    if (mintAmount == 0) revert Errors.ZeroMintAmount();
    return mintAmount;
  }
}
