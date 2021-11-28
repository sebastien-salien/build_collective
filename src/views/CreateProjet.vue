<template lang="html">
  <form @submit.prevent="createProjet">
    <card
      title="Create a projet"
    >
      <div v-if="entrepriseAccount">
        <span class="input-username"
          >Who is the owner ?</span
        >
        <div class="input-username">
          <input
            type="radio"
            id="user"
            v-bind:value="true"
            v-model="isUser"
          />
          <label for="user">You</label>
        </div>
        <div class="input-username">
          <input
            type="radio"
            id="enterprise"
            v-bind:value="false"
            v-model="isUser"
          />
          <label for="enterprise"
            >Your entreprise</label
          >
        </div>
      </div>
      <input
        type="text"
        class="input-username"
        v-model="projetName"
        placeholder="Projet name"
      />
      <span class="input-username">Select contributor(s)</span>
      <div
        v-for="user in users"
        v-bind:key="user.address"
        class="input-username"
      >
        <input
          type="checkbox"
          :id="user.address"
          :value="user.address"
          v-model="projetContributors"
        />
        <span>{{ user.account.username }}</span>
      </div>
      <input
        type="number"
        class="input-username"
        v-model="projetBalance"
        placeholder="Balance of tokens"
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
  name: 'CreateProjet',
  components: { Card },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const contract = computed(() => store.state.contract)
    return { address, contract }
  },
  data() {
    const account = null
    const users: any[] = []
    const entrepriseAccount = null
    const projet = null
    const isUser = 'true'
    const projetName = ''
    const projetBalance = ''
    const projetContributors: never[] = []
    return { account, entrepriseAccount, projet, users, isUser, projetName, projetBalance, projetContributors }
  },
  methods: {
    async updateAccount() {
      const { address, contract } = this
      this.account = await contract.methods.user(address).call()
    },
    async createProjet() {
      const { contract, projetName, isUser, projetBalance, projetContributors } = this
      const name = projetName.trim().replace(/ /g, '_')
      await contract.methods.projet(name, isUser, projetContributors, projetBalance).send()
      await this.$router.push({ name: 'Account' })
    },
  },
  async mounted() {
    const { address, contract } = this
    const account = await contract.methods.user(address).call()
    if (account.registered) this.account = account
    const entrepriseAccount = await contract.methods.getEntreprise(address).call()
    if (entrepriseAccount.name) this.entrepriseAccount = entrepriseAccount
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
