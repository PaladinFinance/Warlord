// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {AccessControl} from "openzeppelin/contracts/access/AccessControl.sol";

contract WarToken is ERC20, AccessControl {
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  constructor(address _admin) ERC20("Warlord token", "WAR", 18) {
    _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    _setRoleAdmin(MINTER_ROLE, DEFAULT_ADMIN_ROLE);
  }

  function updateAdmin(address _newAdmin) public onlyRole(DEFAULT_ADMIN_ROLE) {
    // address oldMinter =
    // _revokeRole(DEFAULT_ADMIN_ROLE, _minter);
    _grantRole(DEFAULT_ADMIN_ROLE, _newAdmin);
  }

  function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
    _mint(to, amount);
  }

  function burn(address from, uint256 amount) public onlyRole(MINTER_ROLE) {
    _burn(from, amount);
  }
}
