// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// amountの変数作っても、実際にやりとりするERC20の量は増えたり減ったりはしてくれないので、ERC20のtransfer, transferFrom, approveを学ぶ必要がありそう。


contract GetUpEarly is Ownable,ERC20 {

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    constructor(uint256 initialSupply) ERC20("GetUpEarly", "GUE") {
        _mint(msg.sender, initialSupply);
        address masterAddress;
    }
    
    
    struct Member {
        string name;
        address addr;
        uint256 tokenAmount;
        bool join;
    }
    Member[] public members;
    
    
    //Participatntを作る関数　-Todoを作るの関数を参考に。

    function create(string memory _name, address _addr) public {
        Member memory member;
        member.name = _name;
        member.addr = msg.sender;
        members.push(Member(_name, _addr, 1000, false));
    }

    //参加者の参加・不参加を決める関数

    function toggleJoined(address _addr) public onlyOwner {
        Member storage member = members[_addr];
        member.join = !member.join;
    }

    //名前を入れてもらえたら出席かどうかわかる
    function check(uint _index) public view returns (address addr,uint balance, bool join) {
        Member storage member = members[_index];
        return (member.addr, member.balance, member.join);
    }

    //joinがTrueなmemberのbalanceからあるアドレスに対して送金する

 
    function transferFrom(address masterAddress, address _addr, uint256 tokenAmount) public override returns (bool) onlyOwner {
            for (uint i = 0; i < members.length; i++) {
                if ( members.join == true) {
                    _addr = msg.sender;
                    require(tokenAmount <= balances[masterAddress]);
                    require(tokenAmount <= allowed[owner][msg.sender]);
                    balances[masterAddress] = balances[masterAddress].sub(tokenAmount);
                    allowed[masterAddress][msg.sender] = allowed[masterAddress][msg.sender].sub(tokenAmount);
                    balances[_addr] = balances[_addr].add(tokenAmount);
                    emit Transfer(masterAddress, _addr, tokenAmount);
                    return true;
            }
        }
    }


