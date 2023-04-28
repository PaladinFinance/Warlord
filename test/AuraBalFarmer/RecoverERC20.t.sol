pragma solidity 0.8.16;
//SPDX-License-Identifier: MIT

import "./AuraBalFarmerTest.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract RecoverERC20 is AuraBalFarmerTest {
  RandomERC20 r;

  function setUp() public override {
    AuraBalFarmerTest.setUp();
    r = new RandomERC20(address(auraBalFarmer));
  }

  function testDefaultBehavior(uint256 amount) public {
    vm.assume(amount > 0);

    r.sendAmount(amount);

    vm.prank(admin);
    auraBalFarmer.recoverERC20(address(r));
    assertEqDecimal(r.balanceOf(admin), amount, 18, "Recovered amount should be the minted one");
  }

  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    auraBalFarmer.recoverERC20(zero);
  }

  function testZeroValue() public {
    vm.expectRevert(Errors.ZeroValue.selector);

    vm.prank(admin);
    auraBalFarmer.recoverERC20(address(r));
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    auraBalFarmer.recoverERC20(address(r));
  }
}

contract RandomERC20 is ERC20 {
  address auraBalFarmer;

  constructor(address _auraBalFarmer) ERC20("Random", "RDM", 18) {
    auraBalFarmer = _auraBalFarmer;
  }

  function sendAmount(uint256 amount) public {
    _mint(auraBalFarmer, amount);
  }
}
