const RefundFund = artifacts.require("./fund/RefundFund.sol")
const Bank = artifacts.require("./bank/Bank.sol")
const FundsManager = artifacts.require("./fund/FundsManager.sol")

module.exports = (deployer) => {
  deployer.deploy(RefundFund, Bank.address)
          .then(() => {
            RefundFund.deployed()
                      .then((refundFund) => {
                       refundFund.addAddressToWhitelist(FundsManager.address)
                     })
            Bank.deployed()
                .then((bank) => {
                  bank.addAddressToWhitelist(RefundFund.address)
                })
            FundsManager.deployed()
                        .then((fundsManager) => {
                          fundsManager.setRefundFundAddress(RefundFund.address)
                        })
          })
}
