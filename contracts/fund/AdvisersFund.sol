pragma solidity ^0.4.17;

import "./Fund.sol";

contract AdvisersFund is Fund {

  function AdvisersFund(address _bankAddress) Fund(_bankAddress) public {
  }

}
