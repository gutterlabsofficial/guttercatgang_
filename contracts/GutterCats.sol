// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface IERC20 {
	function totalSupply() external view returns (uint256);

	function balanceOf(address account) external view returns (uint256);

	function transfer(address recipient, uint256 amount) external returns (bool);

	function allowance(address owner, address spender) external view returns (uint256);

	function approve(address spender, uint256 amount) external returns (bool);

	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract GutterCats is ERC1155, Ownable {
	using SafeMath for uint256;
	using Strings for string;

	string public _baseURI = "https://github.com/nftinvesting/guttercatgang_/tree/master/j/";
	string public _contractURI =
		"https://raw.githubusercontent.com/nftinvesting/guttercatgang_/master/j/contract_uri";
	mapping(uint256 => string) public _tokenURIs;

	constructor() ERC1155(_baseURI) {}

	function mint(
		address to,
		uint256 id,
		uint256 value,
		bytes memory data
	) public onlyOwner {
		_mint(to, id, value, data);
	}

	function mintBatch(
		uint256[] memory ids,
		uint256[] memory amounts,
		bytes memory data
	) public onlyOwner {
		_mintBatch(_msgSender(), ids, amounts, data);
	}

	function setBaseURI(string memory newuri) public onlyOwner {
		_baseURI = newuri;
	}

	function setContractURI(string memory newuri) public onlyOwner {
		_contractURI = newuri;
	}

	function uri(uint256 tokenId) public view override returns (string memory) {
		return string(abi.encodePacked(_baseURI, uint2str(tokenId)));
	}

	function contractURI() public view returns (string memory) {
		return _contractURI;
	}

	function burn(uint256 id, uint256 value) public {
		_burn(msg.sender, id, value);
	}

	function burnBatch(uint256[] memory ids, uint256[] memory values) public {
		_burnBatch(msg.sender, ids, values);
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

	// withdraw currency accidentally sent to the smart contract
	function withdraw() public onlyOwner {
		uint256 balance = address(this).balance;
		address(msg.sender).transfer(balance);
	}

	// reclaim accidentally sent tokens
	function reclaimToken(IERC20 token) public onlyOwner {
		require(address(token) != address(0));
		uint256 balance = token.balanceOf(address(this));
		token.transfer(msg.sender, balance);
	}
}
