// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IFarmer} from "interfaces/IFarmer.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {Owner} from "utils/Owner.sol";
import {CvxCrvStaker} from "interfaces/external/CvxCrvStaker.sol";
import {Errors} from "utils/Errors.sol";

contract WarCvxCrvStaker is IFarmer, Owner {
  IERC20 constant crv = IERC20(0xD533a949740bb3306d119CC777fa900bA034cd52);
  IERC20 constant cvxCrv = IERC20(0x62B9c7356A2Dc64a1969e19C23e4f579F9810Aa7);
  CvxCrvStaker constant staker = CvxCrvStaker(0xaa0C3f5F7DFD688C6E646F66CD2a6B66ACdbE434);
  address controller;

  uint256 _index;

  using SafeERC20 for IERC20;

  constructor(address _controller) {
    if (controller == address(0)) revert Errors.ZeroAddress();
    controller = _controller;
  }

  modifier onlyController() {
    if (controller != msg.sender) revert Errors.CallerNotAllowed(); // TODO More specific error ?
    _;
  }

  function setController(address _controller) external onlyOwner {
    if (controller == address(0)) revert Errors.ZeroAddress();
    controller = _controller;
  }

  function _stakeCrv(uint256 amount) internal {
    crv.safeApprove(address(staker), amount);
    staker.deposit(amount, address(this));
  }

  function _stakeCvxCrv(uint256 amount) internal {
    cvxCrv.safeApprove(address(staker), amount);
    staker.stake(amount, address(this));
  }

  function stake(address source, uint256 amount) external onlyController {
    if (source != address(cvxCrv) || source != address(crv)) revert Errors.IncorrectToken();
    if (amount == 0) revert Errors.ZeroValue();

    _index += amount;

    IERC20(source).safeTransferFrom(controller, address(this), amount);
    if (source == address(crv)) _stakeCrv(amount);
    if (source == address(cvxCrv)) _stakeCvxCrv(amount);
  }

  function getCurrentIndex() public view returns (uint256) {
    return _index;
  }

  function harvest() public {
    staker.getReward(address(this), controller);
  }

  function setRewardWeight(uint256 weight) public onlyOwner {
    staker.setRewardWeight(weight);
  }

  function sendTokens(address receiver, uint256 amount) public {
    if (receiver == address(0)) revert Errors.ZeroAddress();
    if (amount == 0) revert Errors.ZeroValue();
    _unstake(amount);
    cvxCrv.safeTransferFrom(address(this), receiver, amount);
  }

  function _unstake(uint256 amount) internal {
    if (staker.balanceOf(address(this)) > 0) revert Errors.ZeroValue(); //TODO more specific error
    staker.withdraw(amount);
  }
}
