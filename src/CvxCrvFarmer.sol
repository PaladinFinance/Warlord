// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {CvxCrvStaking} from "interfaces/external/convex/CvxCrvStaking.sol";
import {CrvDepositor} from "interfaces/external/convex/CrvDepositor.sol";
import "./BaseFarmer.sol";

// TODO test for event emission
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

  function stake(address _token, uint256 _amount) external onlyController whenNotPaused nonReentrant {
    if (_token != address(cvxCrv) && _token != address(crv)) revert Errors.IncorrectToken();
    if (_amount == 0) revert Errors.ZeroValue();

    // TODO test if it works when a bonus is available

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

    emit Staked(_amount, _index);
  }

  function harvest() external whenNotPaused nonReentrant {
    _harvest();
  }

  function _harvest() internal {
    cvxCrvStaker.getReward(address(this), controller);
  }

  function sendTokens(address receiver, uint256 amount) external onlyWarStaker whenNotPaused nonReentrant {
    if (receiver == address(0)) revert Errors.ZeroAddress();
    if (amount == 0) revert Errors.ZeroValue();
    if (cvxCrvStaker.balanceOf(address(this)) < amount) revert Errors.UnstakingMoreThanBalance();

    cvxCrvStaker.withdraw(amount);
    cvxCrv.safeTransfer(receiver, amount);
  }

  function migrate(address receiver) external override onlyOwner whenPaused {
    if (receiver == address(0)) revert Errors.ZeroAddress();

    // Unstake and send cvxCrv
    uint256 cvxCrvStakedBalance = cvxCrvStaker.balanceOf(address(this));
    cvxCrvStaker.withdraw(cvxCrvStakedBalance);
    cvxCrv.safeTransfer(receiver, cvxCrvStakedBalance);

    // Harvest and send rewards to the controller
    _harvest();
  }

  function rewardTokens() external view returns(address[] memory) { // TODO check for a better way to do this
    uint256 rewardsLength = cvxCrvStaker.rewardLength();
    address[] memory _tokens = new address[](rewardsLength);

    for (uint256 i; i < rewardsLength;) {
      (address _token,,,) = cvxCrvStaker.rewards(i);
      _tokens[i] = _token;

      unchecked {
        ++i;
      }
    }

    return _tokens;
  }
}
