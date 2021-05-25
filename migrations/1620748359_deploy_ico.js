const Crowdsale = artifacts.require("Crowdsale");

const deploy = true;

module.exports = async function(_deployer) {
  if(deploy) {
    const Melody = artifacts.require("Melody")
    const melody = await Melody.deployed()

    const endtime = (Date.now() / 1000 | 0) + 60 * 60 * 24 * 90 // 3 months

    const crowdsale = await _deployer.deploy(
      Crowdsale, 
      (Date.now() / 1000 | 0) + 60 * 5, // starting time, now + 5min
      endtime,
      melody.address,
      `55${"0".repeat(26)}`, // amount of token to release -- 8bln
      [
        {
          rate: 100000,
          lower_limit: 0,
          upper_limit: `1${"0".repeat(27)}`   // 1bln
        },
        {
          rate: 85000,
          lower_limit: `1${"0".repeat(27)}`,
          upper_limit: `25${"0".repeat(26)}`   // 2.5bln
        },
        {
          rate: 70000,
          lower_limit: `25${"0".repeat(26)}`,
          upper_limit: `4${"0".repeat(27)}`  // 4bln
        },
        {
          rate: 55000,
          lower_limit: `4${"0".repeat(27)}`,
          upper_limit: `55${"0".repeat(26)}`  // 5.5bln
        },
        // ~ 76,348.3575 BNB = ~ 45,809,014.5 $ (1:600) || ~ 30,539,343.00 $ (1:400)
      ]
    )
    
    melody.setCrowdsale(crowdsale.address)
    melody.setIcoEndTime(endtime)
  }
  
};
