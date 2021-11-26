const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("GetUp", function () {
  it("Hello World, I'm Tomosuke", async function () {

    let owner;
    let addr1;
    let addr2;
    let addrs;
    let getup;

    beforeEach(async function () {
      const GetUp = await ethers.getContractFactory("GetUp");
      [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
      getup = await GetUp.deploy();
      await getup.deployed();
    });

    it("ERC20Token check", async function () {
      expect(await getup.name()).to.equal("GetUpToken");
      expect(await getup.symbol()).to.equal("GUT");
    });

    

    it("Create User check", async function () {
      const User1 = await getup.createUser(100);
      await User1.wait();
      try {
        await getup.createUser(addr1);
      } catch(error) {
        console.log(error.message);
      }
    });
  });
});