// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract FairGiveaway is VRFConsumerBase, Ownable {
	bytes32 internal keyHash;
	uint256 internal fee;

	uint256[] public randomResults; //keeps track of the random number from chainlink
	uint256[][] public expandedResults; //winners list
	uint256 public totalDraws = 0; //drawID is -1
	string[] public ipfsProof; //proof where the snapshot is

	event RandomRequested(bytes32 indexed requestId, address indexed roller);
	event RandomLanded(bytes32 indexed requestId, uint256 indexed result);
	event Winners(uint256 randomResult, uint256[] expandedResult);

	constructor(
		address _vrfCoordinator,
		address _linkToken,
		bytes32 _keyHash,
		uint256 _fee
	) VRFConsumerBase(_vrfCoordinator, _linkToken) {
		keyHash = _keyHash;
		fee = _fee;
	}

	function addGiveawayData(string memory _ipfsProof) external onlyOwner {
		ipfsProof.push(_ipfsProof);
	}

	/**
	 * Requests randomness
	 */
	function getRandomNumber() external onlyOwner returns (bytes32 requestId) {
		require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK in the contract");
		requestId = requestRandomness(keyHash, fee);
		emit RandomRequested(requestId, msg.sender);
		return requestId;
	}

	/**
	 * Callback function used by VRF Coordinator
	 */
	function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
		randomResults.push(randomness);
		totalDraws++;
		emit RandomLanded(requestId, randomness);
	}

	function expand(
		uint256 numWinners,
		uint256 drawId,
		uint256 totalEntries
	) external onlyOwner {
		uint256[] memory expandedValues = new uint256[](numWinners);
		for (uint256 i = 0; i < numWinners; i++) {
			expandedValues[i] =
				(uint256(keccak256(abi.encode(randomResults[drawId], i))) % totalEntries) +
				1;
		}
		expandedResults.push(expandedValues);
		emit Winners(randomResults[drawId], expandedValues);
	}

	function withdrawLink() external onlyOwner {
		LINK.transfer(owner(), LINK.balanceOf(address(this)));
	}
}
