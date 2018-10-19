const secrets = require('./secrets.js');
var HDWalletProvider = require("truffle-hdwallet-provider");
var NonceTrackerSubprovider = require("web3-provider-engine/subproviders/nonce-tracker")

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  },
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*", // Match any network id
      gasPrice: 5000000000,
      gas: 3000000
    },
    ropsten: {
      provider: function() {
        return createProvider(secrets.mnemonic, "https://ropsten.infura.io/" + secrets.infuraKey)
      },
      network_id: 3,
      gasPrice: 5000000000,
      gas: 3000000
    },
    rinkeby: {
      provider: function() {
        return createProvider(secrets.mnemonic, "https://rinkeby.infura.io/" + secrets.infuraKey)
      },
      network_id: 4,
      gasPrice: 5000000000,
      gas: 3000000
    },
    kovan: {
      provider: function() {
        return createProvider(secrets.mnemonic, "https://kovan.infura.io/" + secrets.infuraKey)
      },
      network_id: 42,
      gasPrice: 5000000000,
      gas: 3000000
    },
    mainnet: {
      provider: function() {
        return createProvider(secrets.mnemonic, "https://mainnet.infura.io/" + secrets.infuraKey)
      },
      network_id: 1,
      gasPrice: 5000000000,
      gas: 3000000
    }
  }
}

function createProvider(mnemonic, infuraUrl) {
  var wallet = new HDWalletProvider(mnemonic, infuraUrl)
  var nonceTracker = new NonceTrackerSubprovider()
  wallet.engine._providers.unshift(nonceTracker)
  nonceTracker.setEngine(wallet.engine)
  return wallet
}
