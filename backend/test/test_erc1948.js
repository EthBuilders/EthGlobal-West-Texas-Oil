const BillOfLading = artifacts.require("BillOfLading");

const {
  constants, // Common constants, like the zero address and largest integers
  expectEvent, // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require("@openzeppelin/test-helpers");
const { assertion } = require("@openzeppelin/test-helpers/src/expectRevert");
const { web3 } = require("@openzeppelin/test-helpers/src/setup");

contract("Bill Of Lading", (accounts) => {
  var instance;

  before("create instance", async () => {
    instance = await BillOfLading.deployed();
    await instance.mint(accounts[0]);
  });

  describe("writeData", () => {
    it("should emit a DataUpdated event", async () => {
      var _newData = web3.utils.asciiToHex("Hello World");
      let tx = await instance.writeData(0, _newData);
      expectEvent(tx, "DataUpdated");
    });
  });
  describe("readData", () => {
    it("should read the event in storage", async () => {
      let data = await instance.readData(0, { from: accounts[0] });
      assert.equal(
        data,
        web3.utils.padRight(web3.utils.asciiToHex("Hello World"), 64)
      );
    });
  });
});
