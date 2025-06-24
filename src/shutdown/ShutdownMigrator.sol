//██████╗  █████╗ ██╗      █████╗ ██████╗ ██╗███╗   ██╗
//██╔══██╗██╔══██╗██║     ██╔══██╗██╔══██╗██║████╗  ██║
//██████╔╝███████║██║     ███████║██║  ██║██║██╔██╗ ██║
//██╔═══╝ ██╔══██║██║     ██╔══██║██║  ██║██║██║╚██╗██║
//██║     ██║  ██║███████╗██║  ██║██████╔╝██║██║ ╚████║
//╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝

pragma solidity 0.8.16;
//SPDX-License-Identifier: None

import {Owner} from "utils/Owner.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "openzeppelin/security/ReentrancyGuard.sol";
import {Errors} from "utils/Errors.sol";
import {ILocker} from "interfaces/ILocker.sol";
import {IWarRedeemModule} from "interfaces/IWarRedeemModule.sol";

contract ShutdownMigrator is ReentrancyGuard, Owner {
  using SafeERC20 for IERC20;

  IERC20 public immutable cvxToken;
  IERC20 public immutable auraToken;

  address public immutable cvxLocker;
  address public immutable auraLocker;

  address public warRedeemer;

  constructor(
    address _cvxToken,
    address _auraToken,
    address _cvxLocker,
    address _auraLocker
  ) {
    if (
      _cvxToken == address(0) ||
      _auraToken == address(0) ||
      _cvxLocker == address(0) ||
      _auraLocker == address(0)
    ) revert Errors.ZeroAddress();

    cvxToken = IERC20(_cvxToken);
    auraToken = IERC20(_auraToken);

    cvxLocker = _cvxLocker;
    auraLocker = _auraLocker;

  }

  function setRedeemer(address _warRedeemer) external onlyOwner {
    warRedeemer = _warRedeemer;
  }

  function shutdownProcess() external nonReentrant {
    _processCVX();
    _processAURA();
  }

  function _processCVX() internal {
    if(ILocker(cvxLocker).paused()) {
      // If the CVX locker is paused, we can call migrate
      ILocker(cvxLocker).migrate(address(this));
    }

    uint256 cvxBalance = cvxToken.balanceOf(address(this));
    if(cvxBalance == 0) return;

    // Get the amount needed in the Redeem Module
    uint256 withdrawalAmount = IWarRedeemModule(warRedeemer).queuedForWithdrawal(address(cvxToken));

    if(withdrawalAmount > cvxBalance) withdrawalAmount = cvxBalance;
    
    cvxToken.safeTransfer(address(warRedeemer), withdrawalAmount);
    IWarRedeemModule(warRedeemer).notifyUnlock(address(cvxToken), withdrawalAmount);
  }

  function _processAURA() internal {
    if(ILocker(auraLocker).paused()) {
      // If the CVX locker is paused, we can call migrate
      ILocker(auraLocker).migrate(address(this));
    }

    uint256 auraBalance = auraToken.balanceOf(address(this));
    if(auraBalance == 0) return;

    // Get the amount needed in the Redeem Module
    uint256 withdrawalAmount = IWarRedeemModule(warRedeemer).queuedForWithdrawal(address(auraToken));

    if(withdrawalAmount > auraBalance) withdrawalAmount = auraBalance;
    
    auraToken.safeTransfer(address(warRedeemer), withdrawalAmount);
    IWarRedeemModule(warRedeemer).notifyUnlock(address(auraToken), withdrawalAmount);
  }

  function acceptLockersOwnership() external onlyOwner {
    // Accept ownership of the CVX locker & AURA locker
    ILocker(cvxLocker).acceptOwnership();
    ILocker(auraLocker).acceptOwnership();
  }

  function giveBackLockersOwnership() external onlyOwner {
    // Give back ownership of the Lockers to this contract owner
    ILocker(cvxLocker).transferOwnership(owner());
    ILocker(auraLocker).transferOwnership(owner());
  }

  function recoverERC20(address _token) external onlyOwner returns (bool) {
    if (_token == address(0)) revert Errors.ZeroAddress();
    uint256 amount = IERC20(_token).balanceOf(address(this));
    if (amount == 0) revert Errors.ZeroValue();

    IERC20(_token).safeTransfer(owner(), amount);

    return true;
  }
}