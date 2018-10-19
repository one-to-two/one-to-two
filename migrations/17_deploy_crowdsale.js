const OneToTwoCrowdsale = artifacts.require("./crowdsale/OneToTwoCrowdsale.sol")
const OneToTwoToken = artifacts.require("./token/OneToTwoToken.sol")
const FundsManager = artifacts.require("./fund/FundsManager.sol")
const ReferrerStorage = artifacts.require("./referrer/ReferrerStorage.sol")
const Bank = artifacts.require("./bank/Bank.sol")

module.exports = (deployer, network, accounts) => {
  deployer.deploy(OneToTwoCrowdsale,
                  accounts[0],
                  new web3.BigNumber(1),
                  Bank.address,
                  OneToTwoToken.address)
          .then(() => {
            OneToTwoToken.deployed()
                         .then((token) => {
                           token.approve(OneToTwoCrowdsale.address, web3.toWei(10000, "ether"))
                         })
            OneToTwoCrowdsale.deployed()
                             .then((crowdsale) => {
                               crowdsale.setFundsManagerAddress(FundsManager.address)
                               crowdsale.setReferrerStorageAddress(ReferrerStorage.address)
                               crowdsale.setBankAddress(Bank.address)
                             })
            FundsManager.deployed()
                        .then((fundsManager) => {
                          fundsManager.addAddressToWhitelist(OneToTwoCrowdsale.address)
                        })
            ReferrerStorage.deployed()
                         .then((referrerStorage) => {
                           referrerStorage.addAddressToWhitelist(OneToTwoCrowdsale.address)
                         })
            Bank.deployed()
                .then((bank) => {
                  bank.addAddressToWhitelist(OneToTwoCrowdsale.address)
                })
          })
}
