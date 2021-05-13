import {
  convertToDisplayable,
  convertToNumber,
  prettyNumber,
  dropDecimals,
  prettyDecimals,
} from './helper'

module.exports = async function main(callback) {
  try {
    // Initialize token instance
    const BEP20 = artifacts.require('MyToken')
    const bep = await BEP20.deployed()

    // Retrieve accounts
    const accounts = await web3.eth.getAccounts()
    console.log('Account list', accounts)

    // Retrieve crowdsale contract
    const Crowdsale = artifacts.require("Crowdsale")
    const crowdsale = await Crowdsale.deployed()

    console.log("token address", bep.address)
    console.log("crowdsale address", crowdsale.address)
    console.log("registered crowdsale in token", )

    callback(0)
  } catch (error) {
    console.error(error)
    callback(1)
  }
}
