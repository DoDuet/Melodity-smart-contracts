const Melody = artifacts.require("Melody");

module.exports = async function(_deployer) {
  await _deployer.deploy(
    Melody,
    `2${"0".repeat(27)}` // Preminted tokens assigned to the owner of the contract
  );
};
