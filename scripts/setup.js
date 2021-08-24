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

  try {
    const melodity_abi = [{"inputs":[],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"spender","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"uint256","name":"value","type":"uint256"}],"name":"Transfer","type":"event"},{"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"spender","type":"address"}],"name":"allowance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"approve","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"subtractedValue","type":"uint256"}],"name":"decreaseAllowance","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"addedValue","type":"uint256"}],"name":"increaseAllowance","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"transfer","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"sender","type":"address"},{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint256","name":"amount","type":"uint256"}],"name":"transferFrom","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"}]
    const crowdsale_abi = [{"inputs":[{"internalType":"uint256","name":"_start","type":"uint256"},{"internalType":"uint256","name":"_end","type":"uint256"},{"internalType":"contract Melodity","name":"_token","type":"address"},{"components":[{"internalType":"uint256","name":"rate","type":"uint256"},{"internalType":"uint256","name":"lower_limit","type":"uint256"},{"internalType":"uint256","name":"upper_limit","type":"uint256"}],"internalType":"struct MelodityCrowdsale.PaymentTier[]","name":"_payment_tier","type":"tuple[]"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"Buy","type":"event"},{"anonymous":false,"inputs":[],"name":"Finalize","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"Redeemed","type":"event"},{"anonymous":false,"inputs":[],"name":"SalePaused","type":"event"},{"anonymous":false,"inputs":[],"name":"SaleResumed","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"_supply","type":"uint256"}],"name":"SupplyInitialized","type":"event"},{"inputs":[],"name":"buy","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[{"internalType":"uint256","name":"funds","type":"uint256"}],"name":"computeTokensAmount","outputs":[{"internalType":"uint256","name":"","type":"uint256"},{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"emergencyRedeem","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"getBalance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getDistributed","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getEndingTime","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getStartingTime","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getTiers","outputs":[{"components":[{"internalType":"uint256","name":"rate","type":"uint256"},{"internalType":"uint256","name":"lower_limit","type":"uint256"},{"internalType":"uint256","name":"upper_limit","type":"uint256"}],"internalType":"struct MelodityCrowdsale.PaymentTier[]","name":"","type":"tuple[]"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"initSupply","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"isPaused","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"isStarted","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"pause","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"redeem","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"resume","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_end","type":"uint256"}],"name":"setEndTime","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"components":[{"internalType":"uint256","name":"rate","type":"uint256"},{"internalType":"uint256","name":"lower_limit","type":"uint256"},{"internalType":"uint256","name":"upper_limit","type":"uint256"}],"internalType":"struct MelodityCrowdsale.PaymentTier[]","name":"_payment_tier","type":"tuple[]"}],"name":"setPaymentTiers","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"uint256","name":"_start","type":"uint256"}],"name":"setStartTime","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"}]

    const melodity_contract = '0x93eFB0E24bb4B9F96789e2C80fd634D10690eC57'
    const crowdsale_contract = '0xA4c7FAe6763b60e6aFB15036EC053d75dF3291F8'

    // Retrieve accounts
    const accounts = await web3.eth.getAccounts()
    const owner = accounts[0]
    console.log(owner)

    // Retrieve contracts
    const melodity = await web3.eth.Contract(melodity_abi, melodity_contract, {
      from: accounts[2] // temporary storage of ico funds
    })
    const crowdsale = await web3.eth.Contract(crowdsale_abi, crowdsale_contract, {
      from: accounts[0] // contract owner
    })

    /**
     * +-----------------------------------+
     * |  Set up crowdsale contract funds  |
     * +-----------------------------------+
     * funds should be moved to the contract before executing this script
     */
    console.log(
      '[+] Crowdsale contract balance:',
      prettyDecimals(await melodity.methods.balanceOf(crowdsale_contract)),
    )
    

    /**
     * +---------------------------------------+
     * |  Set up crowdsale start and end time  |
     * +---------------------------------------+
     */
    await crowdsale.methods.setStartTime(((Date.now() / 1000) | 0) + 2) // starting time, now + 2s
    await crowdsale.methods.setEndTime(((Date.now() / 1000) | 0) + 60 * 10) // starting time, now + 10min
    console.log(
      '[+] Crowdsale start time:',
      convertDate((await crowdsale.methods.getStartingTime()) * 1000),
    )
    console.log(
      '[+] Crowdsale end time:',
      convertDate((await crowdsale.methods.getEndingTime()) * 1000),
    )

    /**
     * +----------------------------------+
     * |  Set up crowdsale selling tiers  |
     * +----------------------------------+
     */
    console.log('[+] Crowdsale selling tiers:', await crowdsale.methods.getTiers())
    await crowdsale.methods.setPaymentTiers(
      [
        {
          rate: 15000,
          lower_limit: 0,
          upper_limit: `25000000${'0'.repeat(18)}`, // 25 million
        },
        {
          rate: 10000,
          lower_limit: `25000000${'0'.repeat(18)}`, // 25 million
          upper_limit: `125000000${'0'.repeat(18)}`, // 125 million
        },
        {
          rate: 7500,
          lower_limit: `125000000${'0'.repeat(18)}`, // 125 million
          upper_limit: `225000000${'0'.repeat(18)}`, // 225 million
        },
        {
          rate: 4000,
          lower_limit: `225000000${'0'.repeat(18)}`, // 225 million
          upper_limit: `325000000${'0'.repeat(18)}`, // 325 million
        },
        {
          rate: 2000,
          lower_limit: `325000000${'0'.repeat(18)}`, // 325 million
          upper_limit: `350000000${'0'.repeat(18)}`, // 350 million
        },
      ],
      { from: accounts[0] },
    )
    console.log('[+] Crowdsale selling tiers:', await crowdsale.methods.getTiers())

    /**
     * +-------------------------+
     * |  Init crowdsale supply  |
     * +-------------------------+
     */
    console.log('[+] Initializing crowdsale supply')
    await crowdsale.methods.initSupply()

    console.log("Intialization completed, check the onchain values")
  } catch (error) {
    console.error(error)
    callback(1)
  }
}
