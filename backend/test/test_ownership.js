const BillOfLading = artifacts.require("BillOfLading");

contract("BillOfLading", (accounts) => {
  var instance;

  before("deploy contract", async () => {
    instance = await BillOfLading.deployed({ from: accounts[0] });
  });

  it("should set the deployer as the default admin", async () => {
    let DEFAULT_ADMIN_ROLE = "0x00";
    let deployer_is_instance_admin = await instance.hasRole(
      DEFAULT_ADMIN_ROLE,
      accounts[0]
    );
    let admin_count = await instance.getRoleMemberCount(DEFAULT_ADMIN_ROLE);

    assert.isTrue(deployer_is_instance_admin);
    assert.equal(admin_count, 1);
  });
});
