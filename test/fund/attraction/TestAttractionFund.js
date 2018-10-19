const AttractionFund = artifacts.require("./AttractionFund.sol")
const Bank = artifacts.require("../../bank/Bank.sol")

contract('AttractionFund', async (accounts) => {

  it("bet is returned once", async () => {
    const attractionFund = await AttractionFund.deployed()
    const bank = await Bank.deployed()
    await attractionFund.addAddressToWhitelist(accounts[0])
    await attractionFund.addAddressToWhitelist(accounts[1])
    await attractionFund.add(web3.toWei(0.1, "ether"))
    await attractionFund.returnBet(accounts[0], web3.toWei(0.05, "ether"))
    const balance = await bank.balances(accounts[0])
    assert.equal(balance.valueOf(), web3.toWei(0.05, "ether"), "0.05 ether returned")
    await attractionFund.returnBet(accounts[0], web3.toWei(0.05, "ether"))
    const updatedBalance = await bank.balances(accounts[0])
    assert.equal(updatedBalance.valueOf(), web3.toWei(0.05, "ether"), "0.05 ether is not returned second time")
  })

})
