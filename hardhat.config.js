require("@nomiclabs/hardhat-waffle")
require("dotenv").config()
require("hardhat-gas-reporter")
require("@nomiclabs/hardhat-web3")
require("@nomiclabs/hardhat-etherscan")

module.exports = {
	solidity: {
		version: "0.8.7",
		settings: {
			optimizer: {
				enabled: true,
				runs: 200,
			},
		},
	},
	networks: {
		hardhat: {
			chainId: 127001,
			accounts: {
				mnemonic: "test test test test test test test test test test test junk",
			},
			blockGasLimit: 199022552,
			gas: 1500000,
			gasPrice: 100,
			allowUnlimitedContractSize: false,
			throwOnTransactionFailures: false,
			throwOnCallFailures: true,
		},
		ganache: {
			url: "http://127.0.0.1:7545",
			blockGasLimit: 10000000,
		},
		mainnet: {
			url: process.env.MAINNET_RPC,
			gas: 4000000,
			gasPrice: 67000000000, //67 gwei
			timeout: 15000,
			accounts: [process.env.PRIVATE_KEY_MAINNET],
		},
		rinkeby: {
			url: process.env.RINKEBY_RPC,
			network_id: 4,
			gas: 6000000,
			gasPrice: 1000000000, //1 gwei
			timeout: 15000,
			accounts: [process.env.PRIVATE_KEY_RINKEBY],
		},
		bsc_test: {
			url: process.env.BSC_RPC_TEST,
			network_id: 97,
			accounts: [process.env.PRIVATE_KEY_BSC],
		},
		bsc: {
			url: process.env.BSC_RPC,
			network_id: 56,
			accounts: [process.env.PRIVATE_KEY_BSC],
		},
		polygon: {
			url: process.env.MATIC_RPC,
			network_id: 4,
			gas: 1500000,
			gasPrice: 13000000000, //13 gwei
			timeout: 25000,
			accounts: [process.env.PRIVATE_KEY_MAINNET],
		},
		polygon_test: {
			url: process.env.MATIC_RPC_TEST,
			network_id: 4,
			gas: 1500000,
			gasPrice: 13000000000, //13 gwei
			timeout: 25000,
			accounts: [process.env.PRIVATE_KEY_MAINNET],
		},
	},

	gasReporter: {
		enabled: !!process.env.REPORT_GAS === true,
		currency: "USD",
		gasPrice: 20,
		showTimeSpent: true,
		coinmarketcap: process.env.COINMARKETCAP_API,
	},
	mocha: {
		timeout: 20000,
	},
	etherscan: {
		apiKey: process.env.ETHERSCAN_KEY, //BSC_SCAP_API_KEY or ETHERSCAN_KEY, POLYSCAN_KEY
	},
}
