pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Whitelist.sol";

import "../bank/BankInterface.sol";
import "./FundInterface.sol";

contract Fund is Whitelist, FundInterface {
  using SafeMath for uint256;

  uint256 public value;

  BankInterface internal bank;

  event Withdraw(uint256 value);

  function Fund(address _bankAddress) public {
    bank = BankInterface(_bankAddress);
  }

  function setBankAddress(address _address) external onlyOwner {
    bank = BankInterface(_address);
  }

  function getValue() view public returns (uint256) {
    return value;
  }

  function add(uint256 _amount) public onlyWhitelisted {
    value = value.add(_amount);
  }

  function sub(uint256 _amount) public onlyWhitelisted {
    value = value.sub(_amount);
  }

  function sendFunds(address _receiver, uint256 _amount) public onlyWhitelisted {
    require(value >= _amount);
    value = value.sub(_amount);
    bank.sendFunds(_receiver, _amount);
  }

  function withdraw(uint256 _amount) public onlyOwner {
    require(value >= _amount);
    value = value.sub(_amount);
    bank.sendFunds(owner, _amount);
    Withdraw(_amount);
  }

}
