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

	const tryUntilDone = async (fn) => {
		let state = false;
		while(!state) {
			try {
				await fn()
				state = true
			}
			catch(e) { console.log(e.message) }
		}
	}
  
	tests = {
		mint: true,
		nft: false,
		nft_delete: false,
		vote: true,
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

		console.log("[+]\tMelody supply", prettyDecimals(await melody.totalSupply()))

		//	+-----------------------------------------------------------------------------------+
		// 	| Remember to request approval for all the contracts that requires token management |
		//  +-----------------------------------------------------------------------------------+
		//  Approval cost 0.00183184 BNB
		//  Vote cost 0.00267458 BNB
		for(let acc of accounts) {
			melody.approve(track.address, `1${"0".repeat(36)}`, {from: acc})
			melody.approve(track_election.address, `1${"0".repeat(36)}`, {from: acc})
			console.log(
				"Balance of ",
				acc,
				prettyDecimals(await melody.balanceOf(acc)),
				symbol
			)
			console.log(
				"Balance of",
				acc,
				prettyDecimals(await web3.eth.getBalance(acc)),
				"BNB"
			)
		}

		// TESTS.MINT
		if(tests.mint) {
			console.group("test.mint")

			const tokens = `300${"0".repeat(18)}`;

			for(let acc of accounts) {
				console.log("Minting", prettyDecimals(tokens), symbol, "to", acc);

				await tryUntilDone(async () => {
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
				})
				console.log()
			}

			console.groupEnd()
		}
		
		await tryUntilDone(async () => {
			console.log("[+]\tMelody supply", prettyDecimals(await melody.totalSupply()))
		})

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

			console.log(
				"Balance of",
				accounts[0],
				prettyDecimals(await melody.balanceOf(accounts[0])),
				symbol,
			)
			console.log(
				"Balance of",
				accounts[0],
				prettyDecimals(await web3.eth.getBalance(accounts[0])),
				"BNB"
			)	

			console.log()

			console.groupEnd()
		}

		await tryUntilDone(async () => {
			console.log("[+]\tMelody supply", prettyDecimals(await melody.totalSupply()))
		})

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


		// TESTS.VOTE
		if(tests.vote) {
			console.group("test.vote")

			console.log("Registering NFT tracks")
			await tryUntilDone(async () => {
				await track.registerTrack(accounts[1], "https://example.com/1", {from: accounts[1]}) // id 1
			}) 
			await tryUntilDone(async () => {
				await track.registerTrack(accounts[2], "https://example.com/2", {from: accounts[2]}) // id 2
			}) 
			await tryUntilDone(async () => {
				await track.registerTrack(accounts[3], "https://example.com/3", {from: accounts[3]}) // id 3
			}) 	

			console.log("Participating to the election")
			await tryUntilDone(async () => {
				await track_election.participate(1, {from: accounts[1]})
			}) 	
			await tryUntilDone(async () => {
				await track_election.participate(2, {from: accounts[2]})
			}) 	
			await tryUntilDone(async () => {
				await track_election.participate(3, {from: accounts[3]})
			}) 	

			console.log("Self voting, the following test should fail")
			try {
				await track_election.vote(1, 2.5 * 2, {from: accounts[1]})
				// Mint the tokens to the voter
				await melody.mint(accounts[1], `10${"0".repeat(18)}`)
			} catch(e) {
				console.log()
				console.error(e.message)
				console.log()
			}

			for(let [id, acc] of accounts.entries()) {
				if(id != 1 && id != 2 && id != 3) {
					console.log(acc, "giving 2.5 full stars to NFT", 2)
					
					await tryUntilDone(async () => {
						await track_election.vote(2, 2.5 * 2, {from: acc})
					}) 
					if(id % 2 === 0){
						await tryUntilDone(async () => {
							await track_election.vote(1, 2.5 * 2, {from: acc})
						}) 
					}
					if(id % 3 === 0){
						await tryUntilDone(async () => {
							await track_election.vote(3, 2.5 * 2, {from: acc})
						}) 
					}
					// Mint the tokens to the voter
					await tryUntilDone(async () => {
						await melody.mint(acc, `10${"0".repeat(18)}`)
					}) 
				}
			}

			console.log(
				"Track election balance",
				prettyDecimals(await track_election.getBalance()),
				"BNB"
			)
			console.log(
				"Track election token balance",
				prettyDecimals(await track_election.getTokenBalance()),
				symbol
			)

			console.log("Finalizing")
			await tryUntilDone(async () => {
				await track_election.finalize()
			}) 
			

			console.log(
				"Track election balance",
				prettyDecimals(await track_election.getBalance()),
				"BNB"
			)
			console.log(
				"Track election token balance",
				prettyDecimals(await track_election.getTokenBalance()),
				symbol
			)
			for(let acc of accounts) {
				console.log(
					"Balance of ",
					acc,
					prettyDecimals(await melody.balanceOf(acc)),
					symbol
				)
				console.log(
					"Balance of",
					acc,
					prettyDecimals(await web3.eth.getBalance(acc)),
					"BNB"
				)
			}

			console.groupEnd()
		}

		console.log("[+]\tMelody supply", prettyDecimals(await melody.totalSupply()))

		callback(0)
	} catch (error) {
	  console.error(error.message)
	  callback(1)
	}
  }