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
import {IFarmer} from "interfaces/IFarmer.sol";
import {IIncentivizedLocker} from "interfaces/IIncentivizedLocker.sol";
import "interfaces/external/incentives/IIncentivesDistributors.sol";

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
    uint256 public constant MAX_BPS = 10_000;


    // Storage

    address public immutable war;

    IMinter public minter;

    IStaker public staker;

    address public swapper;

    address public incentivesClaimer;

    uint256 public feeRatio = 500;
    address public feeReceiver;

    address[] public lockers;
    address[] public farmers;

    mapping(address => address) public tokenLockers;
    mapping(address => address) public tokenFarmers;
    mapping(address => bool) public distributionTokens;

    mapping(address => uint256) public swapperAmounts;


    // Events

    event PullTokens(address indexed swapper, address indexed token, uint256 amount);

    event SetMinter(address oldMinter, address newMinter);
    event SetStaker(address oldStaker, address newStaker);
    event SetSwapper(address oldSwapper, address newSwapper);
    event SetFeeReceiver(address oldFeeReceiver, address newFeeReceiver);
    event SetIncentivesClaimer(address oldIncentivesClaimer, address newIncentivesClaimer);

    event SetFeeRatio(uint256 oldFeeRatio, uint256 newFeeRatio);

    event SetLocker(address indexed token, address locker);
    event SetFarmer(address indexed token, address famer);
    event SetDistributionToken(address indexed token, bool distribution);


    // Modifiers

    modifier onlySwapper() {
        if(msg.sender != swapper) revert Errors.CallerNotAllowed();
        _;
    }

    modifier onlyIncentivesClaimer() {
        if(msg.sender != incentivesClaimer) revert Errors.CallerNotAllowed();
        _;
    }


    // Constructor

    constructor(
        address _war,
        address _minter,
        address _staker,
        address _swapper,
        address _incentivesClaimer
    ) {
        if (
            _war == address(0)
            || _minter == address(0)
            || _staker == address(0)
            || _swapper == address(0)
            || _incentivesClaimer == address(0)
        ) revert Errors.ZeroAddress();

        war = _war;
        swapper = _swapper;
        minter = IMinter(_minter);
        staker = IStaker(_staker);
        incentivesClaimer = _incentivesClaimer;
    }


    // State changing functions

    function harvest(address target) external nonReentrant whenNotPaused {
        IHarvestable(target).harvest();
    }

    function harvestMultiple(address[] calldata targets) external nonReentrant whenNotPaused {
        uint256 length = targets.length;
        if(length == 0) revert Errors.EmptyArray();

        for(uint256 i; i < length;) {
            IHarvestable(targets[i]).harvest();

            unchecked { i++; }
        }
    }

    function harvestAll() external nonReentrant whenNotPaused {
        address[] memory _lockers = lockers;
        address[] memory _farmers = farmers;
        uint256 lockersLength = _lockers.length;
        uint256 farmersLength = _farmers.length;

        for(uint256 i; i < lockersLength;) {
            IHarvestable(_lockers[i]).harvest();

            unchecked { i++; }
        }

        for(uint256 i; i < farmersLength;) {
            IHarvestable(_farmers[i]).harvest();

            unchecked { i++; }
        }
    }

    function process(address token) external nonReentrant whenNotPaused {
        _processReward(token);
    }

    function processMultiple(address[] calldata tokens) external nonReentrant whenNotPaused {
        _processMultiple(tokens);
    }

    function harvestAndProcess(address target) external nonReentrant whenNotPaused {
        IHarvestable(target).harvest();
        
    }

    function harvestAllAndProcessAll() external nonReentrant whenNotPaused {
        address[] memory _lockers = lockers;
        address[] memory _farmers = farmers;
        uint256 lockersLength = _lockers.length;
        uint256 farmersLength = _farmers.length;

        for(uint256 i; i < lockersLength;) {
            IHarvestable(_lockers[i]).harvest();

            _processMultiple(IHarvestable(_lockers[i]).rewardTokens());

            unchecked { i++; }
        }

        for(uint256 i; i < farmersLength;) {
            IHarvestable(_farmers[i]).harvest();

            _processMultiple(IHarvestable(_farmers[i]).rewardTokens());

            unchecked { i++; }
        }

    }

    function pullToken(address token) external nonReentrant whenNotPaused onlySwapper {
        _pullToken(token);
    }

    function pullMultipleTokens(address[] calldata tokens) external nonReentrant whenNotPaused onlySwapper {
        uint256 length = tokens.length;
        if(length == 0) revert Errors.EmptyArray();

        for(uint256 i; i < length;) {
            _pullToken(tokens[i]);

            unchecked { i++; }
        }
    }

    function claimQuestRewards(
        address locker,
        address distributor,
        IQuestDistributor.ClaimParams[] calldata claimParams
    ) external nonReentrant whenNotPaused onlyIncentivesClaimer {
        if (locker == address(0)|| distributor == address(0)) revert Errors.ZeroAddress();

        uint256 length = claimParams.length;
        if(length == 0) revert Errors.EmptyArray();

        for(uint256 i; i < length;) {
            IIncentivizedLocker(locker).claimQuestRewards(
                distributor,
                claimParams[i].questID,
                claimParams[i].period,
                claimParams[i].index,
                locker,
                claimParams[i].amount,
                claimParams[i].merkleProof
            );

            unchecked { i++; }
        }
    }

    function claimDelegationRewards(
        address locker,
        address distributor,
        IDelegationDistributor.ClaimParams[] calldata claimParams
    ) external nonReentrant whenNotPaused onlyIncentivesClaimer {
        if (locker == address(0)|| distributor == address(0)) revert Errors.ZeroAddress();

        uint256 length = claimParams.length;
        if(length == 0) revert Errors.EmptyArray();

        for(uint256 i; i < length;) {
            IIncentivizedLocker(locker).claimDelegationRewards(
                distributor,
                claimParams[i].token,
                claimParams[i].index,
                locker,
                claimParams[i].amount,
                claimParams[i].merkleProof
            );

            unchecked { i++; }
        }
    }

    function claimVotiumRewards(
        address locker,
        address distributor,
        IVotiumDistributor.claimParam[] calldata claimParams
    ) external nonReentrant whenNotPaused onlyIncentivesClaimer {
        if (locker == address(0)|| distributor == address(0)) revert Errors.ZeroAddress();

        uint256 length = claimParams.length;
        if(length == 0) revert Errors.EmptyArray();

        for(uint256 i; i < length;) {
            IIncentivizedLocker(locker).claimVotiumRewards(
                distributor,
                claimParams[i].token,
                claimParams[i].index,
                locker,
                claimParams[i].amount,
                claimParams[i].merkleProof
            );

            unchecked { i++; }
        }
    }

    function claimHiddenHandsRewards(
        address locker,
        address distributor,
        IHiddenHandsDistributor.Claim[] memory claimParams
    ) external nonReentrant whenNotPaused onlyIncentivesClaimer {
        if (locker == address(0)|| distributor == address(0)) revert Errors.ZeroAddress();

        uint256 length = claimParams.length;
        if(length == 0) revert Errors.EmptyArray();

        for(uint256 i; i < length;) {
            IHiddenHandsDistributor.Claim[] memory claim = new IHiddenHandsDistributor.Claim[](1);
            claim[0] = claimParams[i];
            IIncentivizedLocker(locker).claimHiddenHandsRewards(
                distributor,
                claim
            );

            unchecked { i++; }
        }
    }


    // Internal functions

    function _processReward(address token) internal {
        IERC20 _token = IERC20(token);
        uint256 currentBalance = _token.balanceOf(address(this));

        uint256 feeAmount = (currentBalance * feeRatio) / MAX_BPS;
        uint256 processAmount = currentBalance - feeAmount;

        _sendFees(token, feeAmount);

        if(tokenLockers[token] != address(0)){
            if(_token.allowance(address(this), address(minter)) != 0) _token.safeApprove(address(minter), 0);
            _token.safeIncreaseAllowance(address(minter), processAmount);
            minter.mint(token, processAmount);

            IERC20 _war = IERC20(war);
            uint256 warBalance = _war.balanceOf(address(this));
            _war.safeTransfer(address(staker), warBalance);
            staker.queueRewards(war, warBalance);
        } 
        else if(tokenFarmers[token] != address(0)){
            address _farmer = tokenFarmers[token];
            if(_token.allowance(address(this), _farmer) != 0) _token.safeApprove(_farmer, 0);
            _token.safeIncreaseAllowance(_farmer, processAmount);
            IFarmer(_farmer).stake(token, processAmount);
        } 
        else if(distributionTokens[token]){
            _token.safeTransfer(address(staker), processAmount);
            staker.queueRewards(token, processAmount);
        } 
        else {
            swapperAmounts[token] += processAmount;
        }
    }

    function _processMultiple(address[] memory tokens) internal {
        uint256 length = tokens.length;

        for(uint256 i; i < length;) {
            _processReward(tokens[i]);

            unchecked { i++; }
        }
    }

    function _pullToken(address token) internal {
        uint256 amount = swapperAmounts[token];
        swapperAmounts[token] = 0;

        IERC20(token).safeTransfer(swapper, amount);

        emit PullTokens(msg.sender, token, amount);
    }

    function _sendFees(address token, uint256 amount) internal {
        IERC20(token).safeTransfer(feeReceiver, amount);
    }


    // Admin functions

    function setMinter(address newMinter) external onlyOwner {
        if (newMinter == address(0)) revert Errors.ZeroAddress();
        if (newMinter == address(minter)) revert Errors.AlreadySet();

        address oldMinter = address(minter);
        minter = IMinter(newMinter);

        emit SetMinter(oldMinter, newMinter);
    }

    function setStaker(address newStaker) external onlyOwner {
        if (newStaker == address(0)) revert Errors.ZeroAddress();
        if (newStaker == address(staker)) revert Errors.AlreadySet();

        address oldStaker = address(staker);
        staker = IStaker(newStaker);

        emit SetStaker(oldStaker, newStaker);
    }

    function setSwapper(address newSwapper) external onlyOwner {
        if (newSwapper == address(0)) revert Errors.ZeroAddress();
        if (newSwapper == swapper) revert Errors.AlreadySet();

        address oldSwapper = swapper;
        swapper = newSwapper;

        emit SetSwapper(oldSwapper, newSwapper);
    }

    function setIncentivesClaimer(address newIncentivesClaimer) external onlyOwner {
        if (newIncentivesClaimer == address(0)) revert Errors.ZeroAddress();
        if (newIncentivesClaimer == incentivesClaimer) revert Errors.AlreadySet();

        address oldIncentivesClaimer = incentivesClaimer;
        incentivesClaimer = newIncentivesClaimer;

        emit SetIncentivesClaimer(oldIncentivesClaimer, newIncentivesClaimer);
    }

    function setFeeReceiver(address newFeeReceiver) external onlyOwner {
        if (newFeeReceiver == address(0)) revert Errors.ZeroAddress();
        if (newFeeReceiver == feeReceiver) revert Errors.AlreadySet();

        address oldFeeReceiver = feeReceiver;
        feeReceiver = newFeeReceiver;

        emit SetFeeReceiver(oldFeeReceiver, newFeeReceiver);
    }

    function setFeeRatio(uint256 newFeeRatio) external onlyOwner {
        if (newFeeRatio > 1000) revert Errors.InvalidFeeRatio();

        uint256 oldFeeRatio = feeRatio;
        feeRatio = newFeeRatio;

        emit SetFeeRatio(oldFeeRatio, newFeeRatio);
    }

    function setLocker(address token, address locker) external onlyOwner {
        if (token == address(0) || locker == address(0)) revert Errors.ZeroAddress();

        if(tokenLockers[token] == address(0)) {
            lockers.push(token);
        } else {
            address oldLocker = tokenLockers[token];
            address[] memory _lockers = lockers;
            uint256 length = _lockers.length;
            uint256 lastIndex = length - 1;
            for(uint256 i; i < length;){
                if(_lockers[i] == oldLocker){
                    if(i != lastIndex){
                        lockers[i] = _lockers[lastIndex];
                    }

                    lockers.pop();

                    break;
                }

                unchecked{ ++i; }
            }
            lockers.push(locker);
        }

        tokenLockers[token] = locker;

        emit SetLocker(token, locker);
    }

    function setFarmer(address token, address farmer) external onlyOwner {
        if (token == address(0) || farmer == address(0)) revert Errors.ZeroAddress();
        if (tokenLockers[token] != address(0)) revert Errors.ListedLocker();

        if(tokenFarmers[token] == address(0)) {
            farmers.push(token);
        } else {
            address oldFarmer = tokenFarmers[token];
            address[] memory _farmers = farmers;
            uint256 length = _farmers.length;
            uint256 lastIndex = length - 1;
            for(uint256 i; i < length;){
                if(_farmers[i] == oldFarmer){
                    if(i != lastIndex){
                        farmers[i] = _farmers[lastIndex];
                    }

                    farmers.pop();

                    break;
                }

                unchecked{ ++i; }
            }
            farmers.push(farmer);
        }

        tokenFarmers[token] = farmer;

        emit SetFarmer(token, farmer);
    }

    function setDistributionToken(address token, bool distribution) external onlyOwner {
        if (token == address(0)) revert Errors.ZeroAddress();
        if (tokenLockers[token] != address(0)) revert Errors.ListedLocker();
        if (tokenFarmers[token] != address(0)) revert Errors.ListedFarmer();

        distributionTokens[token] = distribution;

        emit SetDistributionToken(token, distribution);
    }

}