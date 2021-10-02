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
	const NFTToken = await hre.ethers.getContractFactory("GBirds")
	console.log("Deploying GBirds.")

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

	let gSpeciesAddress = "0x1897D69cc0088D89C1e94889fBD2eFFfCEfEd778"
	// if (network === "rinkeby") {
	// 	gSpeciesAddress = "0x0F85D1564e297d66E0040447Da1cd24981CED517"
	// }

	const deployed = await NFTToken.deploy(gSpeciesAddress)

	let dep = await deployed.deployed()

	console.log("Contract deployed to:", dep.address)

	await sleep(45000)
	await hre.run("verify:verify", {
		address: dep.address,
		constructorArguments: [gSpeciesAddress],
	})
}

main()
	.then(() => process.exit(0))
	.catch((error) => {
		console.error(error)
		process.exit(1)
	})
