const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("GetUp", function () {

  let token;
  let getup;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    GetUpToken = await ethers.getContractFactory("GetUpToken");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    token = await GetUpToken.deploy();

    const GetUp = await ethers.getContractFactory("GetUp");
    getup = await GetUp.connect(owner).deploy(owner.address); 
  });

  //createUserのテスト
  it("Create User check", async function () {
    [owner] = await ethers.getSigners();
    testUser = await getup.createUser("Tomosuke");
    await testUser.wait();
    expect(testUser.name, 'error').to.equal(undefined);
  });
});