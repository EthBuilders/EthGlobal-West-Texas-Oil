const BillOfLading = artifacts.require("BillOfLading");

contract("BillOfLading", (accounts) => {
  it("should be owned by the deployer", async () => {
    let instance = await BillOfLading.deployed({ from: accounts[0] });
    let instance_owner = await instance.owner();
    assert.equal(instance_owner, accounts[0]);
  });
});
