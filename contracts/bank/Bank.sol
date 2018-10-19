pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Whitelist.sol";

import "./BankInterface.sol";

contract Bank is Whitelist, BankInterface {
  using SafeMath for uint256;

  mapping(address => uint256) public balances;
  mapping(address => string) public names;

  event Deposit(address indexed player, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Withdraw(address indexed player, uint256 value);

  function () external payable {
    deposit(msg.sender);
  }

  function addFunds() external payable onlyOwner {
    // do nothing, just add ether to contract
  }

  function deposit(address _beneficiary) public payable {
      uint256 weiAmount = msg.value;
      require(_beneficiary != address(0));
      require(weiAmount > 0);
      balances[_beneficiary] = balances[_beneficiary].add(weiAmount);
      Deposit(_beneficiary, weiAmount);
  }

  function setName(string _name) public {
    names[msg.sender] = _name;
  }

  function withdraw() public {
    require(balances[msg.sender] > 0);
    withdraw(balances[msg.sender]);
  }

  function withdraw(uint256 _amount) public {
    require(balances[msg.sender] >= _amount);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    msg.sender.transfer(_amount);
    Withdraw(msg.sender, _amount);
  }

  function transfer(address _to, uint256 _amount) public returns (bool) {
    require(_to != address(0));
    require(_amount <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    balances[_to] = balances[_to].add(_amount);
    Transfer(msg.sender, _to, _amount);
    return true;
  }

  function getBalance(address _player) public returns(uint256) {
    return balances[_player];
  }

  function addDeposit(address _player, uint256 _amount) public onlyWhitelisted {
    balances[_player] = balances[_player].add(_amount);
  }

  function subDeposit(address _player, uint256 _amount) public onlyWhitelisted {
    balances[_player] = balances[_player].sub(_amount);
  }

  function sendFunds(address _receiver, uint256 _amount) public onlyWhitelisted {
    _receiver.transfer(_amount);
  }

}
