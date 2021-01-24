const BillOfLading = artifacts.require("BillOfLading");

contract("BillOfLading", (accounts) => {
  var instance;

  before("deploy contract", async () => {
    instance = await BillOfLading.deployed();
  });

  describe("supportsInterface", () => {
    it("should return true for the ERC721 interfaceID", async () => {
      let result = await instance.supportsInterface("0x80ac58cd");
      assert.isTrue(result);
    });

    it("should return true for the ERC721 Metadata extension interfaceID", async () => {
      let result = await instance.supportsInterface("0x5b5e139f");
      assert.isTrue(result);
    });

    it("should return true for the ERC721 Enumerable extension interfaceID", async () => {
      let result = await instance.supportsInterface("0x780e9d63");
      assert.isTrue(result);
    });
  });
});
