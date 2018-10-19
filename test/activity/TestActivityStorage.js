const ActivityStorage = artifacts.require("./ActivityStorage.sol")

contract('ActivityStorage', async (accounts) => {

  it("activity is incremented", async () => {
    activityStorage = await ActivityStorage.deployed()
    await activityStorage.addAddressToWhitelist(accounts[0])
    await activityStorage.incrementActivity(accounts[0])
    const activity = await activityStorage.getActivity(accounts[0])
    assert.equal(activity.valueOf(), 1, "activity is incremented")
  })

})
