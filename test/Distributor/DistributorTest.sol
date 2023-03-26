// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../WarlordTest.sol";
import "src/interfaces/external/IHolyPaladinToken.sol";

contract DistributorTest is WarlordTest {
  event DistributionCreated(uint256 indexed distributionIndex, uint256 amount, uint256 totalLocked);
  event Claim(address indexed user, address indexed receiver, uint256 amount);
  event DistributionManagerUpdated(address indexed oldDistributionManager, address indexed newDistributionManager);

  IHolyPaladinToken dummyHolyPaladin;

  function setUp() public virtual override {
    WarlordTest.setUp();
    dummyHolyPaladin = new MockHolyPaladin();
  }
}

contract MockHolyPaladin is IHolyPaladinToken {
  function getUserLock(address user) external view returns (UserLock memory) {}
  function getUserPastLock(address user, uint256 blockNumber) external view returns (UserLock memory) {}

  function getCurrentTotalLock() external view returns (TotalLock memory) {}
  function getPastTotalLock(uint256 blockNumber) external view returns (TotalLock memory) {}
}
