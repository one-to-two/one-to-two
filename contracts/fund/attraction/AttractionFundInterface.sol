pragma solidity ^0.4.17;

interface AttractionFundInterface {

  function add(uint256 _amount, address _player, address _referrer, bool isAmountReturned) public;
  function returnBet(address _player, uint256 _amount) public returns(bool);
  function rebate(address _player) public;

}
