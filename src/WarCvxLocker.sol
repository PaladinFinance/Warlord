// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.16;

import {IWarLocker} from "interfaces/IWarLocker.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {CvxLockerV2} from "interfaces/external/vlCvx.sol";

contract WarCvxLocker is IWarLocker {
  address _token = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
  CvxLockerV2 constant _locker = CvxLockerV2(0x72a19342e8F1838460eBFCCEf09F6585e32db86E);

  using SafeERC20 for IERC20;

  function lock(uint256 amount) external {
    IERC20(_token).safeTransferFrom(msg.sender, address(this), amount);
    IERC20(_token).safeApprove(address(_locker), amount);
    CvxLockerV2(_locker).lock(address(this), amount, 0); // TODO what is _spendRatio
  }

  function token() external view returns (address) {
    return _token;
  }
}
