// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//Mock ERC721, anyone can mint!
contract ERC721Mock is ERC721Enumerable, Ownable, ReentrancyGuard {
	using Strings for uint256;
	string private _baseTokenURI = "ipfs://xxxx/";
	string private _contractURI = "ipfs://yyyyy";

	constructor() ERC721("erc721 mock", "ERC721") {
		mint(msg.sender, 0);
		mint(msg.sender, 1);
		mint(msg.sender, 2);
		mint(msg.sender, 3);
		mint(msg.sender, 4);
		mint(msg.sender, 5);
	}

	function mint(address to, uint256 tokenID) public virtual nonReentrant {
		_mint(to, tokenID);
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
