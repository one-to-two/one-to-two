const RandomGenerator = artifacts.require("./helper/random/RandomGenerator.sol")
const Bank = artifacts.require("./bank/Bank.sol")
const Game = artifacts.require("./game/Game.sol")

module.exports = (deployer) => {
  deployer.deploy(Game, RandomGenerator.address, Bank.address)
          .then(() => {
            Bank.deployed()
                .then((bank) => {
                  bank.addAddressToWhitelist(Game.address)
                })
          })
}
