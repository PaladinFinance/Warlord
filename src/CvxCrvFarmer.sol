//██████╗  █████╗ ██╗      █████╗ ██████╗ ██╗███╗   ██╗
//██╔══██╗██╔══██╗██║     ██╔══██╗██╔══██╗██║████╗  ██║
//██████╔╝███████║██║     ███████║██║  ██║██║██╔██╗ ██║
//██╔═══╝ ██╔══██║██║     ██╔══██║██║  ██║██║██║╚██╗██║
//██║     ██║  ██║███████╗██║  ██║██████╔╝██║██║ ╚████║
//╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝

pragma solidity 0.8.16;
//SPDX-License-Identifier: BUSL-1.1

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {CvxCrvStaking} from "interfaces/external/convex/CvxCrvStaking.sol";
import {CrvDepositor} from "interfaces/external/convex/CrvDepositor.sol";
import "./BaseFarmer.sol";

contract WarCvxCrvFarmer is WarBaseFarmer {
  IERC20 private constant crv = IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);
  IERC20 private constant cvxCrv = IERC20(0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7);
  CvxCrvStaking private constant cvxCrvStaker = CvxCrvStaking(0xaa0C3f5F7DFD688C6E646F66CD2a6B66ACdbE434);
  CrvDepositor private constant crvDepositor = CrvDepositor(0x8014595F2AB54cD7c604B00E9fb932176fDc86Ae);

  using SafeERC20 for IERC20;

  constructor(address _controller, address _warStaker) WarBaseFarmer(_controller, _warStaker) {}

  function token() external pure returns (address) {
    return address(cvxCrv);
  }

  function setRewardWeight(uint256 weight) external onlyOwner whenNotPaused {
    cvxCrvStaker.setRewardWeight(weight);
  }

  function _isTokenSupported(address _token) internal pure override returns (bool) {
    return _token == address(crv) || _token == address(cvxCrv);
  }

  function _stake(address _token, uint256 _amount) internal override returns (uint256) {
    // TODO #17

    IERC20(_token).safeTransferFrom(controller, address(this), _amount);

    if (_token == address(crv)) {
      uint256 initialBalance = cvxCrv.balanceOf(address(this));
      crv.safeApprove(address(crvDepositor), 0);
      crv.safeIncreaseAllowance(address(crvDepositor), _amount);
      crvDepositor.deposit(_amount, true, address(0));
      // Take into account possible bonus for locking crv
      _index += cvxCrv.balanceOf(address(this)) - initialBalance;
    } else {
      _index += _amount;
    }
    cvxCrv.safeApprove(address(cvxCrvStaker), 0);
    cvxCrv.safeIncreaseAllowance(address(cvxCrvStaker), _amount);
    cvxCrvStaker.stake(_amount, address(this));
    return _amount;
  }

  function _harvest() internal override {
    cvxCrvStaker.getReward(address(this), controller);
  }

  function _stakedBalance() internal view override returns (uint256) {
    return cvxCrvStaker.balanceOf(address(this));
  }

  function _sendTokens(address receiver, uint256 amount) internal override {
    cvxCrvStaker.withdraw(amount);
    cvxCrv.safeTransfer(receiver, amount);
  }

  function _migrate(address receiver) internal override {
    // TODO #19
    // Unstake and send cvxCrv
    uint256 cvxCrvStakedBalance = cvxCrvStaker.balanceOf(address(this));
    cvxCrvStaker.withdraw(cvxCrvStakedBalance);
    cvxCrv.safeTransfer(receiver, cvxCrvStakedBalance);
  }
}
