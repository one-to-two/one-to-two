const FundsManager = artifacts.require("./fund/FundsManager.sol")
const Game = artifacts.require("./game/Game.sol")
const ActivityStorage = artifacts.require("./activity/ActivityStorage.sol")

module.exports = (deployer) => {
  deployer.deploy(FundsManager)
          .then(() => {
            FundsManager.deployed()
                        .then((fundsManager) => {
                          fundsManager.addAddressToWhitelist(Game.address)
                          fundsManager.setActivityStorageAddress(ActivityStorage.address)
                        })
            ActivityStorage.deployed()
                           .then((activityStorage) => {
                             activityStorage.addAddressToWhitelist(FundsManager.address)
                           })
            Game.deployed()
                .then((game) => {
                  game.setFundsManagerAddress(FundsManager.address)
                })
          })
}
