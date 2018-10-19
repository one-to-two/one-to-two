pragma solidity ^0.4.17;

interface OneToTwoTokenInterface {

  function totalSupply() public view returns (uint256);
  function balanceOf(address _owner) public view returns (uint256 balance);
  
}
