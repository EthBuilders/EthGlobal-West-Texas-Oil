const BillOfLading = artifacts.require("BillOfLading");

contract("BillOfLading", (accounts) => {
  var instance;

  before("deploy contract", async () => {
    instance = await BillOfLading.deployed();
  });

  describe("supportsInterface", () => {
    it("should return true for the ERC165 interfaceID", async () => {
      let result = await instance.supportsInterface("0x01ffc9a7");
      assert.isTrue(result);
    });

    it("should return false for interfaceID '0xffffffff'", async () => {
      let result = await instance.supportsInterface("0xffffffff");
      assert.isFalse(result);
    });
  });
});
