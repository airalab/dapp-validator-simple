<template>
  <div>
    <h1>Validator</h1>
    <div>
      Lighthouse:
      <a
        :href="`https://etherscan.io/address/${lighthouse.address}`"
        target="blank"
      >{{ lighthouse.name }}</a>
    </div>

    <h3>Results</h3>
    <div v-if="results.length>0">
      <div class="block" v-for="(item, i) in results" :key="i">
        <b>result:</b>
        {{ item.result }}
        <br>
        <b>liability:</b>
        {{ item.liability }}
        <br>
        <button
          v-if="item.status!='finish'"
          :disabled="item.status=='confirm'"
          @click="confirm(item.liability)"
        >confirm</button>
        <span v-if="item.status=='finish'">confirmed</span>
      </div>
    </div>
  </div>
</template>

<script>
import { Liability } from "robonomics-js";
import * as config from "../config";

export default {
  data() {
    return {
      lighthouse: {
        name: "",
        address: ""
      },
      results: []
    };
  },
  mounted() {
    this.lighthouse.name = this.$robonomics.lighthouse.name;
    this.lighthouse.address = this.$robonomics.lighthouse.address;
    this.$robonomics.onResult(msg => {
      const item = this.results.find(item => item.liability === msg.liability);
      if (!item) {
        const liability = new Liability(
          this.$robonomics.web3,
          msg.liability,
          "0x0000000000000000000000000000000000000000"
        );
        liability.getInfo().then(info => {
          if (
            info.validator ===
            this.$robonomics.web3.toChecksumAddress(config.VALIDATOR)
          ) {
            this.results = [
              {
                ...msg,
                status: "new"
              },
              ...this.results
            ];
          }
        });
      }
    });
  },
  methods: {
    confirm(address) {
      const item = this.results.find(item => item.liability === address);
      this.$robonomics
        .sendResult({
          liability: address,
          success: true,
          result: item.result
        })
        .then(() => {
          item.status = "confirm";
          const liability = new Liability(
            this.$robonomics.web3,
            address,
            "0x0000000000000000000000000000000000000000"
          );
          liability.onResult().then(() => {
            item.status = "finish";
          });
        });
    }
  }
};
</script>

<style>
.block {
  border: 1px solid #eee;
  padding: 10px;
  margin: 10px 0;
}
</style>
