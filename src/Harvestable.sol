// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IHarvestable} from "interfaces/IHarvestable.sol";
import {Owner} from "utils/Owner.sol";
import {Errors} from "utils/Errors.sol";

abstract contract Harvestable is IHarvestable, Owner {
  address[] internal _rewardTokens;

  function rewardTokens() external view returns (address[] memory) {
    return _rewardTokens;
  }

  function addReward(address reward) external onlyOwner {
    if (reward == address(0)) revert Errors.ZeroAddress();

    _rewardTokens.push(reward);
  }

  function removeReward(address reward) external onlyOwner {
    if (reward == address(0)) revert Errors.ZeroAddress();

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
  }
}