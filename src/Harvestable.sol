//██████╗  █████╗ ██╗      █████╗ ██████╗ ██╗███╗   ██╗
//██╔══██╗██╔══██╗██║     ██╔══██╗██╔══██╗██║████╗  ██║
//██████╔╝███████║██║     ███████║██║  ██║██║██╔██╗ ██║
//██╔═══╝ ██╔══██║██║     ██╔══██║██║  ██║██║██║╚██╗██║
//██║     ██║  ██║███████╗██║  ██║██████╔╝██║██║ ╚████║
//╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝


pragma solidity 0.8.16;
//SPDX-License-Identifier: BUSL-1.1

import {IHarvestable} from "interfaces/IHarvestable.sol";
import {Owner} from "utils/Owner.sol";
import {Errors} from "utils/Errors.sol";

abstract contract Harvestable is IHarvestable, Owner {
  address[] private _rewardTokens;
  mapping(address => bool) private _rewardAssigned;

  function rewardTokens() external view returns (address[] memory) {
    return _rewardTokens;
  }

  function addReward(address reward) external onlyOwner {
    if (reward == address(0)) revert Errors.ZeroAddress();
    if (_rewardAssigned[reward]) revert Errors.AlreadySet();

    _rewardTokens.push(reward);
    _rewardAssigned[reward] = true;
  }

  function removeReward(address reward) external onlyOwner {
    if (reward == address(0)) revert Errors.ZeroAddress();
    if (!_rewardAssigned[reward]) revert Errors.NotRewardToken();

    // remove the reward without leaving holes in the array
    address[] memory rewardTokens_ = _rewardTokens;
    uint256 length = rewardTokens_.length;
    uint256 lastIndex = length - 1;
    for (uint256 i; i < length;) {
      if (rewardTokens_[i] == reward) {
        if (i != lastIndex) {
          _rewardTokens[i] = rewardTokens_[lastIndex];
        }

        _rewardTokens.pop();

        break;
      }

      unchecked {
        ++i;
      }
    }

    // rewardToken is no longer part of the list
    _rewardAssigned[reward] = false;
  }
}
