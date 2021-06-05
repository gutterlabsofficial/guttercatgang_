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

	it("simple test...", async function () {
		expect(await nft.name()).to.equal("GutterCats")
	})

	it("simple minting test", async function () {
		expect(await nft.balanceOf(acc1.address)).to.equal(0)
		await nft.mint(acc1.address)
		expect(await nft.balanceOf(acc1.address)).to.equal(1)
	})

	it("complex minting test", async function () {
		expect(await nft.balanceOf(acc1.address)).to.equal(0)
		await nft.mint(acc1.address)
		expect(await nft.balanceOf(acc1.address)).to.equal(1)
		await nft.mint(acc1.address)
		expect(await nft.balanceOf(acc1.address)).to.equal(2)
		await nft.mint(acc2.address)
		expect(await nft.balanceOf(acc2.address)).to.equal(1)
	})

	it("uri test", async function () {
		await nft.mint(acc1.address)
		await nft.mint(acc1.address)
		await nft.mint(acc1.address)
		expect(await nft.tokenURI(2)).to.equal("https://nft..../2")
	})

	it("change uri test", async function () {
		await nft.mint(acc1.address)
		await nft.mint(acc1.address)
		await nft.mint(acc1.address)
		await nft.changeBaseURI("https://nft2.../")
		expect(await nft.tokenURI(2)).to.equal("https://nft2.../2")
	})

	it("transfer ownership test", async function () {
		expect(await nft.balanceOf(acc2.address)).to.equal(0)
		await nft.mint(acc1.address)
		expect(await nft.balanceOf(acc1.address)).to.equal(1)
		await nft.connect(acc1).transferFrom(acc1.address, acc2.address, 0)
		expect(await nft.balanceOf(acc2.address)).to.equal(1)
	})
})
