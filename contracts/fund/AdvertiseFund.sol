pragma solidity ^0.4.17;

import "./Fund.sol";

contract AdvertiseFund is Fund {

  function AdvertiseFund(address _bankAddress) Fund(_bankAddress) public {
  }

}
