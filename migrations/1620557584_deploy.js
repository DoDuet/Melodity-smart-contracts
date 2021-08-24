const Melodity = artifacts.require("Melodity");

module.exports = async function(_deployer) {
  await _deployer.deploy(
    Melodity
  );
};
