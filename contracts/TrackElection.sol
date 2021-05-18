// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Melody.sol";
import "./CommonModifier.sol";
import "./Track.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Router01.sol";
import "./interfaces/IUniswapV2Router02.sol";

contract TrackElection is Ownable, CommonModifier {
    using SafeMath for uint256;
	using EnumerableSet for EnumerableSet.AddressSet;
	using EnumerableSet for EnumerableSet.UintSet;

	event Voted(address voter, uint256 track_id, uint256 half_stars);
	event FeePayed(address payer, uint256 fee);
	event Redeemed(uint256 token_amount, uint256 eth_amount);
	event PrizeForMusician(address musician, uint256 prize, uint8 position);
	event PrizeForInvestor(address investor, uint256 prize, uint8 position);
	event AllPrizesDistributed();
	event NewParticipant(uint256 track_id);

	struct Song {
		address owner;
		uint256 votes;
		EnumerableSet.AddressSet voters;
	}

	struct Ranking {
		uint256 track_id;
		uint256 votes;
	}

	// track => { owner, votes, voters }
	mapping(uint256 => Song) internal participants;
	EnumerableSet.UintSet internal participating_tracks;

	Melody internal token;
	Track internal track;
	uint256 internal participation_fee;
	IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

	modifier canVote(uint256 track_id, uint256 half_stars) {
		require(participating_tracks.contains(track_id), "Track is not participating to the election");
		require(!participants[track_id].voters.contains(msg.sender), "Track already voted");
		require(msg.sender != track.ownerOf(track_id), "Cannot vote your own track");
		_;
	}

	modifier canParticipate(uint256 track_id) {
		require(track.exists(track_id), "Track does not exist");
		require(!participating_tracks.contains(track_id), "Track already marked for participation");
		require(msg.sender == track.ownerOf(track_id), "You can register only your tracks");
		require(token.balanceOf(msg.sender) >= participation_fee, "Not enough funds to participate with this track");
		_;
	}

	constructor(
		uint256 _start, 
		uint256 _end, 
		Melody _token, 
		Track _track, 
		uint256 _participation_fee
	) {
		token = _token;
		start = _start;
		end = _end;
		track = _track;
		participation_fee = _participation_fee * 1 ether;

		// Swap and append to PancakeSwap LP

		// PancakeSwap TestNet router: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
		// PancakeSwap MainNet router: 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F
		IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);

         // Create a uniswap pair for this new token
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
            .createPair(address(token), _uniswapV2Router.WETH());

        // set the rest of the contract variables
        uniswapV2Router = _uniswapV2Router;
	}

	function payVoteFee(uint256 vote_value) internal {}

	function payParticipationFee() internal {
		token.transferFrom(msg.sender, address(this), participation_fee);

		emit FeePayed(msg.sender, participation_fee);
	}

	function participate(uint256 track_id) public canParticipate(track_id) {
		payParticipationFee();

		participating_tracks.add(track_id);

		// Check if the track owner is changed or if it null and update it
		address track_owner = track.ownerOf(track_id);
		// Avoid checking for difference to reduce gas fee
		participants[track_id].owner = track_owner;

		emit NewParticipant(track_id);
	}

	function vote(uint256 track_id, uint256 half_stars) public whenRunning canVote(track_id, half_stars) payable {	
		participants[track_id].votes += half_stars;

		// Add the address of the voter to the set of voters if not yet present
		participants[track_id].voters.add(msg.sender);

		// Addition of tokens is made always in the backend, here will be added 10 MELD
		// The logic for the song completion check will be done on the backend
		// and the tokens will be issued by a backend call, the backend will proxy this call only
		// if the song was listened completely, in that case msg.sender will receive 20 MELD 

		emit Voted(msg.sender, track_id, half_stars);
	} 

	function getBalance() public view returns(uint256) { return address(this).balance; }
	function getTokenBalance() public view returns(uint256) { return token.balanceOf(address(this)); }

	function finalize() public onlyOwner /*whenClosed*/ {
		_finalize();
		_distribute();

		emit AllPrizesDistributed();

		redeem();
	}

	function _swapTrack(Ranking memory new_ranking, Ranking memory old_ranking) internal pure returns(Ranking memory, Ranking memory) {
		if(new_ranking.votes > old_ranking.votes) {
			return (old_ranking, new_ranking);
		}
		return (new_ranking, old_ranking);
	}

	function _distribute() internal {       
		Ranking memory first_place;
		Ranking memory second_place;
		Ranking memory third_place;
		Ranking memory old;

		uint256 track_id;

		for(uint256 i; i < participating_tracks.length(); i++) {
			// caches the current track_id
			track_id = participating_tracks.at(i);

			// Check if current track has more votes than the first one, in case swap them
			(old, first_place) = _swapTrack(
				Ranking({
					votes: participants[track_id].votes, 
					track_id: track_id
				}), 
				first_place
			);

			// Check if the track with less votes in the previous step has more votes than 
			// the one marked as second, in case swap them
			(old, second_place) = _swapTrack(old, second_place);

			// Check if the track with less votes in the previous step has more votes than 
			// the one marked as third, in case swap them, the one with less votes is simply
			// trashed
			(, third_place) = _swapTrack(old, third_place);
		}

		address addr = address(this);
		uint256 balance = token.balanceOf(addr);
		(uint256 first_place_prize, address first_place_address) = _computeMusicianPrize(1, first_place, balance);
		(uint256 second_place_prize, address second_place_address) = _computeMusicianPrize(2, second_place, balance);
		(uint256 third_place_prize, address third_place_address) = _computeMusicianPrize(3, third_place, balance);

		// Send the prizes to the winners and investors
		_sendPrize(first_place.track_id, first_place_address, first_place_prize, 1);
		_sendPrize(second_place.track_id, second_place_address, second_place_prize, 2);
		_sendPrize(third_place.track_id, third_place_address, third_place_prize, 3);

		// burn 12.5% of the remaining prize (equal to the one of the 3rd classified)
		token.burn(third_place_prize);
		
		// 12.5% => 50% platform fee, 50% LP
		uint256 half = third_place_prize / 2;
		// NOTE: half is left on the contract as after the call to _distribute there is an automated call to
		// NOTE: redeem

		// Handle the transfer to the LP (PanckakeSwap)
		// NOTE: Some liquidity must be added to the platform before running this function!!!!
		uint256 initialBalance = address(this).balance;
		uint256 change = half / 2;
		// Swap 50% of the left amount in ETH so that can be added to the LP
		swap(change);
		uint256 newBalance = address(this).balance - initialBalance;
		addToLP(change, newBalance);
	}

	function _computeMusicianPrize(uint8 position, Ranking memory ranking, uint256 balance) internal view returns(uint256, address) {
		// Compute the price for the chosen position
		// 1° --> 37.5%
		// 2° --> 25.0%
		// 3° --> 12.5%
		uint256 prize = (balance * 125 * (position == 1 ? 3 : (position == 2 ? 2 : 1))) / 1000;

		return (prize, participants[ranking.track_id].owner);
	}

	function _sendPrize(
		uint256 track_id, 
		address addr, 
		uint256 prize, 
		uint8 position
	) internal {
		// Track id = 0 will never exist so if it is null the position is not filled
		if(track_id != 0) {
			// send prize to the winner
			token.transfer(addr, prize);

			emit PrizeForMusician(addr, prize, position);
		}
	}

	function redeem() public onlyOwner /*whenClosed*/ {
		address addr = address(this);
		uint256 token_amount = token.balanceOf(addr);
		uint256 eth_amount = addr.balance;

		// Transfer all the tokens (and ether if someone sent it) to the owner
		token.transfer(owner(), token_amount);
		payable(owner()).transfer(eth_amount);

		emit Redeemed(token_amount, eth_amount);
	}

	function swap(uint256 amount) internal {
		// generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = uniswapV2Router.WETH();

		// approve token transfer to cover all possible scenarios
		token.approveFrom(address(this), address(uniswapV2Router), amount);

		// make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
	}

	function addToLP(uint256 tk_amount, uint256 eth_amount) internal {
		// approve token transfer to cover all possible scenarios
		token.approveFrom(address(this), address(uniswapV2Router), tk_amount);

		// add the liquidity
        uniswapV2Router.addLiquidityETH{value: eth_amount}(
            address(token),
            tk_amount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
	}
}