const BillOfLading = artifacts.require("BillOfLading");
const DBol = artifacts.require("DBol");
const { default: Web3 } = require("web3");
const web3 = require("web3");

module.exports = async function (deployer, accounts) {
  //ganache-cli --gasLimit 0xfffffffffff -g 0x01 --allowUnlimitedContractSize      
  deployer.deploy(DBol, "", "", "").then(() => {
    return deployer.deploy(BillOfLading, "", "", "", DBol.address);
  }).then(async() => {
    let instance = await DBol.deployed();
    tx = instance.grantRole(web3.utils.sha3("MINTER_ROLE"), BillOfLading.address);
  })
};
