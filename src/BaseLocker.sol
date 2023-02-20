// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IWarLocker} from "interfaces/IWarLocker.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {Pausable} from "openzeppelin/security/Pausable.sol";
import {ReentrancyGuard} from "solmate/utils/ReentrancyGuard.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {Owner} from "utils/Owner.sol";
import {Errors} from "utils/Errors.sol";
import {IWarRedeemModule} from "interfaces/IWarRedeemModule.sol";
import {WarMinter} from "src/Minter.sol";

abstract contract WarBaseLocker is IWarLocker, Pausable, Owner, ReentrancyGuard {
  address public delegatee;
  address public redeemModule;
  address public controller;
  address public warMinter;
  bool public isShutdown;

  // TODO add events
  constructor(address _controller, address _redeemModule, address _warMinter, address _delegatee) {
    if (_controller == address(0) || _redeemModule == address(0) || _warMinter == address(0)) {
      revert Errors.ZeroAddress();
    }
    warMinter = _warMinter;
    controller = _controller;
    redeemModule = _redeemModule;
    delegatee = _delegatee;
  }

  modifier onlyWarMinter() {
    if (warMinter != msg.sender) revert Errors.CallerNotAllowed();
    _;
  }

  function setController(address _controller) external onlyOwner {
    if (_controller == address(0)) revert Errors.ZeroAddress();
    if (_controller == controller) revert Errors.AlreadySet();
    controller = _controller;
  }

  function setRedeemModule(address _redeemModule) external onlyOwner {
    if (_redeemModule == address(0)) revert Errors.ZeroAddress();
    if (_redeemModule == address(redeemModule)) revert Errors.AlreadySet();
    redeemModule = _redeemModule;
  }

  function harvest() external whenNotPaused {
    _harvest();
  }

  function _harvest() internal virtual;

  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
    if (isShutdown) revert Errors.ContractKilled();
    _unpause();
  }

  function shutdown() external onlyOwner whenPaused {
    isShutdown = true;
  }

  function migrate(address receiver) external virtual;
}
