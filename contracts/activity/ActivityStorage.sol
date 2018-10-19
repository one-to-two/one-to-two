pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Whitelist.sol";

contract ActivityStorage is Whitelist {
    using SafeMath for uint256;

    uint256 constant public DAY_IN_SECONDS = 24 * 60 * 60;

    uint256 public activityNumber;
    uint256 public lastMonthActivity;

    mapping(uint256 => mapping(address => uint256)) public activity;

    function updateMonthActivity() public onlyWhitelisted {
      uint256 currentMonthActivity = _calculateMonthActivity();
      if (lastMonthActivity == 0 || lastMonthActivity != currentMonthActivity) {
        if (lastMonthActivity > 0) {
          activityNumber = activityNumber.add(1);
        }
        lastMonthActivity =  currentMonthActivity;
      }
    }

    function incrementActivity(address _player) public onlyWhitelisted {
      activity[activityNumber][_player] = activity[activityNumber][_player].add(1);
    }

    function getActivity(address _player) public view returns (uint256) {
      return getActivity(activityNumber, _player);
    }

    function getActivity(uint256 _activityNumber, address _player) public view returns (uint256) {
      return activity[_activityNumber][_player];
    }

    function getActivityNumber() public view returns (uint256) {
      return activityNumber;
    }

    // TODO: optimize
    function _calculateMonthActivity() internal view returns(uint256) {
      uint256 thirtyDaysInSeconds = 30 * DAY_IN_SECONDS;
      uint256 thirtyOneDaysInSeconds = 31 * DAY_IN_SECONDS;
      uint256 yearInSeconds = 365 * DAY_IN_SECONDS;
      uint256 leapYearInSeconds = 366 * DAY_IN_SECONDS;
      uint256 restSec = now % (3 * yearInSeconds + leapYearInSeconds);
      uint256 leakY = 0;
      uint256 M2 = 31 * DAY_IN_SECONDS + 28 * DAY_IN_SECONDS;
      uint256 ourMonth = 1;
      if (restSec >= (2 * yearInSeconds + leapYearInSeconds)) {
        restSec = restSec - (2 * yearInSeconds + leapYearInSeconds);
      }
      if (restSec >= 2 * yearInSeconds) {
        restSec = restSec - 2 * yearInSeconds;
        leakY = 1;
      }
      if (restSec >= yearInSeconds) {
        restSec = restSec - yearInSeconds;
      }
      if (leakY == 1) {
        M2 = M2 + DAY_IN_SECONDS;
      }
      if (restSec >= (M2 + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds)) {
        ourMonth = 12;
        restSec = restSec - (M2 + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds);
      }
      if (restSec >= (M2 + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds)) {
        ourMonth = 11;
        restSec = restSec - (M2 + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds);
      }
      if (restSec >= (M2 + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds)) {
        ourMonth = 10;
        restSec = restSec - (M2 + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds);
      }
      if (restSec >= (M2 + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyOneDaysInSeconds)) {
        ourMonth = 9;
        restSec = restSec - (M2 + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyOneDaysInSeconds);
      }
      if (restSec >= (M2 + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds)) {
        ourMonth = 8;
        restSec = restSec - (M2 + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds);
      }
      if (restSec >= (M2 + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds)) {
        ourMonth = 7;
        restSec = restSec - (M2 + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds + thirtyDaysInSeconds);
      }
      if (restSec >= (M2 + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds)) {
        ourMonth = 6;
        restSec = restSec - (M2 + thirtyOneDaysInSeconds + thirtyDaysInSeconds + thirtyOneDaysInSeconds);
      }
      if (restSec >= (M2 + thirtyOneDaysInSeconds + thirtyDaysInSeconds)) {
        ourMonth = 5;
        restSec = restSec - (M2 + thirtyOneDaysInSeconds + thirtyDaysInSeconds);
      }
      if (restSec >= (M2 + thirtyOneDaysInSeconds)) {
        ourMonth = 4;
        restSec = restSec - (M2 + thirtyOneDaysInSeconds);
      }
      if (restSec >= M2) {
        ourMonth = 3;
        restSec = restSec - M2;
      }
      if (restSec >= thirtyOneDaysInSeconds) {
        ourMonth = 2;
        restSec = restSec - thirtyOneDaysInSeconds;
      }
      return ourMonth;
    }

}
