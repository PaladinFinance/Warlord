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
  IWarRedeemModule public redeemModule;
  address public controller;

  WarMinter warMinter;

  // TODO add events
  constructor(address _controller, address _redeemModule, address _warMinter, address _delegatee) {
    if (_controller == address(0) || _redeemModule == address(0) || _warMinter == address(0)) {
      revert Errors.ZeroAddress();
    }
    warMinter = WarMinter(_warMinter);
    controller = _controller;
    redeemModule = IWarRedeemModule(_redeemModule);
    delegatee = _delegatee;
  }

  modifier onlyWarMinter() {
    if (address(warMinter) != msg.sender) revert Errors.CallerNotAllowed();
    _;
  }

  // TODO setter for controller and redeem module

  function pause() external onlyOwner {
    _pause();
  }

  function unpause() external onlyOwner {
    _unpause();
  }

  function migrate() external virtual;
}
