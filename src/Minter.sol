//██████╗  █████╗ ██╗      █████╗ ██████╗ ██╗███╗   ██╗
//██╔══██╗██╔══██╗██║     ██╔══██╗██╔══██╗██║████╗  ██║
//██████╔╝███████║██║     ███████║██║  ██║██║██╔██╗ ██║
//██╔═══╝ ██╔══██║██║     ██╔══██║██║  ██║██║██║╚██╗██║
//██║     ██║  ██║███████╗██║  ██║██████╔╝██║██║ ╚████║
//╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝

pragma solidity 0.8.16;
//SPDX-License-Identifier: BUSL-1.1

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {WarToken} from "./Token.sol";
import {IWarLocker} from "interfaces/IWarLocker.sol";
import {IRatios} from "interfaces/IRatios.sol";
import {Owner} from "utils/Owner.sol";
import {Errors} from "utils/Errors.sol";
import {ReentrancyGuard} from "openzeppelin/security/ReentrancyGuard.sol";

contract WarMinter is Owner, ReentrancyGuard {
  // 10_000 tokens (with 18 decimals)
  uint256 private constant MAX_SUPPLY_PER_TOKEN = 10_000 * 1e18;

  WarToken public war;
  IRatios public ratios;
  mapping(address => address) public lockers;
  mapping(address => uint256) public mintedSupplyPerToken;

  using SafeERC20 for IERC20;

  constructor(address _war, address _ratios) {
    if (_war == address(0) || _ratios == address(0)) revert Errors.ZeroAddress();
    war = WarToken(_war);
    ratios = IRatios(_ratios);
  }

  function setMintRatio(address _ratios) external onlyOwner {
    if (_ratios == address(0)) revert Errors.ZeroAddress();
    ratios = IRatios(_ratios);
  }

  function setLocker(address vlToken, address warLocker) external onlyOwner {
    if (vlToken == address(0) || warLocker == address(0)) revert Errors.ZeroAddress();
    address expectedToken = IWarLocker(warLocker).token();
    if (expectedToken != vlToken) revert Errors.MismatchingLocker(expectedToken, vlToken);
    lockers[vlToken] = warLocker;
  }

  function mint(address vlToken, uint256 amount) external nonReentrant {
    _mint(vlToken, amount, msg.sender);
  }

  function mint(address vlToken, uint256 amount, address receiver) external nonReentrant {
    _mint(vlToken, amount, receiver);
  }

  function _mint(address vlToken, uint256 amount, address receiver) internal {
    if (amount == 0) revert Errors.ZeroValue();
    if (vlToken == address(0) || receiver == address(0)) revert Errors.ZeroAddress();
    if (lockers[vlToken] == address(0)) revert Errors.NoWarLocker();

    IWarLocker locker = IWarLocker(lockers[vlToken]);

    IERC20(vlToken).safeTransferFrom(msg.sender, address(this), amount);
    IERC20(vlToken).safeApprove(address(locker), 0);
    IERC20(vlToken).safeIncreaseAllowance(address(locker), amount);
    locker.lock(amount);

    uint256 mintAmount = ratios.getMintAmount(vlToken, amount);
    if (mintAmount == 0) revert Errors.ZeroMintAmount();
    mintedSupplyPerToken[vlToken] += mintAmount;
    if (mintedSupplyPerToken[vlToken] > MAX_SUPPLY_PER_TOKEN) revert Errors.MintAmountBiggerThanSupply();
    war.mint(receiver, mintAmount);
  }

  function _mintMultiple(address[] calldata vlTokens, uint256[] calldata amounts, address receiver) internal {
    if (vlTokens.length != amounts.length) revert Errors.DifferentSizeArrays(vlTokens.length, amounts.length);
    if (vlTokens.length == 0) revert Errors.EmptyArray();
    uint256 length = vlTokens.length;
    for (uint256 i; i < length;) {
      _mint(vlTokens[i], amounts[i], receiver);
      unchecked {
        ++i;
      }
    }
  }

  function mintMultiple(address[] calldata vlTokens, uint256[] calldata amounts, address receiver)
    external
    nonReentrant
  {
    _mintMultiple(vlTokens, amounts, receiver);
  }

  function mintMultiple(address[] calldata vlTokens, uint256[] calldata amounts) external nonReentrant {
    _mintMultiple(vlTokens, amounts, msg.sender);
  }

  /**
   * @notice Recover ERC2O tokens in the contract
   * @dev Recover ERC2O tokens in the contract
   * @param token Address of the ERC2O token
   * @return bool: success
   */
  function recoverERC20(address token) external onlyOwner returns (bool) {
    if (token == address(0)) revert Errors.ZeroAddress();
    uint256 amount = IERC20(token).balanceOf(address(this));
    if (amount == 0) revert Errors.ZeroValue();
    IERC20(token).safeTransfer(msg.sender, amount);

    return true;
  }
}
