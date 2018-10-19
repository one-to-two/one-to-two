pragma solidity ^0.4.17;

interface FundInterface {

  function getValue() view public returns (uint256);
  function add(uint256 _amount) public;
  function sub(uint256 _amount) public;

}
