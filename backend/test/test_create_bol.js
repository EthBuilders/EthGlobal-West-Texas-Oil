const BillOfLading = artifacts.require("BillOfLading");

const {
  BN, // Big Number support
  constants, // Common constants, like the zero address and largest integers
  expectEvent, // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require("@openzeppelin/test-helpers");
const { assertion } = require("@openzeppelin/test-helpers/src/expectRevert");

contract("BillOfLading", (accounts) => {
  var instance;

  before("create instance", async () => {
    instance = await BillOfLading.deployed({ from: accounts[0] });
  });

  describe("createBill", () => {
    let [shipper, sn, origin, destination, quantity] = [
      accounts[1],
      "13WX78KS011",
      // 40°39'0.36"N, 73°56'58.49"W Brooklyn, New York
      [
        [40, 39, 00360, 0],
        [73, 56, 58490, 3],
      ],
      // 27°56'51.07"N, 82°27'30.35"W Tampa, Florida
      [
        [27, 56, 51070, 0],
        [82, 27, 30350, 3],
      ],
      10000,
    ];
    it("should emit a transfer event", async () => {
      let tx = await instance.createBillOfLading(
        [shipper, sn, origin, destination, quantity],
        { from: accounts[0] }
      );

      expectEvent(tx, "Transfer", {
        from: constants.ZERO_ADDRESS,
        to: accounts[0],
      });
    });
    it("should revert if sender isn't a minter", async () => {
      await expectRevert(
        instance.createBillOfLading(
          [shipper, sn, origin, destination, quantity],
          { from: accounts[1] }
        ),
        "must have minter role to mint"
      );
    });
    it("should mint a token and give to the minter");
    it("should increase the total supply by 1");
  });
});
