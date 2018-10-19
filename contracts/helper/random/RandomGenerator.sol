pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";

import './RandomGeneratorInterface.sol';

contract RandomGenerator is Ownable, RandomGeneratorInterface {

  uint256 internal randNonce = 0;
  uint256 internal step;

  function RandomGenerator(uint256 _step) public {
    step = _step;
  }

  function random() public returns (uint256) {
    randNonce += step;
    // TODO: improve randomness or use 3rd party contract
    return uint256(keccak256(now, msg.sender, randNonce));
  }

  function setStep(uint256 _step) public onlyOwner {
    step = _step;
  }

}
