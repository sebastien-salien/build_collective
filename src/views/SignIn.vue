<template>
  <div class="home-wrapper">
    <card
      v-if="!address"
      title="It looks like you're not connected."
      subtitle="Connect an account of MetaMask to use"
      :blue="true"
    >
      <collective-button :transparent="true" @click="connect">
        Connect to MetaMask
      </collective-button>
    </card>
    <card title="You're connected!" subtitle="YAY" :blue="true" v-else>
      <collective-button :transparent="true" @click="goToAccount">
        Go to account
      </collective-button>
    </card>
    <spacer :size="24" />
  </div>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'
import CollectiveButton from '@/components/CollectiveButton.vue'
import Spacer from '@/components/Spacer.vue'

export default defineComponent({
  name: 'SignIn',
  components: { Card, CollectiveButton, Spacer },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const contract = computed(() => store.state.contract)
    return { address, contract, store }
  },
  methods: {
    connect() {
      this.store.dispatch('ethereumConnect')
    },
    goToAccount() {
      this.$router.push({ name: 'Account' })
    },
  },
})
</script>

<style lang="css" scoped>
.home-wrapper {
  margin: auto 24px auto 24px;
}

.home {
  display: grid;
  align-items: center;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  grid-gap: 24px;
}

.card-body {
  padding: 12px;
  display: inline;
  font-family: inherit;
  font-size: 1.2rem;
  font-weight: inherit;
  text-align: center;
  color: inherit;
  text-decoration: none;
  font-variant: small-caps;
}
</style>
