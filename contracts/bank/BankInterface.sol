pragma solidity ^0.4.17;

interface BankInterface {

  function getBalance(address _player) public returns(uint256);
  function addDeposit(address _player, uint256 _amount) public;
  function subDeposit(address _player, uint256 _amount) public;
  function sendFunds(address _receiver, uint256 _amount) public;
  
}
