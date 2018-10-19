pragma solidity ^0.4.17;

import "zeppelin-solidity/contracts/crowdsale/emission/AllowanceCrowdsale.sol";
import "zeppelin-solidity/contracts/ownership/Whitelist.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";

import "../bank/BankInterface.sol";
import "../fund/FundsManagerInterface.sol";
import "../referrer/ReferrerStorage.sol";
import "../bank/Bank.sol";

contract OneToTwoCrowdsale is Whitelist, AllowanceCrowdsale {

  uint8 public constant STAGES_COUNT = 5;
  uint256 public constant ONE_ETHER = 1 ether;
  uint256 public constant REFERRAL_DICOUNT = 5;

  uint256 public closingTime = 1548115199; //21-01-2019 23:59:59

  mapping(uint8 => uint256) public openingTimes;
  mapping(uint8 => uint256) public minTokensAmount;
  mapping(uint8 => uint256) public prices;

  FundsManagerInterface internal fundsManager;
  ReferrerStorage internal referrerStorage;
  BankInterface internal bank;

  event PaidToReferrer(address indexed _referrer, uint256 _amount);

  /**
   * @dev Reverts if not in crowdsale time range.
   */
  modifier onlyWhileOpen {
    require(isOpen());
    _;
  }

  function OneToTwoCrowdsale(address _tokenWallet, uint256 _rate, address _wallet, ERC20 _token)
      Crowdsale(_rate, _wallet, _token)
      AllowanceCrowdsale(_tokenWallet)
      public {
        minTokensAmount[1] = 10 ether;

        openingTimes[1] = now;
        openingTimes[2] = 1542758400; //21-11-2018
        openingTimes[3] = 1543622400; //01-12-2018
        openingTimes[4] = 1544572800; //12-12-2018
        openingTimes[5] = 1545436800; //22-12-2018

        prices[1] = 0.05 ether;
        prices[2] = 0.0625 ether;
        prices[3] = 0.075 ether;
        prices[4] = 0.0875 ether;
        prices[5] = 0.125 ether;
  }

  function setFundsManagerAddress(address _address) external onlyOwner {
    fundsManager = FundsManagerInterface(_address);
  }

  function setReferrerStorageAddress(address _address) external onlyOwner {
    referrerStorage = ReferrerStorage(_address);
  }

  function setBankAddress(address _address) external onlyOwner {
    bank = BankInterface(_address);
  }

  function setOpeningTime(uint8 _stage, uint256 _time) external onlyOwner {
    openingTimes[_stage] = _time;
  }

  function setPrice(uint8 _stage, uint256 _price) external onlyOwner {
    prices[_stage] = _price;
  }

  function setMinTokensAmount(uint8 _stage, uint256 _minTokensAmount) external onlyOwner {
    minTokensAmount[_stage] = _minTokensAmount;
  }

  function isOpen() view public returns (bool) {
    return now <= closingTime;
  }

  function getStage() public view returns (uint8) {
    for (uint8 i = STAGES_COUNT; i >= 1; i--) {
      if (now >= openingTimes[i]) {
        return i;
      }
    }

    return 1;
  }

  function canBuyMore(uint8 _stage) public view returns (uint256) {
    uint256 totalTokensForStage = 2000 ether;
    return remainingTokens() - (STAGES_COUNT - _stage) * totalTokensForStage;
  }

  function () external payable {
    buyTokens(msg.sender, address(0));
  }

  function buyTokensWithReferrer(address _referrer) public payable {
    buyTokens(msg.sender, _referrer);
  }

  function buyTokens(address _beneficiary, address _referrer) private {
    uint256 weiAmount = msg.value;
    if (!_hasReferrer(_beneficiary) && _appropriateReferrer(_beneficiary, _referrer)) {
      referrerStorage.setReferrer(_beneficiary, _referrer);
    }
    buyTokens(_beneficiary, _referrer, weiAmount);
    // check if investor has referrer an send 20% to him
    if (_hasDiscount(_beneficiary, _referrer)) {
      address referrer = referrerStorage.getReferrer(_beneficiary);
      uint256 toReferrer = weiAmount.div(5);
      bank.sendFunds(referrer, toReferrer);
      weiAmount = weiAmount.sub(toReferrer);
      PaidToReferrer(referrer, toReferrer);
    }
    // distribute the amount between funds
    fundsManager.fillFunds(weiAmount);
  }

  function buyTokens(address _beneficiary, address _referrer, uint256 _weiAmount) public payable {
    _preValidatePurchase(_beneficiary, _referrer, _weiAmount);
    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(_beneficiary, _referrer, _weiAmount);
    // update state
    weiRaised = weiRaised.add(_weiAmount);
    _processPurchase(_beneficiary, tokens);
    TokenPurchase(
      msg.sender,
      _beneficiary,
      _weiAmount,
      tokens
    );
    _updatePurchasingState(_beneficiary, _weiAmount);
    _forwardFunds();
    _postValidatePurchase(_beneficiary, _weiAmount);
  }

  function buyTokens(address beneficiary) public payable {
    // turn off super logic
    assert(false);
  }

  function _preValidatePurchase(address _beneficiary, address _referrer, uint256 _weiAmount) internal onlyWhileOpen {
    super._preValidatePurchase(_beneficiary, _weiAmount);
    uint8 stage = getStage();
    uint256 tokens = _getTokenAmount(_beneficiary, _referrer, _weiAmount);
    require(tokens >= minTokensAmount[stage] && tokens <= canBuyMore(stage));
  }

  function getPrice(address _beneficiary, address _referrer) public view returns (uint256, bool) {
    uint256 price = prices[getStage()];
    if (_hasDiscount(_beneficiary, _referrer)) {
      return (price.sub(price.mul(REFERRAL_DICOUNT).div(100)), true);
    } else {
      return (price, false);
    }
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(address _beneficiary, address _referrer, uint256 _weiAmount) internal view returns (uint256) {
    uint256 price;
    (price,) = getPrice(_beneficiary, _referrer);
    return ONE_ETHER.mul(_weiAmount).div(price);
  }

  function _hasDiscount(address _investor, address _referrer) public view returns (bool) {
    return _hasReferrer(_investor) || _appropriateReferrer(_investor, _referrer);
  }

  function _hasReferrer(address _investor) public view returns (bool) {
    return referrerStorage.getReferrer(_investor) != address(0);
  }

  function _appropriateReferrer(address _investor, address _referrer) public view returns (bool) {
    address realReferrer = referrerStorage.getReferrer(_investor);
    return (realReferrer != address(0) && realReferrer == _referrer) || realReferrer == address(0) && _referrer != address(0) && _referrer != _investor && token.balanceOf(_investor) == 0;
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    Bank(wallet).deposit.value(msg.value)(this);
  }

}
