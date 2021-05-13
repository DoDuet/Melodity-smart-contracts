const Crowdsale = artifacts.require("Crowdsale");

module.exports = async function(_deployer) {
  const BEP20 = artifacts.require("MyToken")
  const bep = await BEP20.deployed()

  const endtime = (Date.now() / 1000 | 0) + 60 * 60

  const crowdsale = await _deployer.deploy(
    Crowdsale, 
    (Date.now() / 1000 | 0) + 60, // starting time, now + 60s
    endtime,
    4000 + "0".repeat(18), 
    bep.address,
    `1${"0".repeat(18)}`
  )
  
  bep.setCrowdsale(crowdsale.address)
  bep.setIcoEndTime(endtime)
};
