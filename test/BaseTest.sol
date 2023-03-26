// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import "forge-std/Test.sol";
import {Errors} from "src/utils/Errors.sol";
import {IERC20} from "openzeppelin/interfaces/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import "solgen/Generators.sol";

contract BaseTest is Test {
  using SafeERC20 for IERC20;
  // Useful addresses

  address alice = makeAddr("alice");
  address bob = makeAddr("bob");
  address admin = makeAddr("admin");
  address zero = address(0);
}

contract MockERC20 is ERC20 {
  constructor() ERC20("MockToken", "MCK", 18) {}
}

// make a function that takes a list of addresses and returns a random one
function randomAddress(address[] memory addrs, uint256 seed) pure returns (address) {
  return addrs[seed % addrs.length];
}

function randomBinaryAddress(address option1, address option2, uint256 seed) pure returns (address) {
  // implement using previous function
  address[] memory options = new address[](2);
  options[0] = option1;
  options[1] = option2;
  return randomAddress(options, seed);
}

function randomBoolean(uint256 seed) pure returns (bool) {
  return seed % 2 == 0;
}

function generateAddressArray(uint256 size) pure returns (address[] memory addrArray) {
  // TODO generate with keccak
  if (size == 0) return new address[](0);
  uint256[] memory numArray = linspace(uint256(0), uint256(uint160(0x9999999999999999999999999999999999999999)), size);
  addrArray = new address[](size);
  for (uint256 i; i < size; ++i) {
    addrArray[i] = address(uint160(numArray[i]));
  }
}

function generateAddressArrayFromHash(uint256 seed, uint256 len) pure returns (address[] memory addrArray) {
  seed = seed % 1e77;
  if (len == 0) return new address[](0);
  addrArray = new address[](len);
  for (uint256 i; i < len; ++i) {
    addrArray[i] = address(uint160(bytes20((keccak256(abi.encode(seed + i))))));
  }
}

function generateNumberArrayFromHash(uint256 seed, uint256 len, uint256 upperBound)
  pure
  returns (uint256[] memory numArray)
{
  seed = seed % 1e77;
  if (len == 0) return new uint256[](0);
  numArray = new uint256[](len);
  for (uint256 i; i < len; ++i) {
    // numArray[i] = uint160(bytes20((keccak256(abi.encode(seed + i)))));
    numArray[i] = uint256((keccak256(abi.encode(seed + i)))) % upperBound + 1;
  }
}
