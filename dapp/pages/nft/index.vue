<template>
  <v-layout align-center justify-center>
    <v-flex v-if="nft" xs12 sm8 md6 ma-5 class="search-form__wrap" style="">
      <form class="search-form" @submit.prevent="loadNewURI()">
        <div class="search-form__row">
          <v-text-field
            v-model="tokenID"
            class="pt-5 redtext ma-1 form-input"
            style="max-width: 900px"
            placeholder="*Search a number between 0 - 9999"
            solo
          ></v-text-field>
          <v-btn
            style="max-height: 48px"
            color="#450302"
            x-large
            class="mb-2"
            @click="loadNewURI()"
          >
            GO
          </v-btn>
        </div>
      </form>

      <v-card elevation="0" class="model-block">
        <v-img
          v-if="!nft.animation_url"
          :src="nft.image"
          max-height="600"
          contain
        >
        </v-img>
        <model-viewer
          v-if="nft.animation_url"
          data-js-focus-visible
          class="model-viewer"
          style=""
          :src="nft.animation_url"
          :alt="nft.description"
          auto-rotate
          camera-controls
          preload
        ></model-viewer>

        <v-flex xs12 sm8 md6 class="heading-wrap" style="max-width: 900px">
          <v-row align="center" style="margin-top: 60px">
            <span class="title">{{ nft.name }}</span>
            <v-spacer />
            <section v-if="!isOwned">
              <v-spacer></v-spacer>
              <v-icon v-if="itemPriceETH" color="red" right
                >mdi-ethereum</v-icon
              >
              <span v-if="itemPriceETH" class="body-1">{{ itemPriceETH }}</span>

              <v-btn
                v-if="itemPriceETH"
                width="150px"
                elevation="0"
                class="ml-5 redtext"
                @click="buyNow()"
                >buy</v-btn
              >

              <v-btn
                v-if="!itemPriceETH"
                width="150px"
                elevation="0"
                class="ml-5 redtext"
                @click="buyNow()"
                >buy</v-btn
              >
            </section>

            <section v-if="isOwned">
              <v-row no-gutters>
                <v-col cols="6">
                  <span
                    style="padding: 6px; border: 1px solid grey"
                    class="title orange--text"
                    >SOLD</span
                  >
                </v-col>
                <v-col cols="6">
                  <v-btn class="mb-2" text @click="viewOnOpenSea()"
                    >view on opensea
                  </v-btn>
                </v-col>
              </v-row>
            </section>
          </v-row>
        </v-flex>

        <v-card-text>
          <v-list color="transparent">
            <v-list-item v-for="(item, i) in nft.attributes" :key="i">
              <v-list-item-content>
                <v-list-item-title v-text="item.trait_type"></v-list-item-title>
                <v-list-item-subtitle
                  v-text="item.value"
                ></v-list-item-subtitle>
              </v-list-item-content>
            </v-list-item>
          </v-list>
        </v-card-text>

        <v-card-text>
          <p class="redtext">Cat ID: {{ id }}</p>
          <p v-if="contractAddress" class="redtext">
            Contract: {{ contractAddress }}
          </p>
          <p class="redtext">Blockchain: Ethereum</p>
          <p class="redtext">
            The year is 2050. Humans are an interplanetary species and have all
            but abandoned the post-apocalyptic shatters of society on earth.
            Cats have taken over. One crime-ridden, nondescript inner city is
            inhabited by a group of cats collectively known as the Gutter Cats.
          </p>
        </v-card-text>
      </v-card>
    </v-flex>
  </v-layout>
</template>
<script>
import '@google/model-viewer/dist/model-viewer'
import { ethers } from 'ethers'
import { CONTRACT_ADDR, RPC_PROVIDER, NETWORK_ID } from '../../constants'
import { ERC1155_ABI } from '../../erc1155_abi'
const EthersUtils = require('ethers').utils

export default {
  auth: false,
  data() {
    return {
      id: null,
      tokenID: null,
      contract: null,
      contractAddress: null,
      itemPriceETH: null,
      itemPriceWei: null,
      nft: null,
      isOwned: false,
      ethers: null,
      signer: null,
      provider: null,
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
  },
  methods: {
    initialize() {
      this.isOwned = false
      this.loadNFT(this.id)
      this.loadContract()
    },
    loadNFT(id) {
      this.$axios
        .$get('https://hyp.s3.eu-west-2.amazonaws.com/json/' + id)
        .then((response) => {
          this.nft = response
        })
    },
    async loadContract() {
      this.contract = new ethers.Contract(
        CONTRACT_ADDR,
        ERC1155_ABI,
        this.ethers
      )

      this.itemPriceWei = await this.contract.getItemPrice()
      this.itemPriceETH = EthersUtils.formatEther(this.itemPriceWei)

      const tokenSupply = await this.contract.tokenSupply(this.id)
      if (Number(tokenSupply) !== 0) {
        console.warn('this token is already owned')
        this.isOwned = true
      }
    },
    async buyNow() {
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
      const overrides = { value: this.itemPriceWei, gasLimit: 120000 }

      try {
        const tx = await this.contract.buyOne(this.id, overrides)
        if (tx.hash) {
          this.$toast.info('Transaction submitted successfully')
        }
      } catch (err) {
        if (err.message.includes('denied')) {
          this.$toast.info('you canceled the transaction')
        } else {
          this.$toast.error(err.message)
        }
      }
    },
    searchForToken() {
      if (this.tokenID == null) {
        return
      }
      this.nft.animation_url = null
      this.id = this.tokenID
      this.init(this.tokenID)
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
  },
}
</script>

<style lang="scss" scoped>
#styled-input {
  height: 48px;
}
.styled-input label[for] {
  height: 48px;
}
// .v-list-item__subtitle {
//   font-size: 0.8em !important;
// }
</style>
