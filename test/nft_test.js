const { expect, assert } = require("chai")
const { web3, ethers } = require("hardhat")
const { BN, time, balance, expectEvent, expectRevert } = require("@openzeppelin/test-helpers")
const ether = require("@openzeppelin/test-helpers/src/ether")

let nft
let owner, acc1, acc2

describe("NFT", function () {
	beforeEach(async function () {
		let NFTContract = await ethers.getContractFactory("GutterCats")

		nft = await NFTContract.deploy()
		await nft.deployed()

		signers = await ethers.getSigners()
		owner = signers[0]
		acc1 = signers[1]
		acc2 = signers[2]
	})

	it("simple test....", async function () {
		expect(await nft.getItemPrice()).to.equal("70000000000000000")
	})

	it("adopting a cat works", async function () {
		await expect(nft.connect(acc1).adoptCat({ value: web3.utils.toWei("0.07", "ether") })).to.emit(
			nft,
			"TransferSingle"
		)
	})

	it("adopting multiple cats works", async function () {
		await expect(
			nft.connect(acc1).adoptCats(10, { value: web3.utils.toWei("0.7", "ether") })
		).to.emit(nft, "TransferSingle")
	})

	it("it will retry if random fails", async function () {
		for (i = 0; i < 5; i++) {
			await nft.connect(acc1).adoptCats(10, { value: web3.utils.toWei("0.7", "ether") })
		}
	})

	it("owner can withdraw the ETH", async function () {
		const tracker = await balance.tracker(owner.address)
		let ownerInitialBalance = Number(await tracker.get("wei"))
		await expect(
			nft.connect(acc1).adoptCats(10, { value: web3.utils.toWei("0.7", "ether") })
		).to.emit(nft, "TransferSingle")
		await nft.withdraw()
		let ownerFinalBalance = Number(await tracker.get("wei"))
		expect(ownerFinalBalance - ownerInitialBalance).to.be.greaterThan(
			Number(web3.utils.toWei("0.699", "ether"))
		)
	})

	it("can't adopt a cat with less funds", async function () {
		await expect(
			nft.connect(acc1).adoptCat({ value: web3.utils.toWei("0.069", "ether") })
		).to.be.revertedWith("insufficient ETH")
	})
	it("can't adopt a 10 cats with less funds", async function () {
		await expect(
			nft.connect(acc1).adoptCat({ value: web3.utils.toWei("0.69", "ether") })
		).to.be.revertedWith("insufficient ETH")
	})
})
