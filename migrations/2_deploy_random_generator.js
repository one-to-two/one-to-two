const RandomGenerator = artifacts.require("./helper/random/RandomGenerator.sol")

module.exports = (deployer) => {
  deployer.deploy(RandomGenerator, 10)
}
