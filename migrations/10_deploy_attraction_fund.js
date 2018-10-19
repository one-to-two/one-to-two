const AttractionFund = artifacts.require("./fund/attraction/AttractionFund.sol")
const Bank = artifacts.require("./bank/Bank.sol")
const FundsManager = artifacts.require("./fund/FundsManager.sol")
const ReferrerStorage = artifacts.require("./referrer/ReferrerStorage.sol")
const ActivityStorage = artifacts.require("./activity/ActivityStorage.sol")

module.exports = (deployer) => {
  deployer.deploy(AttractionFund, Bank.address)
          .then(() => {
            AttractionFund.deployed()
                          .then((attractionFund) => {
                            attractionFund.addAddressToWhitelist(FundsManager.address)
                            attractionFund.setReferrerStorageAddress(ReferrerStorage.address)
                            attractionFund.setActivityStorageAddress(ActivityStorage.address)
                          })
            ReferrerStorage.deployed()
                         .then((referrerStorage) => {
                           referrerStorage.addAddressToWhitelist(AttractionFund.address)
                         })
            ActivityStorage.deployed()
                           .then((activityStorage) => {
                             activityStorage.addAddressToWhitelist(AttractionFund.address)
                           })
            Bank.deployed()
                .then((bank) => {
                   bank.addAddressToWhitelist(AttractionFund.address)
                })
            FundsManager.deployed()
                        .then((fundsManager) => {
                          fundsManager.setAttractionFundAddress(AttractionFund.address)
                        })
          })
}
