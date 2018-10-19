const Game = artifacts.require("./Game.sol")
const Bank = artifacts.require("../bank/Bank.sol")
const DividendsFund = artifacts.require("../fund/DividendsFund.sol")
const JackpotFund = artifacts.require("../fund/jackpot/JackpotFund.sol")
const AttractionFund = artifacts.require("../fund/attraction/AttractionFund.sol")
const RefundFund = artifacts.require("../fund/RefundFund.sol")
const DevelopmentFund = artifacts.require("../fund/DevelopmentFund.sol")

// game 1/2
const oneToTwoType = 10002

contract('Game', async (accounts) => {

  it("try to bet two times on the same table", async () => {
    const game = await Game.deployed()
    const bank = await Bank.deployed()
    await bank.deposit(accounts[0], { value: web3.toWei(0.05, "ether") })
    await game.bet(oneToTwoType, accounts[2], { from: accounts[0] })
    let error
    try {
      await game.bet(oneToTwoType, accounts[2], { from: accounts[0] })
    } catch (err) {
        error = err
    }
    assert.ok(error instanceof Error)
  });

});

contract('Game', async (accounts) => {

  it("main game scenario", async () => {
    const game = await Game.deployed()
    const bank = await Bank.deployed()
    const dividendsFund = await DividendsFund.deployed()
    const jackpotFund = await JackpotFund.deployed()
    const attractionFund = await AttractionFund.deployed()
    const refundFund = await RefundFund.deployed()
    const developmentFund = await DevelopmentFund.deployed()
    await bank.deposit(accounts[1], { value: web3.toWei(0.05, "ether") })
    await bank.deposit(accounts[2], { value: web3.toWei(0.05, "ether") })
    await game.bet(oneToTwoType, 0, { from: accounts[1] })
    await game.bet(oneToTwoType, 0, { from: accounts[2] })

    const developmentFundValue = await developmentFund.value()
    assert.equal(developmentFundValue.valueOf(), web3.toWei(0.002, "ether"), "development fund is increased on 0.002")
    const dividendsFundValue = await dividendsFund.value()
    assert.equal(dividendsFundValue.valueOf(), web3.toWei(0.003, "ether"), "dividends fund is increased on 0.003")
    const jackpotFundValue = await jackpotFund.value()
    assert.equal(jackpotFundValue.valueOf(), web3.toWei(0.002, "ether"), "jackpot fund is increased on 0.002")
    const attractionFundValue = await attractionFund.value()
    assert.equal(attractionFundValue.valueOf(), web3.toWei(0.002, "ether"), "attraction fund is increased on 0.002")
    const refundFundValue = await refundFund.value()
    assert.equal(refundFundValue.valueOf(), web3.toWei(0.001, "ether"), "refund fund is increased on 0.001")

    const table = await game.tablesByType(oneToTwoType, 0)
    assert.equal(table[0], 1, "table is created with id = 1")
    assert.equal(table[1].valueOf(), 1, "table status is FINISHED")

    const player1Balance = await bank.balances(accounts[1])
    const player2Balance = await bank.balances(accounts[2])
    let winner
    let loser
    if (player1Balance.valueOf() > player2Balance.valueOf()) {
      winnerBalance = player1Balance.valueOf();
    } else {
      winnerBalance = player2Balance.valueOf();
    }

    assert.equal(winnerBalance, web3.toWei(0.09, "ether"), "winner has 0.09 eth balance")
  })

})

contract('Game', async (accounts) => {

  it("test referral payment", async () => {
    const game = await Game.deployed()
    const bank = await Bank.deployed()
    await bank.deposit(accounts[1], { value: web3.toWei(0.05, "ether") })
    await game.bet(oneToTwoType, accounts[2], { from: accounts[1] })
    const player2Balance = await bank.balances(accounts[2])
    assert.equal(player2Balance.valueOf(), web3.toWei(0.00025, "ether"), "referrer received 0.00025 eth to balance")
  })

})
