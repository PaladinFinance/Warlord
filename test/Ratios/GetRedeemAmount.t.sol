// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "./RatiosTest.sol";

contract GetRedeemAmount is MintRatioTest {
  function testDefaultBehavior(uint256 initialMintAmount) public {
    address token = randomVlToken(initialMintAmount);
    vm.assume(initialMintAmount > MINT_PRECISION_LOSS);
    vm.assume(initialMintAmount <= (token == address(aura) ? AURA_MAX_SUPPLY : CVX_MAX_SUPPLY));

    uint256 amountToBurn = ratios.getMintAmount(token, initialMintAmount);
    uint256 burnedAmount = ratios.getBurnAmount(token, amountToBurn);

    // Precision correction
    initialMintAmount = initialMintAmount / MINT_PRECISION_LOSS * MINT_PRECISION_LOSS;
    burnedAmount = burnedAmount / MINT_PRECISION_LOSS * MINT_PRECISION_LOSS;

    assertEqDecimal(
      burnedAmount, initialMintAmount, 18, "The burned amount should correspond to the initial amount used to mint"
    );
  }

  function testZeroAddress(uint256 amount) public {
    vm.assume(amount != 0);

    vm.expectRevert(Errors.ZeroAddress.selector);
    ratios.getBurnAmount(zero, amount);
  }

  function testZeroAmount(address token) public {
    vm.assume(token != zero);

    vm.expectRevert(Errors.ZeroValue.selector);
    ratios.getBurnAmount(token, 0);
  }
}
