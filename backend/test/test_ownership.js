const BillOfLading = artifacts.require("BillOfLading");

contract("BillOfLading", (accounts) => {
  var instance;

  before("deploy contract", async () => {
    instance = await BillOfLading.deployed({ from: accounts[0] });
  });

  it("should be owned by the deployer", async () => {
    let instance_owner = await instance.owner();
    assert.equal(instance_owner, accounts[0]);
  });

  it("should not be owned by another account", async () => {
    let instance_owner = await instance.owner();
    assert.notEqual(instance_owner, accounts[1]);
  });
});
