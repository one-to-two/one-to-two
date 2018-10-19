const FundsManager = artifacts.require("./FundsManager.sol")
const AttractionFund = artifacts.require("../fund/attraction/AttractionFund.sol")
const RefundFund = artifacts.require("../fund/RefundFund.sol")
const AdvertiseFund = artifacts.require("../fund/AdvertiseFund.sol")
const AdvisersFund = artifacts.require("../fund/AdvisersFund.sol")

contract('FundsManager', async (accounts) => {

  it("fill funds", async () => {
    const fundsManager = await FundsManager.deployed()
    const attractionFund = await AttractionFund.deployed()
    const refundFund = await RefundFund.deployed()
    const advertiseFund = await AdvertiseFund.deployed()
    const advisersFund = await AdvisersFund.deployed()

    await fundsManager.addAddressToWhitelist(accounts[0])
    await fundsManager.fillFunds(web3.toWei(100, "ether"))

    const attractionFundValue = await attractionFund.value()
    assert.equal(attractionFundValue.valueOf(), web3.toWei(55, "ether"), "attraction fund is increased on 55%")
    const refundFundValue = await refundFund.value()
    assert.equal(refundFundValue.valueOf(), web3.toWei(30, "ether"), "refund fund is increased on 30%")
    const advertiseFundValue = await advertiseFund.value()
    assert.equal(advertiseFundValue.valueOf(), web3.toWei(10, "ether"), "advertise fund is increased on 10%")
    const advisersFundValue = await advisersFund.value()
    assert.equal(advisersFundValue.valueOf(), web3.toWei(5, "ether"), "advisers fund is increased on 5%")
  })

})
