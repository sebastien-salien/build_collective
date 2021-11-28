<template lang="html">
  <div class="home-wrapper" v-if="account">
    <div class="home">
      <div>
        <card
          :title="`${account.username}`"
          :subtitle="`Your balance : \n${balance} \tETH \t| \t${account.balance} \tTokens`"
          :gradient="true"
        >
          <div class="explanations">
            Account information : 
            <ul>
              <li>Name : {{ account.username }}</li>
              <li>Address : {{ address }}</li>
              <li>ETH : {{ balance }}</li>
              <li>Account balance : {{ account.balance }} Tokens</li>
            </ul>
            To add 200 Tokens to your account click <button class="button-link" @click="addTokens">HERE</button>
          </div>
        </card>
      </div>
      <div>
        <card
          :title="`Your entreprise : ${entrepriseAccount.name}`"
          :subtitle="`Entreprise balance : ${entrepriseAccount.balance} Tokens`"
          v-if="entrepriseAccount"
        >
          <div class="explanations" v-if="entrepriseAccount">
            Entreprise information : 
            <ul>
              <li>Entreprise name : {{ entrepriseAccount.name }}</li>
              <li>Owner name : {{ entrepriseOwner.username }}</li>
              <li>Owner address : {{ entrepriseAccount.owner }}</li>
              <li>Entreprise balance : {{ entrepriseAccount.balance }}</li>
            </ul>
            <ul v-if="entrepriseMembers.length>0">
              List of members :
              <li
                v-for="member in entrepriseMembers"
                v-bind:key="member.address"
              >  
                Name : {{ member.account.username }} &nbsp;&nbsp; Address : {{ member.address }}
              </li>
            </ul>
          </div>
        </card>
      </div>
    </div>
    <spacer :size="24" />
    <card
      title="Your projet list"
      :subtitle="`Number of projets: ${projets.length}`"
      v-if="projets.length>0"
    >
      <div class="explanations" v-for="projet in projets" v-bind:key="projet.name">
        Projet information : 
        <ul>
          <li>Projet name : {{ projet.name }}</li>
          <li>Owner name : {{ projet.isUser ? projet.owner.username : projet.owner.name }}</li>
          <li>Projet balance : {{ projet.balance }}</li>
        </ul>
        <ul v-if="projet.contributors.length>0">
          List of contributors :
          <li
            v-for="contributor in projet.contributors"
            v-bind:key="contributor.address"
          >
            Name : {{ contributor.account.username }} &nbsp;&nbsp; Address : {{ contributor.address }}
          </li>
        </ul>
        ******************************
      </div>
    </card>
    <spacer :size="24" />
    <div class="home">
      <card
        title="Create your entreprise"
        v-if="!entrepriseAccount"
      >
        <router-link class="card-body" to="/entreprise">
          Create an entreprise
        </router-link>
      </card>
      <card
        title="Create your projet"
      >
        <router-link class="card-body" to="/projet">
          Create a projet
        </router-link>
      </card>
    </div>
  </div>
  <div class="signUp" v-else>
    <form @submit.prevent="signUp">
      <card
        title="Create your account"
      >
        <input
          type="text"
          class="input-username"
          v-model="username"
          placeholder="User name"
        />
        <input
          type="number"
          class="input-username"
          v-model="userBalance"
          placeholder="Enter how much balance you want to put"
        />
        <button type="submit" class="input-username">Create</button>
      </card>
    </form>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue'
import { useStore } from 'vuex'
import Card from '@/components/Card.vue'
import Spacer from '@/components/Spacer.vue'

export default defineComponent({
  name: 'Account',
  components: { Spacer, Card },
  setup() {
    const store = useStore()
    const address = computed(() => store.state.account.address)
    const balance = computed(() => store.state.account.balance)
    const contract = computed(() => store.state.contract)
    return { address, contract, balance }
  },
  data() {
    const account = null
    const username = ''
    const userBalance = ''
    const entrepriseOwner: any = { username: '', balance: 0 }
    const entrepriseAccount = null
    const entrepriseMembers: any[] = []
    const projets: any[] = []
    return { account, username, userBalance, entrepriseOwner, entrepriseAccount, entrepriseMembers, projets }
  },
  methods: {
    async updateAccount() {
      const { address, contract } = this
      this.account = await contract.methods.user(address).call()
    },
    async updateEnterpriseAccount() {
      const { address, contract } = this
      this.entrepriseAccount = await contract.methods.getEntreprise(address).call()
    },
    getMembersAccount(membersAddress: string) {
      return this.contract.methods.user(membersAddress).call()
    },
    async signUp() {
      const { contract, username, userBalance } = this
      const name = username.trim().replace(/ /g, '_')
      await contract.methods.signUp(name, userBalance).send()
      await this.updateAccount()
      this.username = ''
    },
    async addTokens() {
      const { contract } = this
      await contract.methods.addBalance(200).send()
      await this.updateAccount()
    },
  },
  async mounted() {
    const { address, contract } = this
    const contractBalance = await contract.methods.getBalance().call()
    const account = await contract.methods.user(address).call()
    if (account.registered) this.account = account
    const entrepriseAccount = await contract.methods.getEntreprise(address).call()
    if (entrepriseAccount.name) {
      this.entrepriseAccount = entrepriseAccount
      this.entrepriseOwner = await contract.methods.user(entrepriseAccount.owner).call()
      const membersAddressesList = entrepriseAccount.membersAddresses
      for (const memberAddress of membersAddressesList) {
        const member = await contract.methods.user(memberAddress).call()
        this.entrepriseMembers.push({
          address: memberAddress,
          account: {
            username: member.username,
            balance: member.balance
          },
        })
      }
    }
    const projetsList = await contract.methods.getProjet(address).call()
    if (projetsList.length > 0) {
      for (const projet of projetsList) {
        let name = projet.name
        let owner = null
        if (projet.isUser) {
          owner = await contract.methods.user(projet.owner).call()
        } else {
          owner = await contract.methods.getEntreprise(projet.owner).call()
        }
        let balance = projet.balance
        const contributorsAddressesList = projet.contributorsAddresses
        let contributors = []
        for (const contributorAddress of contributorsAddressesList) {
          const contributor = await contract.methods.user(contributorAddress).call()
          contributors.push({
            address: contributorAddress,
            account: {
              username: contributor.username,
              balance: contributor.balance,
              registered: contributor.registered,
            },
          })
        }
        this.projets.push({
          id: projet.id,
          name: name,
          owner: {
            name: owner.name,
            username: owner.username,
            balance: owner.balance,
          },
          ownerAddress: projet.owner,
          isUser: projet.isUser,
          balance: balance,
          contributors: contributors,
        })
      }
    }
  },
})
</script>

<style lang="css" scoped>
.home-wrapper {
  margin: auto 24px auto 24px;
}
.home {
  display: grid;
  grid-template-columns: 50% 50%;
  grid-gap: 24px;
}
.card-body {
  padding: 12px;
  display: block;
  font-family: inherit;
  font-size: 1.2rem;
  font-weight: inherit;
  text-align: center;
  color: inherit;
  text-decoration: none;
  font-variant: small-caps;
}
.signUp {
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
  color: yellow;
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
