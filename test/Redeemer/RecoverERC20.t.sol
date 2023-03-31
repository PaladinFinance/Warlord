pragma solidity 0.8.16;
//SPDX-License-Identifier: MIT

import "./RedeemerTest.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract RecoverERC20 is RedeemerTest {
  RandomERC20 r;

  function setUp() public override {
    RedeemerTest.setUp();
    r = new RandomERC20(address(redeemer));
  }

  function testDefaultBehavior(uint256 amount) public {
    r.sendAmount(amount);

    vm.prank(admin);
    redeemer.recoverERC20(address(r));
    assertEqDecimal(r.balanceOf(admin), amount, 18, "Recovered amount should be the minted one");
  }

  function recoverForbidden(address token, uint256 amount) public {
    deal(token, address(redeemer), amount);

    vm.expectRevert(Errors.RecoverForbidden.selector);

    vm.prank(admin);
    redeemer.recoverERC20(token);
  }

  function testRecoverForbiddenWar(uint256 amount) public {
    recoverForbidden(address(war), amount);
  }

  function testRecoverForbiddenAuraBal(uint256 amount) public {
    recoverForbidden(address(aura), amount);
  }

  function testRecoverForbiddenCvxCrv(uint256 amount) public {
    recoverForbidden(address(cvx), amount);
  }

  function testOnlyOwner() public {
    vm.expectRevert("Ownable: caller is not the owner");
    redeemer.recoverERC20(address(r));
  }
}

contract RandomERC20 is ERC20 {
  address redeemer;

  constructor(address _redeemer) ERC20("Random", "RDM", 18) {
    redeemer = _redeemer;
  }

  function sendAmount(uint256 amount) public {
    _mint(redeemer, amount);
  }
}
