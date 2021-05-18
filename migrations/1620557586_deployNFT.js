const Track = artifacts.require("Track");

module.exports = async function(_deployer) {
  const Melody = artifacts.require("Melody")
  const melody = await Melody.deployed()

  const track = await _deployer.deploy(
    Track,
    melody.address,
    150       // 150 MELD = song registration fee
  );
};
