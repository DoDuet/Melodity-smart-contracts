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
    redeeem: false,
    getters: true
  }

  try {
    // Initialize token instance
    const Melody = artifacts.require('Melody')
    const melody = await Melody.deployed()
    const symbol = await melody.symbol()

    // Retrieve accounts
    const accounts = await web3.eth.getAccounts()
    console.log('Account list', accounts)

    // Retrieve crowdsale contract
    const Crowdsale = artifacts.require('Crowdsale')
    const crowdsale = await Crowdsale.deployed()

    console.log('token address:', convertToDisplayable(await melody.address))
    console.log(
      'crowdsale address:',
      convertToDisplayable(await crowdsale.address),
    )
    console.log(
      'registered crowdsale in token:',
      convertToDisplayable(await melody.crowdsaleAddress()),
    )

    if (tests.buy) {
      console.group("tests.buy")
      console.log(
        `Balance of ${accounts[1]}: `,
        prettyDecimals(await melody.balanceOf(accounts[1])),
        symbol,
      )

      await crowdsale.buy({ from: accounts[1], value: 4e18 })

      console.log(
        `Balance of ${accounts[1]}: `,
        prettyDecimals(await melody.balanceOf(accounts[1])),
        symbol,
      )
      console.groupEnd()
    }

    console.log("crowdsale balance:", prettyDecimals(await crowdsale.getBalance()), "BNB")
    console.log("token total supply:", prettyDecimals(await melody.totalSupply()), symbol)

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
          prettyDecimals(await melody.balanceOf(acc)),
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
        symbol,
      )
      console.log(
        "crowdsale.getMinted()",
        prettyDecimals(await crowdsale.getMinted()),
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
        "crowdsale.getGoal()",
        prettyDecimals(await crowdsale.getGoal()),
        symbol,
      )
      console.log(
        "crowdsale.getTiers()",
        JSON.stringify(await crowdsale.getTiers(), null, 4),
      )
      console.log(
        "crowdsale.getGoal()",
        prettyDecimals(await crowdsale.getGoal()),
        symbol,
      )
      console.log(
        "crowdsale.isCompleted()",
        await crowdsale.isCompleted(),
      )
      console.log(
        "crowdsale.isStarted()",
        await crowdsale.isStarted(),
      )

      console.groupEnd()
    }

    callback(0)
  } catch (error) {
    console.error(error)
    callback(1)
  }
}
