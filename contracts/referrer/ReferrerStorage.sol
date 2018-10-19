pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/ownership/Whitelist.sol";

contract ReferrerStorage is Whitelist {

  mapping(address => address) public referrer;

  function getReferrer(address _player) public view returns (address) {
    return referrer[_player];
  }

  function setReferrer(address _player, address _referrer) public onlyWhitelisted {
    referrer[_player] = _referrer;
  }

}
