// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IFarmer} from "interfaces/IFarmer.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {Owner} from "utils/Owner.sol";
import {CrvDepositor} from "interfaces/external/CrvDepositor.sol";
import {CvxCrvStaker} from "interfaces/external/CvxCrvStaker.sol";
import {Errors} from "utils/Errors.sol";

contract WarCvxCrvStaker is IFarmer, Owner {
  uint256 _index;
  IERC20 immutable crv = IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);
  // CrvDepositor immutable crvDepositor = CrvDepositor(0x8014595F2AB54cD7c604B00E9fb932176fDc86Ae);
  IERC20 immutable cvxCrv = IERC20(0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7);
  CrvDepositor constant crvDepositor = CrvDepositor(0x8014595F2AB54cD7c604B00E9fb932176fDc86Ae);
	CvxCrvStaker constant staker = CvxCrvStaker(0xaa0C3f5F7DFD688C6E646F66CD2a6B66ACdbE434);
	address controller;

  using SafeERC20 for IERC20;

	constructor(address _controller) {
		controller = _controller;
	}

  function _crvToCvxCrv(uint256 amount) internal {
    crv.safeTransferFrom(controller, address(this), amount);
		crv.safeApprove(address(crvDepositor), amount);
    crvDepositor.deposit(amount, false); // TODO shitload of parameters to figure out
  }

  function _stakeCvxCrv(uint256 amount) internal {
		cvxCrv.safeTransferFrom(controller, address(this), amount);
		cvxCrv.safeApprove(address(staker), amount);
		staker.depositAndSetWeight(amount, 0); // TODO figure out which weight maximized governance tokens
	}

	function stake(address source, uint256 amount) public {
		if (amount == 0) revert Errors.ZeroValue();
		if (source == address(crv)) _crvToCvxCrv(amount);
		else if (source != address(cvxCrv)) revert Errors.IncorrectToken();
		_stakeCvxCrv(amount);
		_index += amount;
	}

  function getCurrentIndex() public view returns (uint256) {
    return _index;
  }

	function setRewardWeight(uint256 weight) public onlyOwner {
		staker.setRewardWeight(weight);
	}

  function sendTokens(address receiver, uint256 amount) public onlyOwner {
		// TODO Should I let choose the amount or should it always be whole non staked balance?
		if (receiver == address(0)) revert Errors.ZeroAddress();
		if (amount == 0) revert Errors.ZeroValue();
		// TODO should I unstake some cvxCrv if the amount < cvxCrv.balanceOf(address(this)) ?
    cvxCrv.safeTransferFrom(address(this), receiver, amount);
  }
}
