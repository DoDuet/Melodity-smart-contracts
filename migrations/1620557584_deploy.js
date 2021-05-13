const BEP20 = artifacts.require("MyToken");

module.exports = async function(_deployer) {
  await _deployer.deploy(BEP20);
};
