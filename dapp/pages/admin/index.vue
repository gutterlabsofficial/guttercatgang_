<template>
  <v-layout align-center justify-center>
    <v-flex v-if="isOwner" xs12 sm8 md6 ma-5 style="max-width: 600px">
      <p class="display-1">DApp Admin Dashboard</p>
      <v-card elevation="5" class="mt-5">
        <v-card-text>
          <p class="body-1">
            Total Balance Available: {{ currentBalance }} wei ({{
              currentBalanceETH
            }}
            ETH)
          </p>
          <p>Withdraw ETH from sold NFTs</p>
          <v-container>
            <v-row>
              <v-col cols="12" md="6">
                <v-btn color="primary" large @click="withdraw()">
                  Withdraw
                </v-btn>
              </v-col>
            </v-row>
          </v-container>
        </v-card-text>
      </v-card>

      <v-card elevation="5" class="mt-5">
        <v-card-text>
          <p class="body-1">
            Price per NFT: {{ itemPriceWei }} wei ({{ itemPriceETH }}
            ETH)
          </p>
          <p>Set New Item Price</p>
          <v-container>
            <v-row>
              <v-col cols="12" md="6">
                <v-text-field
                  v-model="newItemPrice"
                  label="New Item Price (wei)"
                  required
                ></v-text-field>
              </v-col>
              <v-col cols="12" md="6">
                <v-btn color="primary" large @click="setItemPrice()">
                  Set New Price
                </v-btn>
              </v-col>
            </v-row>
          </v-container>
        </v-card-text>
      </v-card>
    </v-flex>
  </v-layout>
</template>
<script>
import { ethers } from 'ethers'
import { CONTRACT_ADDR } from '../../constants'
import { ERC1155_ABI } from '../../erc1155_abi'
const EthersUtils = require('ethers').utils
export default {
  auth: false,
  data() {
    return {
      newItemPrice: 0,
      contract: null,
      itemPriceETH: null,
      itemPriceWei: null,
      currentBalance: 0,
      currentBalanceETH: 0,
      ethers: null,
      isOwner: false,
      signer: null,
    }
  },
  mounted() {
    if (window.ethereum) {
      this.ethers = new ethers.providers.Web3Provider(window.ethereum)
      this.loadContract()

      this.ethers.on('error', (tx) => {
        this.$toast.error('in ' + tx.hash + ' an error occurred')
      })
    } else {
      this.$toast.error('metamask NOT detected!')
    }
  },
  methods: {
    async loadContract() {
      this.signer = this.ethers.getSigner()
      this.contract = new ethers.Contract(
        CONTRACT_ADDR,
        ERC1155_ABI,
        this.signer
      )

      this.isOwner = await this.contract.isOwner()
      if (!this.isOwner) {
        this.$router.push('/other/only_owner_allowed')
      }

      this.itemPriceWei = await this.contract.getItemPrice()
      this.itemPriceETH = EthersUtils.formatEther(this.itemPriceWei)

      this.currentBalance = await this.contract.getCurrentBalance()
      this.currentBalanceETH = EthersUtils.formatEther(this.currentBalance)
    },
    async setItemPrice() {
      const overrides = { gasLimit: 60000 }

      try {
        const tx = await this.contract.setItemPrice(
          this.newItemPrice,
          overrides
        )
        if (tx.hash) {
          this.$toast.info('Transaction submitted successfully')
        }
        if (tx.hash) {
          this.$toast.info('Transaction submitted successfully')
        }
        this.ethers.once(tx.hash, (transaction) => {
          if (transaction.status === 1) {
            this.$toast.success('Transaction executed successfully')
          } else {
            this.$toast.error('Transaction failed to execute!')
          }
        })
      } catch (err) {
        if (err.message.includes('denied')) {
          this.$toast.info('you canceled the transaction')
        } else {
          this.$toast.error(err.message)
        }
      }
    },
    async withdraw() {
      const overrides = { gasLimit: 60000 }

      try {
        const tx = await this.contract.withdraw(overrides)
        if (tx.hash) {
          this.$toast.info('Transaction submitted successfully')
        }
        this.ethers.once(tx.hash, (transaction) => {
          if (transaction.status === 1) {
            this.$toast.success('Transaction executed successfully')
          } else {
            this.$toast.error('Transaction failed to execute!')
          }
        })
      } catch (err) {
        if (err.message.includes('denied')) {
          this.$toast.info('you canceled the transaction')
        } else {
          this.$toast.error(err.message)
        }
      }
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
</style>
