const Melody = artifacts.require("Melody");

module.exports = async function(_deployer) {
  await _deployer.deploy(Melody);
};
