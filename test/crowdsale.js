module.exports = async function main(callback) {
  const convertToNumber = (raw) => {
    return +convertToDisplayable(raw)
  }

  const convertToDisplayable = (raw) => {
    return raw.toString()
  }

  const prettyNumber = (x) => {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')
  }

  const dropDecimals = (number, decimals = 18) => {
    const str = number.toString()
    return str.substr(0, str.length - decimals)
  }

  const prettyDecimals = (number, decimals = 18) => {
    const str = number.toString()
    return `${prettyNumber(str.substr(0, str.length - decimals)) || 0}.${str.substr(str.length - decimals) || 0}`
  }

  const convertDate = (inputFormat) => {
    const pad = (s) => (s < 10) ? '0' + s : s;
    var d = new Date(inputFormat)
    return [pad(d.getDate()), pad(d.getMonth()+1), d.getFullYear()].join('/') + " " +
      [pad(d.getHours()), pad(d.getMinutes()), pad(d.getSeconds())].join(":")
  }

  tests = {
    buy: true,
    balances: true,
    finalize: false,
    redeeem: true,
    getters: true
  }

  try {
    // Initialize token instance
    const Melodity = artifacts.require('Melodity')
    const melodity = await Melodity.deployed()
    const symbol = await melodity.symbol()

    // Retrieve accounts
    const accounts = await web3.eth.getAccounts()
    for(let acc of accounts) {
			console.log(
				"Balance of ",
				acc,
				prettyDecimals(await melodity.balanceOf(acc)),
				symbol
			)
			console.log(
				"Balance of",
				acc,
				prettyDecimals(await web3.eth.getBalance(acc)),
				"BNB"
			)
		}

    // Retrieve crowdsale contract
    const Crowdsale = artifacts.require('MelodityCrowdsale')
    const crowdsale = await Crowdsale.deployed()

    console.log('token address:', convertToDisplayable(await melodity.address))
    console.log(
      'crowdsale address:',
      convertToDisplayable(await crowdsale.address),
    )

    console.log("crowdsale start time:", convertDate((await crowdsale.getStartingTime()) * 1000))
    console.log("crowdsale end time:", convertDate((await crowdsale.getEndingTime()) * 1000))

    /**
     * +-----------------------------------+
     * |  Set up crowdsale contract funds  |
     * +-----------------------------------+
     */
    console.log("crowdsale contract balance:", prettyDecimals(await melodity.balanceOf(convertToDisplayable(await crowdsale.address))))
    console.log(`Balance of ${accounts[0]}:`, prettyDecimals(await melodity.balanceOf(accounts[0])))
    await melodity.transfer(
      convertToDisplayable(await crowdsale.address),
      convertToDisplayable(await melodity.balanceOf(accounts[0])), 
      {from: accounts[0]}
    )
    console.log("crowdsale contract balance:", prettyDecimals(await melodity.balanceOf(convertToDisplayable(await crowdsale.address))))
    console.log(`Balance of ${accounts[0]}:`, prettyDecimals(await melodity.balanceOf(accounts[0])))

    /**
     * +---------------------------------------+
     * |  Set up crowdsale start and end time  |
     * +---------------------------------------+
     */
    await crowdsale.setStartTime((Date.now() / 1000 | 0) + 2) // starting time, now + 2s
    await crowdsale.setEndTime((Date.now() / 1000 | 0) + 60 * 10) // starting time, now + 10min
    console.log("crowdsale start time:", convertDate((await crowdsale.getStartingTime()) * 1000))
    console.log("crowdsale end time:", convertDate((await crowdsale.getEndingTime()) * 1000))

    /**
     * +----------------------------------+
     * |  Set up crowdsale selling tiers  |
     * +----------------------------------+
     */
    console.log("crowdsale selling tiers:", await crowdsale.getTiers())
    await crowdsale.setPaymentTiers([
      {
        rate: 2500000, // TODO: 15000
        lower_limit: 0,
        upper_limit: `25000000${"0".repeat(18)}`,  // 25 million
      },
      {
        rate: 10000000, // TODO: 10000
        lower_limit: `25000000${"0".repeat(18)}`,  // 25 million
        upper_limit: `125000000${"0".repeat(18)}`,  // 125 million
      },
      {
        rate: 10000000, // TODO: 7500
        lower_limit: `125000000${"0".repeat(18)}`,  // 125 million
        upper_limit: `225000000${"0".repeat(18)}`,  // 225 million
      },
      {
        rate: 10000000, // TODO: 4000
        lower_limit: `225000000${"0".repeat(18)}`,  // 225 million
        upper_limit: `325000000${"0".repeat(18)}`,  // 325 million
      },
      {
        rate: 2500000, // TODO: 2000
        lower_limit: `325000000${"0".repeat(18)}`,  // 325 million
        upper_limit: `350000000${"0".repeat(18)}`,  // 350 million
      },
    ], {from: accounts[0]})
    console.log("crowdsale selling tiers:", await crowdsale.getTiers())
    
    /**
     * +-------------------------+
     * |  Init crowdsale supply  |
     * +-------------------------+
     */
    console.log("initializing crowdsale supply")
    await crowdsale.initSupply()

    console.log("waiting for crowsale start")
    await new Promise(r => setTimeout(r, 3000));
    console.log("crowdsale should be started")

    if (tests.buy) {
      console.group("tests.buy")
      console.log(
        `Balance of ${accounts[1]}: `,
        prettyDecimals(await melodity.balanceOf(accounts[1])),
        symbol,
      )

      // due to the precence of the loop the gas amount must be very high
      await web3.eth.sendTransaction({to: convertToDisplayable(await crowdsale.address), from:accounts[1], value:51e18, gas: 1e6})

      console.log(
        `Balance of ${accounts[1]}: `,
        prettyDecimals(await melodity.balanceOf(accounts[1])),
        symbol,
      )
      console.groupEnd()
    }

    console.log("crowdsale balance:", prettyDecimals(await crowdsale.getBalance()), "BNB")
    console.log("token total supply:", prettyDecimals(await melodity.totalSupply()), symbol)

    if(tests.finalize) {
      console.group("tests.finalize")
      console.log("Finalized: ", await crowdsale.isCompleted())

      await crowdsale.finalize()

      console.log("Finalized: ", await crowdsale.isCompleted())
      console.groupEnd()
    }
    
    if(tests.redeeem) {
      console.group("tests.redeeem")

      await crowdsale.redeem()

      console.groupEnd()
    }

    if(tests.balances) {
      console.group("tests.balances")

      for(let acc of accounts) {
        console.group(`Balance of ${acc}: `)
        console.log(
          prettyDecimals(await melodity.balanceOf(acc)),
          symbol,
        )
        console.log(
          prettyDecimals(await web3.eth.getBalance(acc)),
          "BNB"
        )
        console.groupEnd()
      }

      console.groupEnd()
    }

    if(tests.getters) {
      console.group("tests.getters")

      console.log(
        "crowdsale.getBalance()",
        prettyDecimals(await crowdsale.getBalance()),
        "BNB",
      )
      console.log(
        "crowdsale.getMinted()",
        prettyDecimals(await crowdsale.getDistributed()),
        symbol,
      )
      console.log(
        "crowdsale.getStartingTime()",
        convertDate((await crowdsale.getStartingTime()) * 1000),
      )
      console.log(
        "crowdsale.getEndingTime()",
        convertDate((await crowdsale.getEndingTime()) * 1000),
      )
      console.log(
        "crowdsale.getSupply()",
        prettyDecimals(await crowdsale.getSupply()),
        symbol,
      )
      console.log(
        "crowdsale.getTiers()",
        JSON.stringify(await crowdsale.getTiers(), null, 4),
      )

      console.groupEnd()
    }

    callback(0)
  } catch (error) {
    console.error(error)
    callback(1)
  }
}
