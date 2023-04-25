// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "../WarlordTest.sol";
import "src/Zap.sol";

contract ZapTest is WarlordTest {
  uint256 constant cvxMaxSupply = 100_000_000e18;
  uint256 constant auraMaxSupply = 100_000_000e18;

  event Zap(address indexed sender, address indexed receiver, uint256 stakedAmount);

  function setUp() public virtual override {
    WarlordTest.setUp();

    vm.startPrank(admin);
    war.grantRole(keccak256("MINTER_ROLE"), address(minter));

    zap = new WarZap(address(minter), address(staker), address(war));

    vm.stopPrank();

    deal(address(aura), address(alice), 10_000e18);
    deal(address(cvx), address(alice), 10_000e18);
  }
}
