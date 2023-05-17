// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./DistributorTest.sol";

contract CreateDistribution is DistributorTest {
  function testDefaultBehavior(uint256 amount) public {
    vm.assume(amount > 0 && amount < WAR_SUPPLY_UPPER_BOUND);

    uint256 hPalTotalLocked = IHolyPaladinToken(address(hPal)).getCurrentTotalLock().total;

    deal(address(war), distributionManager, amount);

    vm.startPrank(distributionManager);
    war.approve(address(distributor), amount);

    vm.expectEmit(true, true, false, true);
    emit DistributionCreated(0, amount, hPalTotalLocked);

    distributor.createDistribution(amount);
    vm.stopPrank();

    (
      uint256 distributionBlockNumber,
      uint256 distributionTimeStamp,
      uint256 distributionAmount,
      uint256 distributionTotalLocked
    ) = distributor.distributions(0);
    assertEqDecimal(
      distributionAmount, amount, 18, "The distribution amount should be equivalent to the amount passed as argument"
    );
    assertEqDecimal(
      distributionTotalLocked,
      hPalTotalLocked,
      18,
      "The total hpal locked should be equivalent to the amount returned by the contract"
    );
    assertEqDecimal(
      distributionBlockNumber, block.number, 18, "The distribution block number should be the current block"
    );
    assertEqDecimal(
      distributionTimeStamp, block.timestamp, 18, "The distribution timestamp should be the block's timestamp"
    );
  }

  function testMultipleDistributions() public {
  }

  function testOnlyDistributionManager(uint256 amount) public {
    vm.expectRevert(Errors.CallerNotAllowed.selector);
    distributor.createDistribution(amount);
  }

  function testWhenNotPaused(uint256 amount) public {
    vm.prank(admin);
    distributor.pause();

    vm.expectRevert("Pausable: paused");

    vm.prank(distributionManager);
    distributor.createDistribution(amount);
  }

  function testZeroAmount() public {
    vm.expectRevert(Errors.ZeroValue.selector);

    vm.prank(distributionManager);
    distributor.createDistribution(0);
  }

  function testZeroTotalLockedPal(uint256 amount) public {
    vm.assume(amount > 0);

    // Setting up zero locked hPAL trigger
    distributor = new HolyPaladinDistributor(address(dummyHolyPaladin), address(war), distributionManager);

    vm.expectRevert(Errors.ZeroValue.selector);

    vm.prank(distributionManager);
    distributor.createDistribution(amount);
  }
}
