pragma solidity ^0.4.19;

import "zeppelin-solidity/contracts/token/ERC20/MintableToken.sol";

import "./StockExchangeInterface.sol";

contract OneToTwoToken is MintableToken {

    string public name = "One To Two Platform";
    string public symbol = "OTTP";
    uint8 public constant decimals = 18;

    StockExchangeInterface stockExchangeContract;

    function setStockExchangeAddress(address _address) external onlyOwner {
        stockExchangeContract = StockExchangeInterface(_address);
    }

    /**
      * @dev transfer token for a specified address
      * @param _to The address to transfer to.
      * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
      require(_to != address(0));
      require(_value <= balances[msg.sender]);

      stockExchangeContract.withdrawDividends(msg.sender);
      stockExchangeContract.withdrawDividends(_to);
      // SafeMath.sub will throw if there is not enough balance.
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      Transfer(msg.sender, _to, _value);
      return true;
    }

    /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    stockExchangeContract.withdrawDividends(_from);
    stockExchangeContract.withdrawDividends(_to);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

    /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    if (stockExchangeContract != address(0)) {
      stockExchangeContract.setRecentDividendsState(_to);
    }
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

}
