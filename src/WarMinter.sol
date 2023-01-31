// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {WarToken} from "./WarToken.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {vlTokenLocker} from "interfaces/vlTokenLocker.sol";

contract WarMinter {
  WarToken public war;
  ERC20 public immutable cvx = ERC20(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
  ERC20 public immutable aura = ERC20(0xC0c293ce456fF0ED870ADd98a0828Dd4d2903DBF);
  address vlCvxLocker;
  address vlAuraLocker;

  constructor(address _war, address _vlCvxLocker, address _vlAuraLocker) {
    war = WarToken(_war);
    vlCvxLocker = _vlCvxLocker;
    vlAuraLocker = _vlAuraLocker;
  }

  function mint(uint256 cvxAmount, uint256 auraAmount) public {
    mint(cvxAmount, auraAmount, msg.sender);
  }

  function mint(uint256 cvxAmount, uint256 auraAmount, address receiver) public {
    //TODO check if a sum is more gas efficient;
    require(cvxAmount > 0 || auraAmount > 0, "not sending any token");
    require(receiver != address(0), "zero address");

    cvx.transferFrom(msg.sender, address(this), cvxAmount);
    aura.transferFrom(msg.sender, address(this), auraAmount);

    cvx.approve(vlCvxLocker, cvxAmount);
    vlTokenLocker(vlCvxLocker).lock(cvxAmount);
    cvx.approve(vlAuraLocker, auraAmount);
    vlTokenLocker(vlAuraLocker).lock(auraAmount);

    war.mint(receiver, cvxAmount + auraAmount);
  }
}
