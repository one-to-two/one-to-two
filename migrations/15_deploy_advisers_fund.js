const AdvisersFund = artifacts.require("./fund/AdvisersFund.sol")
const Bank = artifacts.require("./bank/Bank.sol")
const FundsManager = artifacts.require("./fund/FundsManager.sol")

module.exports = (deployer) => {
  deployer.deploy(AdvisersFund, Bank.address)
          .then(() => {
            AdvisersFund.deployed()
                        .then((fund) => {
                          fund.addAddressToWhitelist(FundsManager.address)
                        })
            Bank.deployed()
                .then((bank) => {
                  bank.addAddressToWhitelist(AdvisersFund.address)
                })
            FundsManager.deployed()
                        .then((fundsManager) => {
                          fundsManager.setAdvisersFundAddress(AdvisersFund.address)
                        })
          })
}
