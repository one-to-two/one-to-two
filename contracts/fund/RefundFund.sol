pragma solidity ^0.4.17;

import "./Fund.sol";

contract RefundFund is Fund {

  function RefundFund(address _bankAddress) Fund(_bankAddress) public {
  }

}
