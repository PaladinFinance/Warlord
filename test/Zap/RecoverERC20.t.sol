pragma solidity 0.8.16;
//SPDX-License-Identifier: MIT

import "./ZapTest.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract RecoverERC20 is ZapTest {
  RandomERC20 r;

  function setUp() public override {
    ZapTest.setUp();
    r = new RandomERC20(address(zap));
  }

  function testDefaultBehavior(uint256 amount) public {
    vm.assume(amount > 0);

    r.sendAmount(amount);

    vm.prank(admin);
    zap.recoverERC20(address(r));
    assertEqDecimal(r.balanceOf(admin), amount, 18, "Recovered amount should be the minted one");
  }

  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    zap.recoverERC20(zero);
  }

  function testZeroValue() public {
    vm.expectRevert(Errors.ZeroValue.selector);

    vm.prank(admin);
    zap.recoverERC20(address(r));
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    zap.recoverERC20(address(r));
  }
}

contract RandomERC20 is ERC20 {
  address zap;

  constructor(address _zap) ERC20("Random", "RDM", 18) {
    zap = _zap;
  }

  function sendAmount(uint256 amount) public {
    _mint(zap, amount);
  }
}
