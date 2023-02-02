// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IWarLocker} from "interfaces/IWarLocker.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract vlMockLocker is IWarLocker {
  ERC20 _token;

  constructor(address _tokenAddress) {
    _token = ERC20(_tokenAddress);
  }

  function lock(uint256 amount) public {
    _token.transferFrom(msg.sender, address(this), amount);
  }

  function token() public view returns (address) {
    return address(_token);
  }
}
