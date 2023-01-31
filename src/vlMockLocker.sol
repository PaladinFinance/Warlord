// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {WarLocker} from "interfaces/WarLocker.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract vlMockLocker is WarLocker {
  ERC20 token;

  constructor(address _token) {
    token = ERC20(_token);
  }

  function lock(uint256 amount) public {
    token.transferFrom(msg.sender, address(this), amount);
  }
}
