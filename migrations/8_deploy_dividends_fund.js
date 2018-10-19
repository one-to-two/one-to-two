const DividendsFund = artifacts.require("./fund/DividendsFund.sol")
const Bank = artifacts.require("./bank/Bank.sol")
const OneToTwoToken = artifacts.require("./token/OneToTwoToken.sol")
const FundsManager = artifacts.require("./fund/FundsManager.sol")

module.exports = (deployer) => {
  deployer.deploy(DividendsFund, Bank.address)
          .then(() => {
            DividendsFund.deployed()
                         .then((dividendsFund) => {
                           dividendsFund.addAddressToWhitelist(FundsManager.address)
                         })
            Bank.deployed()
                .then((bank) => {
                  bank.addAddressToWhitelist(DividendsFund.address)
                })
            FundsManager.deployed()
                        .then((fundsManager) => {
                          fundsManager.setDividendsFundAddress(DividendsFund.address)
                        })
          })
}
