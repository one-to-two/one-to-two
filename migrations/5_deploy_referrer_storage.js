const ReferrerStorage = artifacts.require("./referrer/ReferrerStorage.sol")

module.exports = (deployer) => {
  deployer.deploy(ReferrerStorage)
}
