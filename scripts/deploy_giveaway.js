const hre = require("hardhat")
require("@nomiclabs/hardhat-web3")
const fs = require("fs-extra")

function sleep(ms) {
	return new Promise((resolve) => {
		setTimeout(resolve, ms)
	})
}

async function main() {
	fs.removeSync("cache")
	fs.removeSync("artifacts")
	await hre.run("compile")

	// We get the contract to deploy
	const NFTToken = await hre.ethers.getContractFactory("FairGiveaway")
	console.log("Deploying Fair Giveaway.")

	let network = process.env.NETWORK ? process.env.NETWORK : "rinkeby"

	console.log(">-> Network is set to " + network)

	// ethers is avaialble in the global scope
	const [deployer] = await ethers.getSigners()
	const deployerAddress = await deployer.getAddress()
	const account = await web3.utils.toChecksumAddress(deployerAddress)
	const balance = await web3.eth.getBalance(account)

	console.log(
		"Deployer Account " + deployerAddress + " has balance: " + web3.utils.fromWei(balance, "ether"),
		"ETH"
	)

	// Polygon (Matic) Mainnet
	// LINK Token	0xb0897686c545045aFc77CF20eC7A532E3120E0F1
	// VRF Coordinator	0x3d2341ADb2D31f1c5530cDC622016af293177AE0
	// Key Hash	0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da
	// Fee	0.0001 LINK

	// Polygon (Matic) Mumbai Testnet
	// LINK Token	0x326C977E6efc84E512bB9C30f76E30c160eD06FB
	// VRF Coordinator	0x8C7382F9D8f56b33781fE506E897a4F1e2d17255
	// Key Hash	0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4
	// Fee	0.0001 LINK

	let vrfCoordinator = "0x3d2341ADb2D31f1c5530cDC622016af293177AE0"
	let linkToken = "0xb0897686c545045aFc77CF20eC7A532E3120E0F1"
	let keyHash = "0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da"
	let fee = 100000000000000 // 0.0001 LINK
	if (network === "polygon_test") {
		vrfCoordinator = "0x8C7382F9D8f56b33781fE506E897a4F1e2d17255"
		linkToken = "0x326C977E6efc84E512bB9C30f76E30c160eD06FB"
		keyHash = "0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4"
		fee = 100000000000000 // 0.0001 LINK
	}

	// constructor(
	// 	address _vrfCoordinator,
	// 	address _linkToken,
	// 	bytes32 _keyHash,
	// 	uint256 _fee
	// ) VRFConsumerBase(_vrfCoordinator, _linkToken) {
	const deployed = await NFTToken.deploy(vrfCoordinator, linkToken, keyHash, fee)

	let dep = await deployed.deployed()

	console.log("Contract deployed to:", dep.address)

	await sleep(45000)
	await hre.run("verify:verify", {
		address: dep.address,
		constructorArguments: [vrfCoordinator, linkToken, keyHash, fee],
	})
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
