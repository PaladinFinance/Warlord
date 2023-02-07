// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IHarvestable} from "./IHarvestable.sol";

interface IFarmer is IHarvestable {
  // the index stored by the farmer represents all the recevied tokens
  function getCurrentIndex() external view returns (uint256);

  function sendTokens(address receiver, uint256 amount) external;
}
