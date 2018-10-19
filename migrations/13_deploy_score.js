const Score = artifacts.require("./score/Score.sol")
const FundsManager = artifacts.require("./fund/FundsManager.sol")
const AttractionFund = artifacts.require("./fund/attraction/AttractionFund.sol")
const JackpotFund = artifacts.require("./fund/jackpot/JackpotFund.sol")

module.exports = (deployer) => {
  deployer.deploy(Score)
          .then(() => {
            Score.deployed()
                 .then((score) => {
                   score.addAddressToWhitelist(FundsManager.address)
                   score.addAddressToWhitelist(AttractionFund.address)
                   score.addAddressToWhitelist(JackpotFund.address)
                 })
            FundsManager.deployed()
                        .then((fundsManager) => {
                          fundsManager.setScoreAddress(Score.address)
                        })
            AttractionFund.deployed()
                          .then((attractionFund) => {
                            attractionFund.setScoreAddress(Score.address)
                          })
            JackpotFund.deployed()
                       .then((jackpotFund) => {
                         jackpotFund.setScoreAddress(Score.address)
                       })
          })
}
