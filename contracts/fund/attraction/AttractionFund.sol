pragma solidity ^0.4.17;

import "../../score/ScoreInterface.sol";
import "../../referrer/ReferrerStorage.sol";
import "../../activity/ActivityStorage.sol";
import "../Fund.sol";
import "./AttractionFundInterface.sol";

contract AttractionFund is Fund, AttractionFundInterface {

  mapping(uint256 => mapping(address => uint256)) public attraction;

  ScoreInterface internal score;
  ActivityStorage internal activityStorage;
  ReferrerStorage internal referrerStorage;

  event BetReturn(address indexed _attracted, uint256 _return);
  event Rebate(address indexed _attracted, uint256 _return);
  event PaidToReferrer(address indexed _referrer, uint256 _return);

  function AttractionFund(address _bankAddress) Fund(_bankAddress) public {
  }

  function add(uint256 _amount, address _player, address _referrer, bool isAmountReturned) public onlyWhitelisted {
    address realReferrer = referrerStorage.getReferrer(_player);
    uint256 realAmount = _amount;
    if (realReferrer == address(0) && _referrer != address(0) && _referrer != _player && _hasNoActivity(_player)) {
      realReferrer = _referrer;
      referrerStorage.setReferrer(_player, realReferrer);
    }
    if (realReferrer != address(0) && !isAmountReturned){
      realAmount = _amount * 75 / 100;
      uint256 toReferrer = _amount - realAmount;
      bank.addDeposit(realReferrer, toReferrer);
      PaidToReferrer(realReferrer, toReferrer);
      score.addAmount(realReferrer, toReferrer);
    }
    value = value.add(realAmount);
  }

  function setScoreAddress(address _address) external onlyOwner {
    score = ScoreInterface(_address);
  }

  function setActivityStorageAddress(address _address) external onlyOwner {
    activityStorage = ActivityStorage(_address);
  }

  function setReferrerStorageAddress(address _address) external onlyOwner {
    referrerStorage = ReferrerStorage(_address);
  }

  function rebate(address _player) public onlyWhitelisted {
    uint256 betsCount = activityStorage.getActivity(_player);
    if (betsCount > 99 && value >= 250 ether) {
      uint256 toRebate = (value - 240 ether) / 100;
      value = value.sub(toRebate);
      _incrementAttraction(_player);
      bank.addDeposit(_player, toRebate);
      score.addAmount(_player, toRebate);
      Rebate(_player, toRebate);
    }
  }

  function returnBet(address _player, uint256 _amount) public onlyWhitelisted returns(bool) {
    uint256 currentAttraction = attraction[activityStorage.getActivityNumber()][_player];
    if (currentAttraction == 0 && value >= _amount) {
      value = value.sub(_amount);
      _incrementAttraction(_player);
      bank.addDeposit(_player, _amount);
      score.addAmount(_player, _amount);
      BetReturn(_player, _amount);
      return true;
    } else {
      return false;
    }
  }

  function getAttraction(address _player) public view returns(uint256) {
    return attraction[activityStorage.getActivityNumber()][_player];
  }

  function _incrementAttraction(address _player) internal {
    uint256 activityNumber = activityStorage.getActivityNumber();
    attraction[activityNumber][_player] = attraction[activityNumber][_player].add(1);
  }

  function _hasNoActivity(address _player) internal view returns(bool) {
    uint256 activityNumber = activityStorage.getActivityNumber();
    return activityStorage.getActivity(activityNumber, _player) + activityStorage.getActivity(activityNumber - 1, _player) == 0;
  }

}
