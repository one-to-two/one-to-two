const DevelopmentFund = artifacts.require("./fund/DevelopmentFund.sol")
const Bank = artifacts.require("./bank/Bank.sol")
const FundsManager = artifacts.require("./fund/FundsManager.sol")

module.exports = (deployer) => {
  deployer.deploy(DevelopmentFund, Bank.address)
          .then(() => {
            DevelopmentFund.deployed()
                           .then((developmentFund) => {
                             developmentFund.addAddressToWhitelist(FundsManager.address)
                           })
            Bank.deployed()
                .then((bank) => {
                  bank.addAddressToWhitelist(DevelopmentFund.address)
                })
            FundsManager.deployed()
                        .then((fundsManager) => {
                          fundsManager.setDevelopmentFundAddress(DevelopmentFund.address)
                        })
          })
}
