const AdvertiseFund = artifacts.require("./fund/AdvertiseFund.sol")
const Bank = artifacts.require("./bank/Bank.sol")
const FundsManager = artifacts.require("./fund/FundsManager.sol")

module.exports = (deployer) => {
  deployer.deploy(AdvertiseFund, Bank.address)
          .then(() => {
            AdvertiseFund.deployed()
                         .then((fund) => {
                           fund.addAddressToWhitelist(FundsManager.address)
                         })
            Bank.deployed()
                .then((bank) => {
                  bank.addAddressToWhitelist(AdvertiseFund.address)
                })
            FundsManager.deployed()
                        .then((fundsManager) => {
                          fundsManager.setAdvertiseFundAddress(AdvertiseFund.address)
                        })
          })
}
