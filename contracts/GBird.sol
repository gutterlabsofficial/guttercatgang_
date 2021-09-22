// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface GSpecies {
	function burn(uint256 _tokenId) external;

	function balanceOf(address owner) external view returns (uint256);
}

contract GBird is ERC721Enumerable, Ownable, Pausable, ReentrancyGuard {
	using Strings for uint256;

	GSpecies public gutterSpecies;

	uint256 public tokenIndex = 0;
	uint256 public maxSupply = 3000; //no more than 3k

	string private _baseTokenURI = "ipfs://xxx/";
	string private _contractURI = "ipfs://xxxx";

	event CAction(uint256 nftID, uint256 value, uint256 actionID, string payload);

	constructor(address _gutterSpeciesContract) ERC721("Gutter Birds", "GBIRD") {
		gutterSpecies = GSpecies(_gutterSpeciesContract);
	}

	//gives you a dog if you own a gutter species pass from 1 to 3000
	function mint(uint256 passID) public whenNotPaused nonReentrant {
		require(gutterSpecies.balanceOf(msg.sender) > 0, "you have to own this pass with this id");
		require(passID <= 3000, "id must <= 3000");
		require(passID > 0, "id must > 0");

		//must call setApprovalForAll(THIS_CONTRACT_ADDRESS, true) for this to work
		gutterSpecies.burn(passID);

		_mintToken(_msgSender());
	}

	/* @dev
	 * Internal mint function
	 */
	function _mintToken(address destinationAddress) private {
		tokenIndex++;
		require(!_exists(tokenIndex), "Token already exist.");
		_safeMint(destinationAddress, tokenIndex);
	}

	function cAction(
		uint256 nftID,
		uint256 id,
		string memory what
	) external payable {
		require(ownerOf(nftID) == msg.sender, "NFT ownership required");
		emit CAction(nftID, msg.value, id, what);
	}

	function tokensOfOwner(
		address owner,
		uint256 start,
		uint256 limit
	) external view returns (uint256[] memory) {
		uint256 tokenCount = balanceOf(owner);
		if (tokenCount == 0) {
			return new uint256[](0);
		} else {
			uint256[] memory result = new uint256[](tokenCount);
			uint256 index;
			for (index = start; index < limit; index++) {
				result[index] = tokenOfOwnerByIndex(owner, index);
			}
			return result;
		}
	}

	function burn(uint256 tokenId) public virtual {
		require(_isApprovedOrOwner(_msgSender(), tokenId), "caller is not owner nor approved");
		_burn(tokenId);
	}

	function exists(uint256 _tokenId) external view returns (bool) {
		return _exists(_tokenId);
	}

	function isApprovedOrOwner(address _spender, uint256 _tokenId) external view returns (bool) {
		return _isApprovedOrOwner(_spender, _tokenId);
	}

	function contractURI() public view returns (string memory) {
		return _contractURI;
	}

	function tokenURI(uint256 _tokenId) public view override returns (string memory) {
		require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
		return string(abi.encodePacked(_baseTokenURI, _tokenId.toString()));
	}

	function withdrawETH() public onlyOwner {
		payable(msg.sender).transfer(address(this).balance);
	}

	function getBackAToken(IERC20 erc20Token) public onlyOwner {
		erc20Token.transfer(msg.sender, erc20Token.balanceOf(address(this)));
	}

	function setBaseURI(string memory newBaseURI) public onlyOwner {
		_baseTokenURI = newBaseURI;
	}

	function setContractURI(string memory newuri) public onlyOwner {
		_contractURI = newuri;
	}

	//used to start the minting
	function setPaused(bool _setPaused) public onlyOwner {
		return (_setPaused) ? _pause() : _unpause();
	}

	function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {
		if (_i == 0) {
			return "0";
		}
		uint256 j = _i;
		uint256 len;
		while (j != 0) {
			len++;
			j /= 10;
		}
		bytes memory bstr = new bytes(len);
		uint256 k = len;
		while (_i != 0) {
			k = k - 1;
			uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
			bytes1 b1 = bytes1(temp);
			bstr[k] = b1;
			_i /= 10;
		}
		return string(bstr);
	}
}
