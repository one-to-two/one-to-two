pragma solidity ^0.4.17;

import "../Fund.sol";
import "../../score/ScoreInterface.sol";
import "../../activity/ActivityStorage.sol";
import "../../helper/random/RandomGeneratorInterface.sol";
import "./JackpotFundInterface.sol";

contract JackpotFund is Fund, JackpotFundInterface {

  uint256 constant public DAY_IN_SECONDS = 24 * 60 * 60;

  uint256 public jackpotNumber;

  uint256 public lastAccumulatedTime = now;
  uint256 public minimumThreshold = 1 ether;
  uint256 public jackpotMultiplier = 10;

  RandomGeneratorInterface internal randomGenerator;
  BankInterface internal bank;
  ScoreInterface internal score;
  ActivityStorage internal activityStorage;

  event JackpotDrawn(address indexed _winner, uint256 amount);

  function JackpotFund(address _randomGeneratorAddress, address _bankAddress) Fund(_bankAddress) public {
    randomGenerator = RandomGeneratorInterface(_randomGeneratorAddress);
  }

  function setRandomGeneratorAddress(address _address) external onlyOwner {
    randomGenerator = RandomGeneratorInterface(_address);
  }

  function setScoreAddress(address _address) external onlyOwner {
    score = ScoreInterface(_address);
  }

  function setActivityStorageAddress(address _address) external onlyOwner {
    activityStorage = ActivityStorage(_address);
  }

  function setMinimumThreshold(uint256 _minimumThreshold) external onlyOwner {
    minimumThreshold = _minimumThreshold;
  }

  function setJackpotMultiplier(uint256 _jackpotMultiplier) external onlyOwner {
    jackpotMultiplier = _jackpotMultiplier;
  }

  function drawJackpot(address _player) public onlyWhitelisted {
    _drawJackpot(_player);
  }

  function calculateWinProbability(address _player) public view returns (uint256) {
    if (value < minimumThreshold) {
      return 0;
    }
    // BPWJ - base probability winning jackpot
    uint256 dayProbability = (((now - lastAccumulatedTime) * 100 * jackpotMultiplier) / DAY_IN_SECONDS);
    uint256 jackpotProbability = ((value * 100 * jackpotMultiplier) / 25 ether);
    uint256 baseProbabilityWinJackpot = dayProbability;
    if (dayProbability < jackpotProbability) {
      baseProbabilityWinJackpot = jackpotProbability;
    }
    // IP - individual probability
    uint256 individualMultiplyer = activityStorage.getActivity(_player);
    return (baseProbabilityWinJackpot / 100) * individualMultiplyer;
  }

  function _drawJackpot(address _player) internal {
    uint256 individualProbability = calculateWinProbability(_player);
    if (individualProbability > 0) {
      uint256 rand = randomGenerator.random() % (1000000 * jackpotMultiplier);
      if (individualProbability > rand) {
        _jackpotWon(_player);
        jackpotNumber = jackpotNumber.add(1);
        lastAccumulatedTime = now;
        value = 0;
      }
    }
  }

  function _jackpotWon(address _player) internal {
      bank.addDeposit(_player, value);
      score.addAmount(_player, value);
      JackpotDrawn(_player, value);
  }

}
