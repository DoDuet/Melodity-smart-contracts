const TrackElection = artifacts.require("TrackElection");

module.exports = async function(_deployer) {
  const Melody = artifacts.require("Melody")
  const melody = await Melody.deployed()

  const Track = artifacts.require("Track")
  const track = await Track.deployed()

  await _deployer.deploy(
    TrackElection, 
    (Date.now() / 1000 | 0) + 5 * 60,         // starting time, now + 5min
    (Date.now() / 1000 | 0) + 60 * 60 * 24 * 90,    // ending time, now + 90gg
    melody.address,
    track.address,
    100                                   // participation fee, 100 MELD
  )
};
