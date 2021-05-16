const TrackElection = artifacts.require("TrackElection");

module.exports = async function(_deployer) {
  const Melody = artifacts.require("Melody")
  const melody = await Melody.deployed()

  const Track = artifacts.require("Track")
  const track = await Track.deployed()

  await _deployer.deploy(
    TrackElection, 
    (Date.now() / 1000 | 0) + 60,         // starting time, now + 60s
    (Date.now() / 1000 | 0) + 60 * 60,    // ending time, now + 60min
    melody.address,
    track.address,
    10,                                   // 10 MELD = 1/2 star
    5                                     // 5% prize fee
  )
};
