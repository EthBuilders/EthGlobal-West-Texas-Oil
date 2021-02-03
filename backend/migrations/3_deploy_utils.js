const Selector = artifacts.require("Selector");
const Token = artifacts.require("Token");

module.exports = function (deployer) {
  deployer.deploy(Selector);
  deployer.deploy(Token);
};
