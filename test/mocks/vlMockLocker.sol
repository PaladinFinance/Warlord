// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IWarLocker} from "interfaces/IWarLocker.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";

contract vlMockLocker is IWarLocker {
  IERC20 _token;

  using SafeERC20 for IERC20;

  constructor(address _tokenAddress) {
    _token = IERC20(_tokenAddress);
  }

  function lock(uint256 amount) public {
    _token.transferFrom(msg.sender, address(this), amount);
  }

  function token() public view returns (address) {
    return address(_token);
  }

  function harvest() external {}
}
