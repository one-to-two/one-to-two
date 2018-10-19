pragma solidity ^0.4.17;

import "./Fund.sol";

contract DevelopmentFund is Fund {

  function DevelopmentFund(address _bankAddress) Fund(_bankAddress) public {
  }

}
