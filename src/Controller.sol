pragma solidity 0.8.16;
//SPDX-License-Identifier: MIT

import {Owner} from "utils/Owner.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin/security/Pausable.sol";
import "openzeppelin/security/ReentrancyGuard.sol";
import {Errors} from "utils/Errors.sol";
import {IHarvestable} from "interfaces/IHarvestable.sol";
import {IMinter} from "interfaces/IMinter.sol";
import {IStaker} from "interfaces/IStaker.sol";

/**
 * @title Warlord Controller contract
 * @author xx
 * @notice Controoler to harvest from Locker & Farmer and process the rewards 
 */
contract Controller is ReentrancyGuard, Pausable, Owner {
    using SafeERC20 for IERC20;

    // Constants

    /** @notice 1e18 scale */
    uint256 public constant UNIT = 1e18;


    // Storage

    address public immutable war;

    IMinter public minter;

    IStaker public staker;

    address public swapper;

    address[] public lockers;
    address[] public farmers;

    mapping(address => address) public tokenLockers;
    mapping(address => address) public tokenFarmer;
    mapping(address => bool) public distributionTokens;

    mapping(address => uint256) public swapperAmounts;


    // Events

    // to do


    // Modifiers

    modifier onlySwapper() {
        if(msg.sender != swapper) revert Errors.CallerNotAllowed();
        _;
    }


    // Constructor

    constructor(
        address _war,
        address _minter,
        address _staker,
        address _swapper
    ) {
        if (
            _war == address(0)
            || _minter == address(0)
            || _staker == address(0)
            || _swapper == address(0)
        ) revert Errors.ZeroAddress();

        war = _war;
        swapper = _swapper;
        minter = IMinter(_minter);
        staker = IStaker(_staker);
    }


    // State changing functions


    // Internal functions


    // Admin functions

    // set minter

    // set staker

    // set swapper

    // set locker

    // set farmer

    // set distribution token

}