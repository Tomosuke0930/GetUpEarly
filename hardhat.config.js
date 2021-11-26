require("@nomiclabs/hardhat-waffle");
require('solidity-coverage');

const ALCHEMY_API_KEY = "_kK7priKshdmOWXj4PuFwSzI9DOcw996";
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 const ROPSTEN_PRIVATE_KEY = "6a391a39defe76030cce8bc806f16198644e620a355b784d07b5672791b2cfe8";
 module.exports = {
  solidity: "0.8.0",
  networks: {
    ropsten: {
      url: `https://eth-ropsten.alchemyapi.io/v2/${ALCHEMY_API_KEY}`,
      accounts: [`0x${ROPSTEN_PRIVATE_KEY}`]
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



