const OneToTwoCrowdsale = artifacts.require("./OneToTwoCrowdsale.sol")
const OneToTwoToken = artifacts.require("../../token/OneToTwoToken.sol")
const Bank = artifacts.require("../../bank/Bank.sol")

contract('OneToTwoCrowdsale (stage 1)', async (accounts) => {

  it("test first stage", async () => {
    const crowdsale = await OneToTwoCrowdsale.deployed()
    const token = await OneToTwoToken.deployed()


    const now = new Date().getTime() / 1000
    await crowdsale.setOpeningTime(1, now - 60)
    await crowdsale.setOpeningTime(2, now + 60)
    await crowdsale.setOpeningTime(3, now + 60)
    await crowdsale.setOpeningTime(4, now + 60)
    await crowdsale.setOpeningTime(5, now + 60)

    const investorAddress = accounts[1]
    const investmentsAmount = web3.toWei(0.5, "ether")
    const stage = await crowdsale.getStage()
    assert.equal(stage.valueOf(), 1, "first stage")
    const totalTokens = await crowdsale.remainingTokens()
    await crowdsale.sendTransaction({ value: investmentsAmount, from: investorAddress })
    const tokensAmount = await token.balanceOf(investorAddress)
    assert.equal(tokensAmount.valueOf(), web3.toWei(10, "ether"), "bought 10 tokens")
    const tokensLeftForSale = await crowdsale.remainingTokens()
    assert.equal(tokensLeftForSale.valueOf(), 9990000000000000000000, "9990 tokens left for sale")
    const bankAmount = await web3.eth.getBalance(Bank.address)
    assert.equal(bankAmount.valueOf(), investmentsAmount, "bank has 1 eth")
  })

})

contract('OneToTwoCrowdsale (stage 2)', async (accounts) => {

  it("test second stage", async () => {
    const crowdsale = await OneToTwoCrowdsale.deployed()
    const token = await OneToTwoToken.deployed()

    const now = new Date().getTime() / 1000
    await crowdsale.setOpeningTime(2, now - 60)
    await crowdsale.setOpeningTime(3, now + 60)
    await crowdsale.setOpeningTime(4, now + 60)
    await crowdsale.setOpeningTime(5, now + 60)

    const investorAddress = accounts[1]
    const investmentsAmount = web3.toWei(0.625, "ether")
    const stage = await crowdsale.getStage()
    assert.equal(stage.valueOf(), 2, "second stage")
    await crowdsale.sendTransaction({ value: investmentsAmount, from: investorAddress})
    const tokensAmount = await token.balanceOf(investorAddress)
    assert.equal(tokensAmount.valueOf(), web3.toWei(10, "ether"), "bought 10 tokens")
  })

})

contract('OneToTwoCrowdsale (stage 3)', async (accounts) => {

  it("test third stage", async () => {
    const crowdsale = await OneToTwoCrowdsale.deployed()
    const token = await OneToTwoToken.deployed()

    const now = new Date().getTime() / 1000
    await crowdsale.setOpeningTime(3, now - 60)
    await crowdsale.setOpeningTime(4, now + 60)
    await crowdsale.setOpeningTime(5, now + 60)

    const investorAddress = accounts[1]
    const investmentsAmount = web3.toWei(0.75, "ether")
    const stage = await crowdsale.getStage()
    assert.equal(stage.valueOf(), 3, "third stage")
    await crowdsale.sendTransaction({ value: investmentsAmount, from: investorAddress})
    const tokensAmount = await token.balanceOf(investorAddress)
    assert.equal(tokensAmount.valueOf(), web3.toWei(10, "ether"), "bought 10 tokens")
  })

})

contract('OneToTwoCrowdsale (stage 4)', async (accounts) => {

  it("test fourth stage", async () => {
    const crowdsale = await OneToTwoCrowdsale.deployed()
    const token = await OneToTwoToken.deployed()

    const now = new Date().getTime() / 1000
    await crowdsale.setOpeningTime(4, now - 60)
    await crowdsale.setOpeningTime(5, now + 60)

    const investorAddress = accounts[1]
    const investmentsAmount = web3.toWei(0.875, "ether")
    const stage = await crowdsale.getStage()
    assert.equal(stage.valueOf(), 4, "fourth stage")
    await crowdsale.sendTransaction({ value: investmentsAmount, from: investorAddress})
    const tokensAmount = await token.balanceOf(investorAddress)
    assert.equal(tokensAmount.valueOf(), web3.toWei(10, "ether"), "bought 10 tokens")
  })

})

contract('OneToTwoCrowdsale (stage 5)', async (accounts) => {

  it("test fifth stage", async () => {
    const crowdsale = await OneToTwoCrowdsale.deployed()
    const token = await OneToTwoToken.deployed()

    const now = new Date().getTime() / 1000
    await crowdsale.setOpeningTime(5, now - 60)

    const investorAddress = accounts[1]
    const investmentsAmount = web3.toWei(1.25, "ether")
    const stage = await crowdsale.getStage()
    assert.equal(stage.valueOf(), 5, "fifth stage")
    await crowdsale.sendTransaction({ value: investmentsAmount, from: investorAddress})
    const tokensAmount = await token.balanceOf(investorAddress)
    assert.equal(tokensAmount.valueOf(), web3.toWei(10, "ether"), "bought 8 tokens")
  })

})

contract('OneToTwoCrowdsale (referral)', async (accounts) => {

  it("test referral purchase", async () => {
    const crowdsale = await OneToTwoCrowdsale.deployed()
    const token = await OneToTwoToken.deployed()

    const now = new Date().getTime() / 1000
    await crowdsale.setOpeningTime(1, now - 60)
    await crowdsale.setOpeningTime(2, now + 60)
    await crowdsale.setOpeningTime(3, now + 60)
    await crowdsale.setOpeningTime(4, now + 60)
    await crowdsale.setOpeningTime(5, now + 60)

    const referrerAddress = accounts[0]
    const investorAddress = accounts[1]
    const investmentsAmount = web3.toWei(0.475, "ether")
    const referrerBalance = web3.eth.getBalance(referrerAddress)

    const price = await crowdsale.getPrice(investorAddress, referrerAddress);
    assert.equal(price[1], true, "has discount")
    assert.equal(price[0].valueOf(), web3.toWei(0.0475, "ether"), "price is ...")
    await crowdsale.buyTokensWithReferrer(referrerAddress, { value: investmentsAmount, from: investorAddress })
    const tokensAmount = await token.balanceOf(investorAddress)
    assert.equal(tokensAmount.valueOf(), web3.toWei(10, "ether"), "bought 10 tokens")

    const newReferrerBalance = web3.eth.getBalance(referrerAddress)
    assert.equal(newReferrerBalance - referrerBalance.valueOf(), web3.toWei(0.095, "ether"), "referrer got 0.095 ether")
  })

})
