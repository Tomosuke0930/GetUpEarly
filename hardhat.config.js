require("@nomiclabs/hardhat-waffle");
require('solidity-coverage');
const ethers = require('ethers')
let wallet = new ethers.Wallet.createRandom()
let privateKey = wallet.privateKey

const ALCHEMY_API_KEY = "mGZ22nK18MOJbzlUYZT-rs4K7wcCaabP";
/**
 * @type import('hardhat/config').HardhatUserConfig
 */

 //const ROPSTEN_PRIVATE_KEY = "";
 module.exports = {
  solidity: "0.8.4",
  networks: {
    ropsten: {
      url: `https://eth-ropsten.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [privateKey]
    }
  }
};


// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});



