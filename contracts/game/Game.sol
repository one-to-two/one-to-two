pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";

import "../helper/random/RandomGeneratorInterface.sol";
import "../bank/BankInterface.sol";
import "../fund/FundsManagerInterface.sol";

contract Game is Ownable {
  using SafeMath for uint256;

  enum GameStatus {
    NEW, FINISHED
  }

  struct Table {
    uint256 id;
    address[] players;
    uint256[] bets;
    GameStatus status;
  }

  mapping (uint16 => uint256) public betByType;

  mapping(uint16 => mapping(address => uint256)) public playerTableByType;
  mapping(uint16 => Table[]) public tablesByType;

  RandomGeneratorInterface internal randomGenerator;
  BankInterface internal bank;
  FundsManagerInterface internal fundsManager;

  event NewBet(uint16 indexed tableType, uint256 indexed tableId, address indexed player, uint256 amount);
  event GameStep(uint16 indexed tableType, uint256 indexed tableId, address indexed winner, uint256 prise);

  function Game(address _randomGeneratorAddress, address _bankAddress) public {
    randomGenerator = RandomGeneratorInterface(_randomGeneratorAddress);
    bank = BankInterface(_bankAddress);

    // no comission, single winner
    betByType[4] = 0.0006 ether;
    betByType[8] = 0.0023 ether;

    // no comission, all in, single winner
    betByType[1010] = 0.0006 ether;

    // comission, single winner
    betByType[10002] = 0.05 ether;
    betByType[10004] = 0.04 ether;
    betByType[10006] = 0.03 ether;
    betByType[10008] = 0.02 ether;
    betByType[10010] = 0.01 ether;

    // comission, multiple winners
    betByType[10102] = 0.5 ether;
    betByType[10104] = 0.32 ether;
    betByType[10106] = 0.18 ether;
    betByType[10108] = 0.08 ether;
    betByType[10110] = 0.02 ether;
  }

  function setRandomGeneratorAddress(address _address) external onlyOwner {
    randomGenerator = RandomGeneratorInterface(_address);
  }

  function setBankAddress(address _address) external onlyOwner {
    bank = BankInterface(_address);
  }

  function setFundsManagerAddress(address _address) external onlyOwner {
    fundsManager = FundsManagerInterface(_address);
  }

  function setBetByType(uint16 _type, uint256 _bet) external onlyOwner {
    betByType[_type] = _bet;
  }

  function randMod(uint256 _modulus) internal returns(uint256) {
    return randomGenerator.random() % _modulus;
  }

  function bet(uint16 _type, address _referrer) public {
    address player = msg.sender;
    uint256 balance = bank.getBalance(player);
    uint256 betAmount = betByType[_type];
    require(betAmount > 0);
    if (_allIn(_type)) {
      require(balance < betAmount);
      betAmount = balance;
    }
    require(balance >= betAmount);
    Table storage table = _findOrCreateTable(_type);
    require(playerTableByType[_type][player] != table.id);
    table.players.push(player);

    playerTableByType[_type][player] = table.id;
    bank.subDeposit(player, betAmount);
    if (_hasComission(_type)) {
      uint256 actualBet = fundsManager.bet(_type, player, betAmount, _referrer);
      table.bets.push(actualBet);
    } else {
      table.bets.push(betAmount);
    }
    NewBet(_type, table.id, player, betAmount);
    if (table.players.length == _capacity(_type)) {
      _processTable(_type, table);
    }
  }

  function getLastTableId(uint16 _type) public view returns (uint256) {
    return tablesByType[_type].length;
  }

  function getTable(uint16 _type, uint256 _index) public view returns(uint256, address[], uint256[], GameStatus) {
    Table storage table = tablesByType[_type][_index];
    return (table.id, table.players, table.bets, table.status);
  }

  function _processTable(uint16 _type, Table storage _table) internal {
    uint256 steps = _singleWinner(_type) ? 1 : _table.players.length;

    uint256 fund = 0;
    for (uint256 i = 0; i < _table.bets.length; i++) {
      fund += _table.bets[i];
    }

    uint256 betsWeight = 0;
    uint256[] memory betWeights = new uint256[](_table.bets.length);
    for (i = 0; i < _table.bets.length; i++) {
      betWeights[i] = _table.bets[i] * 100 / fund;
      betsWeight += betWeights[i];
    }

    uint256 prise = fund / steps;
    for (i = 0; i < steps; i++) {
      uint256 randomValue = randMod(betsWeight) + 1;
      uint256 left = 0;
      for (uint256 j = 0; j < _table.players.length; j++) {
        uint256 betWeight = betWeights[j];
        if (left < randomValue && randomValue <= left + betWeight){
          address winner = _table.players[j];
          bank.addDeposit(winner, prise);
          fundsManager.win(winner, prise);
          GameStep(_type, _table.id, winner, prise);
          break;
        } else {
          left += betWeight;
        }
      }
    }
    _table.status = GameStatus.FINISHED;
  }

  function getTickets(uint256 _playerBet) internal pure returns(uint256) {
    uint256 _costOfOneTicket = 0.000125 ether;
    return (_playerBet + _costOfOneTicket) / _costOfOneTicket;
  }

  function _findOrCreateTable(uint16 _type) internal returns (Table storage) {
    Table[] storage tables = tablesByType[_type];
    if (tables.length == 0) {
      return _createTable(_type);
    } else {
      Table storage lastTable = tables[tables.length - 1];
      if (lastTable.status == GameStatus.NEW) {
        return lastTable;
      } else {
        return _createTable(_type);
      }
    }
  }

  function _createTable(uint16 _type) internal returns (Table storage) {
    Table[] storage tables = tablesByType[_type];
    uint256 id = tables.push(Table(tables.length, new address[](0), new uint256[](0), GameStatus.NEW));
    return tables[id - 1];
  }

  function _hasComission(uint16 _type) internal pure returns (bool) {
    return (_type / 10000) > 0;
  }

  function _allIn(uint16 _type) internal pure returns (bool) {
    return (_type % 10000 / 1000) > 0;
  }

  function _singleWinner(uint16 _type) internal pure returns (bool) {
    return (_type % 1000 / 100) < 1;
  }

  function _capacity(uint16 _type) internal pure returns (uint8) {
    return (uint8) (_type % 100);
  }

}
