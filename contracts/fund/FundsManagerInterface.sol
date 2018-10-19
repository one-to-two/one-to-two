pragma solidity ^0.4.17;

interface FundsManagerInterface {

  function bet(uint16 _type, address _player, uint256 _amount, address _referrer) public returns(uint256);
  function win(address _player, uint256 _amount) public;
  function fillFunds(uint256 _amount) public;

}
