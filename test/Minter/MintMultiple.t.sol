// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./MinterTest.sol";

contract MintMultiple is MinterTest {
  function testDefaultBehavior(uint256 amount1, uint256 amount2) public {
    vm.assume(amount1 > 1e4 && amount2 > 1e4);
    vm.assume(amount1 < cvx.balanceOf(alice) && amount2 < aura.balanceOf(alice));

    address[] memory lockers = new address[](2);
    lockers[0] = address(cvx);
    lockers[1] = address(aura);
    uint256[] memory amounts = new uint256[](2);
    amounts[0] = amount1;
    amounts[1] = amount2;

    assertEq(war.totalSupply(), 0);
    assertEq(war.balanceOf(bob), 0);

    vm.prank(alice);

    minter.mintMultiple(lockers, amounts, bob);

    //uint256 totalMintedAmount = minter.mintedSupplyPerToken(lockers[0]) + minter.mintedSupplyPerToken(lockers[1]);
    uint256 totalMintedAmount =
      ratios.getMintAmount(lockers[0], amounts[0]) + ratios.getMintAmount(lockers[1], amounts[1]);
    assertEq(war.totalSupply(), totalMintedAmount);
    assertEq(war.balanceOf(bob), totalMintedAmount);
  } // TODO more tests with iterative minting

  function testDefaultBehaviorWithImplicitReceiver(uint256 amount1, uint256 amount2) public {
    vm.assume(amount1 > 1e4 && amount2 > 1e4);
    vm.assume(amount1 < cvx.balanceOf(alice) && amount2 < aura.balanceOf(alice));
    address[] memory lockers = new address[](2);
    lockers[0] = address(cvx);
    lockers[1] = address(aura);
    uint256[] memory amounts = new uint256[](2);
    amounts[0] = amount1;
    amounts[1] = amount2;
    assertEq(war.totalSupply(), 0);
    assertEq(war.balanceOf(alice), 0);
    vm.prank(alice);
    minter.mintMultiple(lockers, amounts);

    //uint256 totalMintedAmount = minter.mintedSupplyPerToken(lockers[0]) + minter.mintedSupplyPerToken(lockers[1]);
    uint256 totalMintedAmount =
      ratios.getMintAmount(lockers[0], amounts[0]) + ratios.getMintAmount(lockers[1], amounts[1]);
    assertEq(war.totalSupply(), totalMintedAmount);
    assertEq(war.balanceOf(alice), totalMintedAmount);
  }

  function testCantMintWithDifferentLengths(address[] calldata lockers, uint256[] calldata amounts) public {
    vm.assume(lockers.length != amounts.length);
    vm.prank(alice);
    vm.expectRevert(abi.encodeWithSelector(Errors.DifferentSizeArrays.selector, lockers.length, amounts.length));
    minter.mintMultiple(lockers, amounts, bob);
  }

  function testCantMintWithEmptyArrays() public {
    vm.prank(alice);
    vm.expectRevert(Errors.EmptyArray.selector);
    minter.mintMultiple(new address[](0), new uint256[](0), bob);
  }
}
