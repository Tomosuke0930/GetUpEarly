// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Members{
    
    address public masterAddress; 

     struct Member {
        string name;
        address addr;
        uint balance;
        bool join;
    }

    Member[] public members;


    //Participatntを作る関数　-Todoを作るの関数を参考に。
    
    function create(string memory _name, address _addr) public {
        members.push(Member(_name, _addr, 1000, false));

        members.push(Member({name: _name, addr: _addr, balance: 1000, join: false}));

        Member memory member;
        member.name = _name;
        member.addr = _addr;

        members.push(member);
    }
    
    //参加者の参加・不参加を決める関数 
  
    function toggleJoined(string memory _name) public {
        Member storage member = members[_name];
        member.join = !member.join;
    }
    

    //名前を入れてもらえたら出席かどうかわかる

    function check(string memory _name) public view returns (address addr,uint balance, bool join) {
        Member storage member = members [_name];
        return (member.name, member.join, member,addr, member,balance);
    }


    //joinがTrueなmemberのbalanceからあるアドレスに対して送金する
    
    function collectTokenFromJoin(address masterAddress) public{
        for (uint i = 0; i < members.length; i++) {
            if ( members.join == true) {
                require(amount <= balances[sender], "Insufficient balance.");
                member.balance -= amount;
                masterAddress += amount;
        }
    }




    // function lock() public {
    //     //決められた日にちまで集めたコインをロックしておく。
    // }

}