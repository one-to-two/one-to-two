pragma solidity ^0.4.17;

import "./Fund.sol";
import "../token/OneToTwoTokenInterface.sol";
import "../token/StockExchangeInterface.sol";

contract DividendsFund is Fund, StockExchangeInterface {

  mapping(address => uint256) public lastDividendsState;

  uint256 public totalDividends;

  OneToTwoTokenInterface internal token;

  event WithdrawDividends(address indexed investor, uint256 value);

  function DividendsFund(address _bankAddress) Fund(_bankAddress) public {
  }

  function setTokenAddress(address _address) external onlyOwner {
    token = OneToTwoTokenInterface(_address);
  }

  function add(uint256 _amount) public onlyWhitelisted {
    totalDividends = totalDividends.add(_amount);
    value = value.add(_amount);
  }

  function setRecentDividendsState(address _address) public onlyWhitelisted {
      lastDividendsState[_address] = totalDividends;
  }

  function withdrawDividends() public {
    _withdrawDividends(msg.sender);
  }

  function withdrawDividends(address _address) public onlyWhitelisted {
    _withdrawDividends(_address);
  }

  function _withdrawDividends(address _address) internal {
    uint256 dividends = calculateDividends(_address);
    lastDividendsState[_address] = totalDividends;
    if (dividends > 0) {
      value -= dividends;
      bank.sendFunds(_address, dividends);
      WithdrawDividends(_address, dividends);
    }
  }

  function calculateDividends(address _investor) public view returns(uint256) {
    uint256 tokens = token.balanceOf(_investor);
    if (tokens == 0) {
      return 0;
    }
    uint256 newDividendsState = totalDividends - lastDividendsState[_investor];
    return (newDividendsState * tokens) / token.totalSupply();
  }

}
