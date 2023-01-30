// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {AccessControl} from "openzeppelin/contracts/access/AccessControl.sol";

contract WarToken is ERC20, AccessControl {
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  constructor(address _admin) ERC20("Warlord token", "WAR", 18) {
    _grantRole(DEFAULT_ADMIN_ROLE, _admin);
  }

  function grantAdminRole(address _minter) public onlyRole(DEFAULT_ADMIN_ROLE) {
    // TODO more than 1 admin? Capped?
    _grantRole(DEFAULT_ADMIN_ROLE, _minter);
  }

  function revokeAdmin(address _minter) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _revokeRole(DEFAULT_ADMIN_ROLE, _minter);
  }

  function grantMinterRole(address _minter) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _grantRole(MINTER_ROLE, _minter);
  }

  function revokeMinterRole(address _minter) public onlyRole(DEFAULT_ADMIN_ROLE) {
    _revokeRole(MINTER_ROLE, _minter);
  }

  function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
    _mint(to, amount);
  }

  function burn(address from, uint256 amount) public onlyRole(MINTER_ROLE) {
    _burn(from, amount);
  }
}
