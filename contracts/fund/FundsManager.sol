pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Whitelist.sol";

import "../score/ScoreInterface.sol";
import "../activity/ActivityStorage.sol";
import "./AdvertiseFund.sol";
import "./AdvisersFund.sol";
import "./DevelopmentFund.sol";
import "./DividendsFund.sol";
import "./RefundFund.sol";
import "./attraction/AttractionFund.sol";
import "./jackpot/JackpotFund.sol";
import "./FundsManagerInterface.sol";

contract FundsManager is Whitelist, FundsManagerInterface {
  using SafeMath for uint256;

  uint8 jackpotFundPercent = 2;
  uint8 attractionFundPercent = 2;
  uint8 refundFundPercent = 1;
  uint8 dividendsFundPercent = 3;
  uint8 developmentFundPercent = 2;

  uint8 constant ICO_ATTRACTION_FUND_PERCENT = 55;
  uint8 constant ICO_REFUND_FUND_PERCENT = 30;
  uint8 constant ICO_ADVERTISE_FUND_PERCENT = 10;
  uint8 constant ICO_ADVISERS_FUND_PERCENT = 5;

  DevelopmentFund internal developmentFund;
  DividendsFund internal dividendsFund;
  AdvertiseFund internal advertiseFund;
  AdvisersFund internal advisersFund;
  RefundFund internal refundFund;
  JackpotFund internal jackpotFund;
  AttractionFund internal attractionFund;
  ScoreInterface internal score;
  ActivityStorage internal activityStorage;

  function setDevelopmentFundAddress(address _address) external onlyOwner {
    developmentFund = DevelopmentFund(_address);
  }

  function setDividendsFundAddress(address _address) external onlyOwner {
    dividendsFund = DividendsFund(_address);
  }

  function setJackpotFundAddress(address _address) external onlyOwner {
    jackpotFund = JackpotFund(_address);
  }

  function setAttractionFundAddress(address _address) external onlyOwner {
    attractionFund = AttractionFund(_address);
  }

  function setAdvertiseFundAddress(address _address) external onlyOwner {
    advertiseFund = AdvertiseFund(_address);
  }

  function setAdvisersFundAddress(address _address) external onlyOwner {
    advisersFund = AdvisersFund(_address);
  }

  function setRefundFundAddress(address _address) external onlyOwner {
    refundFund = RefundFund(_address);
  }

  function setScoreAddress(address _address) external onlyOwner {
    score = ScoreInterface(_address);
  }

  function setActivityStorageAddress(address _address) external onlyOwner {
    activityStorage = ActivityStorage(_address);
  }

  function fillFunds(uint256 _amount) public onlyWhitelisted {
    uint256 toAttraction = _amount * ICO_ATTRACTION_FUND_PERCENT / 100;
    uint256 toRefund = _amount * ICO_REFUND_FUND_PERCENT / 100;
    uint256 toAdvertise = _amount * ICO_ADVERTISE_FUND_PERCENT / 100;
    uint256 toAdvisers = _amount * ICO_ADVISERS_FUND_PERCENT / 100;

    attractionFund.add(toAttraction);
    refundFund.add(toRefund);
    advertiseFund.add(toAdvertise);
    advisersFund.add(toAdvisers);
  }

  function bet(uint16 _type, address _player, uint256 _amount, address _referrer) public onlyWhitelisted returns(uint256) {
    bool isAmountReturned = false;
    if (_returnBet(_type)){
      isAmountReturned = attractionFund.returnBet(_player, _amount);
    }
    attractionFund.rebate(_player);

    uint256 toJackpot = _amount * jackpotFundPercent / 100;
    uint256 toAttraction = _amount * attractionFundPercent / 100;
    uint256 toRefund = _amount * refundFundPercent / 100;
    uint256 toDividends = _amount * dividendsFundPercent / 100;
    uint256 toDevelopment = _amount * developmentFundPercent / 100;

    activityStorage.updateMonthActivity();
    attractionFund.add(toAttraction, _player, _referrer, isAmountReturned);
    jackpotFund.add(toJackpot);
    refundFund.add(toRefund);
    dividendsFund.add(toDividends);
    developmentFund.add(toDevelopment);

    activityStorage.incrementActivity(_player);
    jackpotFund.drawJackpot(_player);

    uint256 realBetAmount = _amount - (toJackpot + toAttraction + toRefund + toDividends + toDevelopment);
    return realBetAmount;
  }

  function win(address _player, uint256 _amount) public {
    score.addAmount(_player, _amount);
  }

  function _returnBet(uint16 _type) internal pure returns (bool) {
    // game 1/10
    return (_type == 10010);
  }

}
