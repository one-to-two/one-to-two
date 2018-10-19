const Bank = artifacts.require("./bank/Bank.sol")

module.exports = (deployer) => {
  deployer.deploy(Bank)
}
