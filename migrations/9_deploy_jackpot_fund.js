const RandomGenerator = artifacts.require("./helper/random/RandomGenerator.sol")
const Bank = artifacts.require("./bank/Bank.sol")
const JackpotFund = artifacts.require("./fund/jackpot/JackpotFund.sol")
const FundsManager = artifacts.require("./fund/FundsManager.sol")
const ActivityStorage = artifacts.require("./activity/ActivityStorage.sol")

module.exports = (deployer) => {
  deployer.deploy(JackpotFund, RandomGenerator.address, Bank.address)
          .then(() => {
            JackpotFund.deployed()
                       .then((jackpotFund) => {
                         jackpotFund.addAddressToWhitelist(FundsManager.address)
                         jackpotFund.setActivityStorageAddress(ActivityStorage.address)
                       })
            Bank.deployed()
                .then((bank) => {
                  bank.addAddressToWhitelist(JackpotFund.address)
                })
            ActivityStorage.deployed()
                           .then((activityStorage) => {
                             activityStorage.addAddressToWhitelist(JackpotFund.address)
                           })
            FundsManager.deployed()
                        .then((fundsManager) => {
                          fundsManager.setJackpotFundAddress(JackpotFund.address)
                        })
          })
}
