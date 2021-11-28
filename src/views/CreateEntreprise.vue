<template lang="html">
  <form @submit.prevent="createEntreprise">
    <card
      title="Create an entreprise account"
    >
      <input
        type="text"
        class="input-username"
        v-model="entrepriseName"
        placeholder="Enter entreprise name"
      />
      <span class="input-username">Select member(s)</span>
      <div
        v-for="user in users"
        v-bind:key="user.address"
        class="input-username"
      >
        <input
          type="checkbox"
          :id="user.address"
          :value="user.address"
          v-model="entrepriseMembers"
        />
        <span>{{ user.account.username }}</span>
      </div>
      <input
        type="number"
        class="input-username"
        v-model="entrepriseBalance"
        placeholder="Enter your entreprise balance"
      />
      <button type="submit" class="input-username">Create</button>
    </card>
  </form>
</template>

<script lang="ts">
import { computed, defineComponent } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'

export default defineComponent({
  name: 'createEntreprise',
  components: { Card },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const contract = computed(() => store.state.contract)
    return { address, contract }
  },
  data() {
    const users: any[] = []
    const entrepriseAccount = null
    const entrepriseName = ''
    const entrepriseBalance = ''
    const entrepriseMembers: never[] = []
    return { entrepriseName, users, entrepriseAccount, entrepriseBalance, entrepriseMembers }
  },
  methods: {
    async updateEntreprise() {
      const { address, contract } = this
      this.entrepriseAccount = await contract.methods.getEntreprise(address).call()
    },
    async createEntreprise() {
      const { contract, entrepriseName, entrepriseMembers, entrepriseBalance } =
        this
      const name = entrepriseName.trim().replace(/ /g, '_')
      await contract.methods.entreprise(name, entrepriseMembers, entrepriseBalance).send()
      await this.updateEntreprise()
      await this.$router.push({ name: 'Account' })
    },
  },
  async mounted() {
    const { address, contract } = this
    this.entrepriseAccount = await contract.methods.getEntreprise(address).call()
    const userAddressesList = await contract.methods.getAllUsers().call()
    for (const userAddress of userAddressesList) {
      const account = await contract.methods.user(userAddress).call()
      this.users.push({ address: userAddress, account: account })
    }
  },
})
</script>

<style lang="css" scoped>
.home {
  padding: 24px;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  max-width: 100%;
  margin: auto;
}

.explanations {
  padding: 12px;
}

.button-link {
  display: inline;
  appearance: none;
  border: none;
  background: none;
  color: inherit;
  text-decoration: underline;
  font-family: inherit;
  font-size: inherit;
  font-weight: inherit;
  padding: 0;
  margin: 0;
  cursor: pointer;
}

.select-type,
.input-username {
  background: transparent;
  border: none;
  padding: 12px;
  outline: none;
  width: 100%;
  color: white;
  font-family: inherit;
  font-size: 1.3rem;
}
</style>
