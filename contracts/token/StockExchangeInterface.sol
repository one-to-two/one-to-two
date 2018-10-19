pragma solidity ^0.4.19;

contract StockExchangeInterface {

    function setRecentDividendsState(address _address) public;
    function withdrawDividends(address _address) public;

}
