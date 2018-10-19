# One To Two

The application is launched on [Ethereum app platform](https://ethereum.org/).


#### Development stack

- [Solidity](http://solidity.readthedocs.io/en/v0.4.24/) - contract language
- [Truffle](http://truffleframework.com/) - development framework for Ethereum
- [Ganche](http://truffleframework.com/ganache/) - local blockchain for testing

#### Build and deploy

1. Install truffle v4.0.6: *npm install -g truffle@v4.0.6*
2. Create *secrets.js* file in the project root, you can move *secrets.js.template* to *secrets.js*
3. Launch Ganache and then execute:

```shell
truffle compile
truffle migrate
```

And contracts will be loaded to local blockchain.
