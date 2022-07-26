/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * trufflesuite.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like @truffle/hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura accounts
 * are available for free at: infura.io/register.
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */


const HDWalletProvider = require('@truffle/hdwallet-provider');
const Web3 = require('web3');
const TestnetPrivateKey = "b375f6ba3e3ec45f985fd619b8684527e95522fdf5d574d7373570ca0999414b";
const MainnetPrivateKey = "";

module.exports = {
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */

  networks: {
    // Useful for testing. The `development` name is special - truffle uses it by default
    // if it's defined here and no other network is specified at the command line.
    // You should run a client (like ganache-cli, geth or parity) in a separate terminal
    // tab if you use this network and you must also set the `host`, `port` and `network_id`
    // options below to some value.
    //
    development: {
      provider: () => new Web3.providers.HttpProvider("http://127.0.0.1:7546"),
      // host: "127.0.0.1",     // Localhost (default: none)
      // port: 7546,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
      gas: 8500000,
    },
    test: {
      provider: () => {
        return new HDWalletProvider(TestnetPrivateKey, 'https://api.s0.b.hmny.io');
      },
      network_id: 1666700000,      
    },
    live: {
      provider: () => {
        if (!MainnetPrivateKey) {
          throw Error("MainnetPrivateKey is not set");
        }

        return new HDWalletProvider(MainnetPrivateKey, 'https://api.s0.t.hmny.io');
      },
      network_id: 1666600000,      
    },
    // Another network with more advanced options...
    // advanced: {
    // port: 8777,             // Custom port
    // network_id: 1342,       // Custom network
    // gas: 8500000,           // Gas sent with each transaction (default: ~6700000)
    // gasPrice: 20000000000,  // 20 gwei (in wei) (default: 100 gwei)
    // from: <address>,        // Account to send txs from (default: accounts[0])
    // websocket: true        // Enable EventEmitter interface for web3 (default: false)
    // },
    // Useful for deploying to a public network.
    // NB: It's important to wrap the provider as a function.

  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
    // reporter: "mocha-junit-reporter",
    // reporterOptions: {
    //   mochaFile: "./test-results/test-results.xml"
    // }
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.2",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      // settings: {          // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
         enabled: false,
         runs: 200
       },
      //  evmVersion: "byzantium"
      // }
    }
  },
  contracts_directory: './contracts/',
  // Truffle DB is currently disabled by default; to enable it, change enabled: false to enabled: true
  //
  // Note: if you migrated your contracts prior to enabling this field in your Truffle project and want
  // those previously migrated contracts available in the .db directory, you will need to run the following:
  // $ truffle migrate --reset --compile-all

  db: {
    enabled: false
  },

  plugins: [
    'truffle-contract-size'
  ]
};

