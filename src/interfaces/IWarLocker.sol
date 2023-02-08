// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IHarvestable} from "./IHarvestable.sol";

interface IWarLocker is IHarvestable {
  function lock(uint256 amount) external;
  function token() external view returns (address);
}
