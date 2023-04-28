pragma solidity 0.8.16;
//SPDX-License-Identifier: MIT

import "./CvxLockerTest.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract RecoverERC20 is CvxLockerTest {
  RandomERC20 r;

  function setUp() public override {
    CvxLockerTest.setUp();
    r = new RandomERC20(address(locker));
  }

  function testDefaultBehavior(uint256 amount) public {
    vm.assume(amount > 0);

    r.sendAmount(amount);

    vm.prank(admin);
    locker.recoverERC20(address(r));
    assertEqDecimal(r.balanceOf(admin), amount, 18, "Recovered amount should be the minted one");
  }

  function recoverForbidden(address token, uint256 amount) public {
    vm.assume(amount > 0);

    deal(token, address(locker), amount);

    vm.expectRevert(Errors.RecoverForbidden.selector);

    vm.prank(admin);
    locker.recoverERC20(token);
  }

  function testRecoverForbidden(uint256 amount) public {
    recoverForbidden(address(cvx), amount);
  }


  function testZeroAddress() public {
    vm.expectRevert(Errors.ZeroAddress.selector);

    vm.prank(admin);
    locker.recoverERC20(zero);
  }

  function testZeroValue() public {
    vm.expectRevert(Errors.ZeroValue.selector);

    vm.prank(admin);
    locker.recoverERC20(address(r));
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    locker.recoverERC20(address(r));
  }
}

contract RandomERC20 is ERC20 {
  address locker;

  constructor(address _locker) ERC20("Random", "RDM", 18) {
    locker = _locker;
  }

  function sendAmount(uint256 amount) public {
    _mint(locker, amount);
  }
}
