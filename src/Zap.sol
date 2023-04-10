pragma solidity 0.8.16;
//SPDX-License-Identifier: MIT

import {Owner} from "utils/Owner.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "openzeppelin/security/Pausable.sol";
import {ReentrancyGuard} from "openzeppelin/security/ReentrancyGuard.sol";
import {Errors} from "utils/Errors.sol";
import {IStaker} from "interfaces/IStaker.sol";
import {IMinter} from "interfaces/IMinter.sol";

/**
 * @title Warlord Zap contract
 * @author xx
 * @notice Zap to mint WAR & stake it directly
 */
contract WarZap is ReentrancyGuard, Pausable, Owner {
    using SafeERC20 for IERC20;

    IStaker public immutable staker;
    IMinter public immutable minter;
    IERC20 public immutable warToken;

    constructor(
        address _staker,
        address _minter,
        address _warToken
    ) {
        if (_staker == address(0) || _minter == address(0) || _warToken == address(0)) revert Errors.ZeroAddress();
        staker = IStaker(_staker);
        minter = IMinter(_minter);
        warToken = IERC20(_warToken);

        IERC20(_warToken).safeApprove(_staker, type(uint256).max);
    }

    function zap(
        address token,
        uint256 amount,
        address receiver
    ) external nonReentrant whenNotPaused {
        if(amount == 0) revert Errors.ZeroValue();
        if(token == address(0) || receiver == address(0)) revert Errors.ZeroAddress();

        uint256 prevBalance = IERC20(warToken).balanceOf(address(this));

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        
        IERC20(token).safeIncreaseAllowance(address(minter), amount);
        minter.mint(token, amount);

        uint256 mintedAmount = IERC20(warToken).balanceOf(address(this)) - prevBalance;

        staker.stake(mintedAmount, receiver);
    }

    function zapMultiple(
        address[] calldata vlTokens,
        uint256[] calldata amounts,
        address receiver
    ) external nonReentrant whenNotPaused {
        if(receiver == address(0)) revert Errors.ZeroAddress();
        uint256 length = vlTokens.length;
        if(length != amounts.length) revert Errors.DifferentSizeArrays(length, amounts.length);
        if(length == 0) revert Errors.EmptyArray();

        uint256 prevBalance = IERC20(warToken).balanceOf(address(this));

        for(uint256 i; i < length;) {
            address token = vlTokens[i];
            uint256 amount = amounts[i];
            if(amount == 0) revert Errors.ZeroValue();
            if(token == address(0)) revert Errors.ZeroAddress();

            IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        
            IERC20(token).safeIncreaseAllowance(address(minter), amount);
            minter.mint(token, amount);

            unchecked { i++; }
        }

        uint256 mintedAmount = IERC20(warToken).balanceOf(address(this)) - prevBalance;

        staker.stake(mintedAmount, receiver);
    }

}