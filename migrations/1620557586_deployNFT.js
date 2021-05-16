const Track = artifacts.require("Track");
const TrackProxy = artifacts.require("TrackProxy")

module.exports = async function(_deployer) {
  const Melody = artifacts.require("Melody")
  const melody = await Melody.deployed()

  const track = await _deployer.deploy(
    Track,
    melody.address,
    100       // 100 MELD = song registration fee
  );
};
