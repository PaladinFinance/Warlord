// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IFarmer} from "interfaces/IFarmer.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {Owner} from "utils/Owner.sol";

contract CvxCrvStaker is IFarmer, Owner {
  uint256 _index;
  IERC20 immutable crv = IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);
  // CrvDepositor immutable crvDepositor = CrvDepositor(0x8014595F2AB54cD7c604B00E9fb932176fDc86Ae);
  IERC20 immutable cvxCrv = IERC20(0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7);

  using SafeERC20 for IERC20;

  function _crvToCvxCrv() internal {
    // TODO convert full balance ?
    // crv.approve(address(crvDepositor), crv.balanceOf(address(this)));
    // crvDepositor.deposit(5000, false); // TODO shitload of parameters
  }

  function stakeCvxCrv() public {}

  function getCurrentIndex() public view returns (uint256) {
    return _index;
  }

  function sendTokens(address receiver, uint256 amount) public {
    cvxCrv.safeTransferFrom(address(this), receiver, amount);
  }
}
