// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract PriceConsumer {

    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Testnet
     * Aggregator: BNB / USD
     * Address: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
	 *
	 * Network: Mainnet
     * Aggregator: BNB / USD
     * Address: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
     */
    constructor(address aggregator) {
        priceFeed = AggregatorV3Interface(aggregator);
    }

    /**
     * Returns the latest price
     */
    function getPrice() public view returns (int) {
        (, int price,,,) = priceFeed.latestRoundData();
        return price;
    }

	/**
		Compute the number of token to change given a fixed price, as float are not accepted
		the value must be ported to integer.
		examples:
			0.01 $ / tkn => 100
			0.001 $ / tkn => 1000
		@param fixed_value The amount of dollar that a token is valued
	 */
	function computeNumberOfToken(uint256 fixed_value) public view returns (uint256) {
		int price = getPrice();
		return uint256(price) * 1e10 * fixed_value;
	}
}