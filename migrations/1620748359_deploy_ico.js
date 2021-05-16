const Crowdsale = artifacts.require("Crowdsale");

const deploy = false;

module.exports = async function(_deployer) {
  if(deploy) {
    const Melody = artifacts.require("Melody")
    const melody = await Melody.deployed()

    const endtime = (Date.now() / 1000 | 0) + 60 * 60

    const crowdsale = await _deployer.deploy(
      Crowdsale, 
      (Date.now() / 1000 | 0) + 60, // starting time, now + 60s
      endtime,
      melody.address,
      `150000${"0".repeat(18)}`, // amount of token to release -- 1mln
      [
        {
          rate: 75000,
          lower_limit: 0,
          upper_limit: `150000${"0".repeat(18)}`
        },
        {
          rate: 50000,
          lower_limit: `150000${"0".repeat(18)}`,
          upper_limit: `100000000000${"0".repeat(18)}`
        },
      ]
    )
    
    melody.setCrowdsale(crowdsale.address)
    melody.setIcoEndTime(endtime)
  }
  
};
