const OneToTwoToken = artifacts.require("./token/OneToTwoToken.sol")
const DividendsFund = artifacts.require("./fund/dividends/DividendsFund.sol")

module.exports = (deployer, network, accounts) => {
  deployer.deploy(OneToTwoToken)
          .then(() => {
            DividendsFund.deployed()
                         .then((dividendsFund) => {
                           dividendsFund.addAddressToWhitelist(OneToTwoToken.address)
                           dividendsFund.setTokenAddress(OneToTwoToken.address)
                         })
            OneToTwoToken.deployed()
                         .then((token) => {
                           token.setStockExchangeAddress(DividendsFund.address)
                           // mint tokens for ICO and bounty program
                           token.mint(accounts[0], web3.toWei(11000, "ether"))
                         })
          })
}
