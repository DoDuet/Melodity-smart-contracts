const PriceConsumer = artifacts.require("PriceConsumer");

module.exports = async function(_deployer) {
  /**
   * Network: Testnet
   * Aggregator: BNB / USD
   * Address: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
	 *
	 * Network: Mainnet
   * Aggregator: BNB / USD
   * Address: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
   */

  // Only works on testnet and mainnet
  await _deployer.deploy(PriceConsumer, "0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526");
};
