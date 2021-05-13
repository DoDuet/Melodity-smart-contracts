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
    return `${prettyNumber(str.substr(0, str.length - decimals)) || 0}.${str.substr(decimals) || 0}`
  }

  const delay = ms => new Promise(res => setTimeout(res, ms));

  tests = {
    buy: false,
    balances: true,
    finalize: false,
    redeeem: false,
  }

  try {
    // Initialize token instance
    const BEP20 = artifacts.require('MyToken')
    const bep = await BEP20.deployed()
    const symbol = await bep.symbol()

    // Retrieve accounts
    const accounts = await web3.eth.getAccounts()
    console.log('Account list', accounts)

    // Retrieve crowdsale contract
    const Crowdsale = artifacts.require('Crowdsale')
    const crowdsale = await Crowdsale.deployed()

    let started = await crowdsale.isStarted()
    while(!started) {
      await delay(1000)
      console.log("Crowdsale started?", started)
      started = await crowdsale.isStarted()
    }

    console.log('token address:', convertToDisplayable(await bep.address))
    console.log(
      'crowdsale address:',
      convertToDisplayable(await crowdsale.address),
    )
    console.log(
      'registered crowdsale in token:',
      convertToDisplayable(await bep.crowdsaleAddress()),
    )

    if (tests.buy) {
      console.group("tests.buy")
      console.log(
        `Balance of ${accounts[1]}: `,
        prettyDecimals(await bep.balanceOf(accounts[1])),
        symbol,
      )

      await crowdsale.buy({ from: accounts[1], value: 1e18 })

      console.log(
        `Balance of ${accounts[1]}: `,
        prettyDecimals(await bep.balanceOf(accounts[1])),
        symbol,
      )
      console.groupEnd()
    }

    console.log("crowdsale balance:", prettyDecimals(await crowdsale.currentBalance()), "BNB")
    console.log("token total supply:", prettyDecimals(await bep.totalSupply()), symbol)

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
          prettyDecimals(await bep.balanceOf(acc)),
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

    callback(0)
  } catch (error) {
    console.error(error)
    callback(1)
  }
}
