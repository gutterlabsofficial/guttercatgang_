<template>
  <v-container>
    <form class="search-form" @submit.prevent="searchForToken">
      <div class="search-form__row">
        <v-btn
          style="max-height: 48px"
          color="#450302"
          x-large
          class="ma-5"
          input
          @click="adoptOne()"
        >
          ADOPT ONE
        </v-btn>

        <v-btn
          style="max-height: 48px"
          color="#450302"
          x-large
          class="ma-5"
          input
          @click="dialogAdoptMany = true"
        >
          ADOPT MANY
        </v-btn>
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
          </v-container>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="blue darken-1" text @click="dialogAdoptMany = false">
            Close
          </v-btn>
          <v-btn
            color="blue darken-1"
            text
            @click="
              dialogAdoptMany = false
              if (howManyCats > 10) {
                errorText = 'maximum 10 cats at once per adoption'
                dialogError = true
              } else {
                dialogConfirmGasCost = true
              }
            "
          >
            ADOPT
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="dialogConfirmGasCost" max-width="600px">
      <v-card>
        <v-card-text>
          Please make sure you set the gas limit high enough otherwise the
          transaction might fail
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>

          <v-btn
            text
            color="darken-1"
            @click="
              dialogAdoptMany = false
              dialogConfirmGasCost = false
              adoptMultiple()
            "
          >
            I CONFIRM
          </v-btn>

          <v-btn
            color="blue darken-1"
            text
            @click="
              dialogAdoptMany = false
              dialogConfirmGasCost = false
            "
          >
            CANCEL
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="dialogConfirmGasCost" max-width="600px">
      <v-card>
        <v-card-text>
          Please make sure you set the gas limit high enough otherwise the
          transaction might fail
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>

          <v-btn text color="darken-1" @click="adoptMultiple()">
            I CONFIRM
          </v-btn>

          <v-btn
            color="blue darken-1"
            text
            @click="
              dialogAdoptMany = false
              dialogConfirmGasCost = false
            "
          >
            CANCEL
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="dialogError" persistent max-width="600px">
      <v-card>
        <v-card-text>
          {{ errorText }}
        </v-card-text>
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
  </v-container>
</template>

<script>
export default {
  auth: false,
  data() {
    return {
      errorText: '',
      dialogAdoptMany: false,
      dialogConfirmGasCost: false,
      dialogError: false,
      tokenID: '',
      howManyCats: 2,
    }
  },
  mounted() {},
  methods: {
    adoptOne() {
      console.log('adopting one cat')
    },
    adoptMultiple() {
      if (this.howManyCats > 10) {
        this.errorText = 'maximum 10 cats at once per adoption'
        this.dialogError = true
        return
      }
      console.log('adopting multiple cats')
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
</style>
