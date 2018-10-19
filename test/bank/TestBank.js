const Bank = artifacts.require("./Bank.sol")

contract('Bank', async (accounts) => {

  it("buy credits", async () => {
    const bank = await Bank.deployed()
    await bank.deposit(accounts[0], { value: web3.toWei(0.1, "ether") })
    const balance = await bank.balances(accounts[0])
    assert.equal(balance, web3.toWei(0.1, "ether"), "has 0.1 ether on balance")
  })

})
