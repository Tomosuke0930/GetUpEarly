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
    let testUser = await getup.connect(addr1).createUser("Tomosuke");
    await testUser.wait();

    expect(await getup.balanceOf(addr1.address)).to.equal(100);
  });

  it("Create Project check", async function () {
    let testUser = await getup.connect(addr1).createUser("Tomosuke");
    await testUser.wait();

    expect(await getup.balanceOf(addr1.address)).to.equal(100);

    let createProjectByTestUser 
    = await getup.connect(addr1).createProject(1, 1, "firstProject",20,5,7,5);
    // _startXDaysLater,_duration,_name,_joinFee,_penaltyFee,_deadlineTime,_canJoinNumbe
    await createProjectByTestUser.wait();

    // let joinProjectByTestUser = await getup.connect(addr1).joinProject(1);
    // await joinProjectByTestUser.wait();
    
  });
});

