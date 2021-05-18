# Melody-BEP20-Token

Melody token on BNB chain, this repository contains most of the code used.
This repository contains an hard-coded mnemonic used for testing purpose.
The mnemonic used is:

`bleak opinion yard bacon payment process atom tomorrow transfer flat misery where`

Something may not work when testing with ganache as it uses the PancakeSwap contract to 
swap tokens.

## Deploy

To deploy follow the next steps:

1) Ensure the proper contract for the PancakeSwap router is set in TrackElection.sol 
2) Ensure to have enough BNB liquidity for gas fees and to fill the LP (~1 BNB)
3) Deploy Melody
4) Properly set the token rates to release on the ICO
5) Deploy ICO (if needed)
	
	5.1) Set crowdsale address in the Melody

	5.2) Set crowdsale ending time in Melody

6) Wait for the ICO to end and redeem it
7) Deploy Track NFT
8) Create liquidity on PancakeSwap
9) Deploy TrackElection

Every week deploy again the TrackElection contract