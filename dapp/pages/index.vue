<template>
  <v-container>
    <form class="search-form" @submit.prevent="searchForToken">
      <div class="search-form__row">
        <p>Thank you for everyone that adopted a cat or more.</p>
        <!-- <v-btn
          style="max-height: 58px; min-width: 250px"
          outlined
          x-large
          class="ma-5"
          input
          @click="adoptOne()"
        >
          ADOPT ONE
        </v-btn> -->

        <!-- <v-btn
          style="max-height: 58px; min-width: 250px"
          x-large
          class="ma-5"
          input
          outlined
          @click="dialogAdoptMany = true"
        >
          ADOPT MANY
        </v-btn> -->
      </div>
      <div
        class="ma-5 pa-5 d-flex flex-column justify-space-between align-center"
      >
        <p class="ma-5" style="text-align: center">
          You can adopt a minimum of 1 and maximum of 10 Gutter Cats.
          <span v-if="itemPriceETH"
            >Each Gutter Cat cost {{ itemPriceETH }} ETH + gas
          </span>
        </p>

        <p v-if="adoptedCats">{{ adoptedCats }}/3000 Gutter Cats Adopted</p>
        <img
          class="ma-5 pa-5"
          style="max-width: 350px"
          src="/cats_gif.gif"
          alt="gutter cats gif"
        />

        <p v-if="txHash" style="text-align: center">
          You can check your transaction status
          <span style="font-weight: bold"
            ><a target="_blank" :href="`https://etherscan.io/tx/${txHash}`"
              >here</a
            ></span
          >
        </p>
        <p v-if="txHash" style="text-align: center">
          In a few minutes, your Gutter Cat will show up in Opensea
          <span style="font-weight: bold">
            <a
              target="_blank"
              href="https://opensea.io/collections/guttercatgang"
              >opensea.io/collections/guttercatgang</a
            ></span
          >
        </p>
        <p v-if="txHash" class="mt-5" style="text-align: center">
          Keep it Gutta!
        </p>
      </div>
    </form>

    <v-dialog v-model="dialogAdoptMany" max-width="400px">
      <v-card>
        <v-card-title>
          <span class="headline">ADOPTION FORM</span>
        </v-card-title>
        <v-card-text>
          <v-container>
            <v-row>
              <v-col cols="12" sm="12" md="12">
                <v-text-field
                  v-model="howManyCats"
                  label="How Many Cats ? (max 10)"
                  required
                ></v-text-field>
              </v-col>
            </v-row>

            Please increase the gas limit to have a higher likelihood of the
            transaction being successful.
          </v-container>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn text @click="dialogAdoptMany = false"> Close </v-btn>
          <v-btn
            color="blue darken-1"
            text
            @click="
              dialogAdoptMany = false
              if (howManyCats > 10) {
                errorText = 'maximum 10 cats at once per adoption'
                dialogError = true
              } else {
                adoptMultiple()
              }
            "
          >
            ADOPT
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog
      v-model="dialogError"
      class="ma-5 pa-5"
      persistent
      max-width="600px"
    >
      <v-card>
        <v-card-title>
          {{ errorText }}
        </v-card-title>
        <v-card-actions>
          <v-spacer></v-spacer>

          <v-btn
            color="blue darken-1"
            text
            @click="
              dialogError = false
              errorText = ''
            "
          >
            EXIT
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- not used -->
    <v-row v-if="showRandNFTs" dense>
      <v-col v-for="(image, index) in randNFTs" :key="index">
        <v-hover v-slot="{ hover }">
          <v-card :elevation="hover ? 3 : 1" class="ma-5" max-width="374">
            <v-img :src="image" alt="A cool looking cat" contain> </v-img>
          </v-card>
        </v-hover>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { ethers } from 'ethers'
import { CONTRACT_ADDR, RPC_PROVIDER, NETWORK_ID } from '../constants'
import { ERC1155_ABI } from '../erc1155_abi'
const EthersUtils = require('ethers').utils

export default {
  auth: false,
  data() {
    return {
      randNFTs: [],
      id: null,
      adoptedCats: null,
      tokenID: null,
      contract: null,
      contractAddress: null,
      itemPriceETH: null,
      itemPriceWei: null,
      txHash: null,
      isOwned: false,
      ethers: null,
      signer: null,
      provider: null,
      errorText: '',
      dialogAdoptMany: false,
      dialogError: false,
      howManyCats: 2,
      showRandNFTs: false,
    }
  },
  mounted() {
    this.id = this.$route.query.id
    this.contractAddress = CONTRACT_ADDR
    if (!window.ethereum) {
      this.provider = 'not_web3'
      this.ethers = new ethers.providers.JsonRpcProvider(
        RPC_PROVIDER,
        NETWORK_ID
      )
    } else {
      this.provider = 'web3'
      this.ethers = new ethers.providers.Web3Provider(window.ethereum)
    }
    this.initialize()
    //this.randomNFTs()
    //const that = this
    //setInterval(function () {
    //that.randomNFTs()
    //}, 30000)
  },
  methods: {
    initialize() {
      this.isOwned = false
      this.loadContract()
    },
    clickedNFT(index) {
      this.$router.push('/nft?id=' + index)
    },
    randomNFTs() {
      for (let i = 1; i <= 3000; ++i)
        this.randNFTs[i] =
          'https://guttercatgang.s3.us-east-2.amazonaws.com/i/' + i + '.png'
      this.randNFTs = this.shuffle(this.randNFTs)
      this.randNFTs = this.randNFTs.slice(1, 10)
      this.showRandNFTs = true
    },
    async loadContract() {
      this.contract = new ethers.Contract(
        CONTRACT_ADDR,
        ERC1155_ABI,
        this.ethers
      )

      this.itemPriceWei = await this.contract.getItemPrice()
      this.itemPriceETH = EthersUtils.formatEther(this.itemPriceWei)
      this.adoptedCats = await this.contract.adoptedCats()
    },
    async checkMetamaskConnected() {
      if (window.ethereum) {
        await window.ethereum.enable()
        this.ethers = new ethers.providers.Web3Provider(window.ethereum)

        this.signer = this.ethers.getSigner()
        this.account = await this.signer.getAddress()
        this.balance = await this.signer.getBalance()
        this.ethBalance = await ethers.utils.formatEther(this.balance)
        this.signer = this.ethers.getSigner()
        const addr = await this.signer.getAddress()
        this.walletBtnText =
          addr.substr(0, 7) + '...' + addr.substr(addr.length - 5, addr.length)

        const chainId = this.ethers._network.chainId
        this.$store.commit('setSelectedAddress', addr)
        this.$store.commit('setNetworkID', Number(chainId))

        if (chainId !== 1) {
          this.showNonMainnetWarning = true
        }
        return true
      } else {
        this.$router.push('/other/install_metamask')
        return false
      }
    },
    loadNewURI() {
      window.location.replace('/nft?id=' + this.tokenID)
    },
    viewOnOpenSea() {
      const url =
        'https://opensea.io/assets/' + this.contractAddress + '/' + this.id
      window.open(url, '_blank')
    },
    async adoptOne() {
      console.log('adopting one cat')
      this.txHash = null
      this.ethers = new ethers.providers.Web3Provider(window.ethereum)
      this.signer = this.ethers.getSigner()
      this.contract = new ethers.Contract(
        CONTRACT_ADDR,
        ERC1155_ABI,
        this.signer
      )

      const res = await this.checkMetamaskConnected()
      if (!res) {
        return
      }
      const overrides = { value: this.itemPriceWei, gasLimit: 150000 }

      try {
        const tx = await this.contract.adoptCat(overrides)
        if (tx.hash) {
          this.$toast.info('Transaction submitted successfully')
        }
        this.txHash = tx.hash
      } catch (err) {
        if (err.message.includes('denied')) {
          this.$toast.info('you canceled the transaction')
        } else {
          this.$toast.error(err.message)
        }
      }
    },
    async adoptMultiple() {
      this.txHash = null
      if (this.howManyCats > 10) {
        this.errorText = 'maximum 10 cats at once please'
        this.dialogError = true
        return
      }
      console.log('adopting multiple cats')
      this.ethers = new ethers.providers.Web3Provider(window.ethereum)
      this.signer = this.ethers.getSigner()
      this.contract = new ethers.Contract(
        CONTRACT_ADDR,
        ERC1155_ABI,
        this.signer
      )

      const res = await this.checkMetamaskConnected()
      if (!res) {
        return
      }
      const overrides = {
        value: String(Number(this.howManyCats) * Number(this.itemPriceWei)),
        gasLimit: 1490000,
      }

      try {
        const tx = await this.contract.adoptCats(this.howManyCats, overrides)
        if (tx.hash) {
          this.$toast.info(
            'Transaction submitted successfully. You should check your opensea wallet after it gets confirmed'
          )
          this.txHash = tx.hash
        }
      } catch (err) {
        if (err.message.includes('denied')) {
          this.$toast.info('you canceled the transaction')
        } else {
          this.$toast.error(err.message)
        }
      }
    },
    shuffle(array) {
      let tmp
      let current
      let top = array.length

      if (top)
        while (--top) {
          current = Math.floor(Math.random() * (top + 1))
          tmp = array[current]
          array[current] = array[top]
          array[top] = tmp
        }
      return array
    },
  },
}
</script>

<style lang="scss" scoped>
.container {
  max-width: 1500px;
}
.black-text {
  color: black i !important;
}

.theme--dark.v-input input,
.theme--dark.v-input textarea {
  color: #ea201c;
}

.v-card {
  background-color: #333 !important;
}
</style>
