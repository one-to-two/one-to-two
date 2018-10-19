const ActivityStorage = artifacts.require("./activity/ActivityStorage.sol")

module.exports = (deployer) => {
  deployer.deploy(ActivityStorage)
}
