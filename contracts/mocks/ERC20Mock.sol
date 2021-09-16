// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";

contract ERC20Mock is ERC20PresetFixedSupply {
	constructor()
		ERC20PresetFixedSupply("ERC20 Contract", "ERC20", 100000000000000000000000000000, msg.sender)
	{}
}
