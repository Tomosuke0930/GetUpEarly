const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("GetUp", function () {

  let token;
  let getup;
  let owner;
  let addr1;
  let addr2;
  let addrs;
  let defaultAmount = "0x" + (10000 * 10 ** 18).toString(16);

  beforeEach(async function () {
    GetUpToken = await ethers.getContractFactory("GetUpToken");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    token = await GetUpToken.deploy();
    expect(token.deployed(), "contract was not deployed");

    const GetUp = await ethers.getContractFactory("GetUp");
    getup = await GetUp.connect(owner).deploy(owner.address); 
    expect(getup.deployed(), "contract was not deployed");
  });

  // GetUpコントラクトに送金テスト
  it("Should send coin correctly", async function(){
    await token.transfer(owner.address, defaultAmount);
    const balance = (await token.balanceOf(owner.address)).toString();
    expect(balance > 0, "No balance on contract");
  });

  //createUserのテスト
  it("Create User check", async function () {
    // expect(getup.balanceOf(addr1.address).toString == 0);
    let testUser = await getup.connect(addr1).createUser("Tomosuke");
    await testUser.wait();
    expect(getup.balanceOf(addr1.address) > 0);
    console.log(getup.balanceOf(addr1.address));
  });
  // https://ethereum.stackexchange.com/questions/94351/revert-reason-for-arithmetic-overflows-in-solidity-v0-8
  // https://medium.com/linum-labs/error-vm-exception-while-processing-transaction-revert-8cd856633793
});

