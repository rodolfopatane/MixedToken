const Migrations = artifacts.require("Migrations");
const MixedToken = artifacts.require("MixedToken");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(MixedToken);
};
