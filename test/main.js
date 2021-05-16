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
  
	tests = {
		mint: true,
		nft: false,
		nft_delete: false,
	}
  
	try {
		// Initialize token instance
		const Melody = artifacts.require('Melody')
		const melody = await Melody.deployed()
		const symbol = await melody.symbol()

		// Retrieve accounts
		const accounts = await web3.eth.getAccounts()
		console.log('Account list', accounts)

		// Song election instance
		const TrackElection = artifacts.require('TrackElection')
		const track_election = await TrackElection.deployed()

		// Track nft
		const Track = artifacts.require('Track')
		const track = await Track.deployed()

		//	+-----------------------------------------------------------------------------------+
		// 	| Remember to request approval for all the contracts that requires token management |
		//  +-----------------------------------------------------------------------------------+
		for(let acc of accounts) {
			melody.approve(track.address, `1${"0".repeat(36)}`, {from: acc})
			melody.approve(track_election.address, `1${"0".repeat(36)}`, {from: acc})
		}

		// TESTS.MINT
		if(tests.mint) {
			console.group("test.mint")

			const tokens = `300${"0".repeat(18)}`;

			for(let acc of accounts) {
				console.log("Minting", prettyDecimals(tokens), symbol, "to", acc);

				await melody.mint(acc, tokens)

				console.log(
					"Balance of",
					acc,
					prettyDecimals(await melody.balanceOf(acc)),
					symbol,
				)
				console.log(
					"Balance of",
					acc,
					prettyDecimals(await web3.eth.getBalance(acc)),
					"BNB"
				)
				console.log()
			}

			console.groupEnd()
		}
		

		// TESTS.NFT
		if(tests.nft) {
			console.group("test.nft")
			
			console.log(
				"Balance of NFT",
				accounts[1] + ":",
				convertToDisplayable(await track.balanceOf(accounts[1])),
			)
			
			// The fucking approval is locked due to the fucking ico
			await track.registerTrack(accounts[1], "https://example.com/0", {from: accounts[1]})

			console.log(
				"Balance of NFT",
				accounts[1] + ":",
				convertToDisplayable(await track.balanceOf(accounts[1])),
			)

			console.log(
				"Checking track if owner is",
				accounts[1] + ":",
				accounts[1] == (await track.ownerOf(1)).toString()
			)
			console.log(
				"Getting token uri",
				await track.tokenURI(1)
			)
			console.log(
				"Balance of",
				accounts[1],
				prettyDecimals(await melody.balanceOf(accounts[1])),
				symbol,
			)
			console.log(
				"Balance of",
				accounts[1],
				prettyDecimals(await web3.eth.getBalance(accounts[1])),
				"BNB"
			)
			console.log()

			console.groupEnd()
		}


		// TESTS.NFT_DELETE
		if(tests.nft_delete) {
			console.group("test.nft")

			// This should throw an error
			console.log("The following call will thrown an error")
			try {
				await track.deleteTrack(1)
			}
			catch (e) {
				console.error(e.message)
			}

			await track.deleteTrack(1, {from: accounts[1]})
			console.log("Track deleted")

			console.groupEnd()
		}

		callback(0)
	} catch (error) {
	  console.error(error.message)
	  callback(1)
	}
  }