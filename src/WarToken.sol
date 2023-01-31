// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {ERC20} from "solmate/tokens/ERC20.sol";
import {AccessControl} from "openzeppelin/contracts/access/AccessControl.sol";
import {CannotBeOwner, CallerNotPendingOwner, ZeroAddress} from "./Errors.sol";

contract WarToken is ERC20, AccessControl {
  event NewPendingOwner(address indexed previousPendingOwner, address indexed newPendingOwner);

  address public pendingOwner;
  address public owner;
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

  constructor(address _owner) ERC20("Warlord token", "WAR", 18) {
    owner = _owner;
    _grantRole(DEFAULT_ADMIN_ROLE, owner);
    _setRoleAdmin(DEFAULT_ADMIN_ROLE, keccak256("NO_ROLE"));
  }

  function transferOwnership(address newOwner) public onlyRole(DEFAULT_ADMIN_ROLE) {
    if (newOwner == address(0)) revert ZeroAddress();
    if (newOwner == owner) revert CannotBeOwner();

    address oldPendingOwner = pendingOwner;

    pendingOwner = newOwner;

    emit NewPendingOwner(oldPendingOwner, newOwner);
  }

  function acceptOwnership() public {
    if (msg.sender != pendingOwner) revert CallerNotPendingOwner();
    address newOwner = pendingOwner;

    _revokeRole(DEFAULT_ADMIN_ROLE, owner);
    _grantRole(DEFAULT_ADMIN_ROLE, newOwner);

    owner = pendingOwner;
    pendingOwner = address(0);

    emit NewPendingOwner(newOwner, address(0));
  }

  function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
    _mint(to, amount);
  }

  function burn(address from, uint256 amount) public onlyRole(BURNER_ROLE) {
    _burn(from, amount);
  }
}
