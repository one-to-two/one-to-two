const Score = artifacts.require("./Score.sol")

contract('Score', async (accounts) => {

  it("test scoring", async () => {
    const score = await Score.deployed()
    await score.addAddressToWhitelist(accounts[0])
    await score.setMaxLength(2)

    // single player
    await score.addAmount(accounts[0], web3.toWei(0.1, "ether"))
    const top00 = await score.top(0)
    assert.equal(top00, accounts[0], "account 1 is in top players")

    // add player with higher score
    await score.addAmount(accounts[1], web3.toWei(0.2, "ether"))
    const top10 = await score.top(0)
    const top11 = await score.top(1)
    assert.equal(top10, accounts[1], "account 2 has first place")
    assert.equal(top11, accounts[0], "account 1 has second place")

    // add player with minimum score
    await score.addAmount(accounts[2], web3.toWei(0.1, "ether"))
    const top20 = await score.top(0)
    const top21 = await score.top(1)
    assert.equal(top20, accounts[1], "account 2 has first place")
    assert.equal(top21, accounts[0], "account 1 has second place")

    // add player with highest score
    await score.addAmount(accounts[2], web3.toWei(0.2, "ether"))
    const top30 = await score.top(0)
    const top31 = await score.top(1)
    assert.equal(top30, accounts[2], "account 3 has first place")
    assert.equal(top31, accounts[1], "account 2 has second place")
  })

})
