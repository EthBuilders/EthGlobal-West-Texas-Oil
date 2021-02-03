const BillOfLading = artifacts.require("BillOfLading");
const DBol = artifacts.require("DBol");

module.exports = async function (deployer, accounts, web3) {
  //ganache-cli --gasLimit 0xfffffffffff -g 0x01 --allowUnlimitedContractSize      
  deployer.deploy(DBol, "", "", "").then(() => {
    return deployer.deploy(BillOfLading, "", "", "", DBol.address);
  })
};
