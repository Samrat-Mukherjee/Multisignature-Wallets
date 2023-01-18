// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract multisigWallet {

    uint public maxVote = 3; //max vote nedded
    address [] public owners; //dont's know the need *
    proposal [] public listofProposals;  //database for all proposals
    mapping (address => bool ) public ownerList;  //Those who can vote *
    mapping (address => mapping(uint => bool)) public alreadyVoted;  //database for who already voted


    constructor() {
        owners.push(msg.sender);
        ownerList[msg.sender] = true; //pushing owner in list
    }

    receive() external payable{}  // Eth receive function

      modifier onlyOwner{
        require(ownerList[msg.sender] == true, "You are not the owner");
        _;
    }

    //security cheak for owners in list

    struct proposal {
        address sendingTo;
        uint value;
        bool alreadyExecuted;
        uint approval;
    } 

    //stucture of proposals

  

    function setProposal(address to, uint amount) public onlyOwner{
        listofProposals.push(proposal({
            sendingTo: to,
            value:amount,
            alreadyExecuted: false,
            approval: 0
        }));
    }

    //set proposals in database


  

    function voteTransaction(uint index) public onlyOwner{
        require(alreadyVoted[msg.sender][index] == false, "You have already voted");
        listofProposals[index].approval += 1;
        alreadyVoted[msg.sender][index] = true;
    }

    //voting system


    function executeProposals(uint index) public onlyOwner returns (bool){
        require(listofProposals[index].approval >= maxVote, "Proposal till not achive its goal");
        require( listofProposals[index].alreadyExecuted == false, "It's already executed");
        address payable toSend = payable(listofProposals[index].sendingTo);
        (bool tryToSend,) = toSend.call{value:listofProposals[index].value, gas:5000}("");
        require(tryToSend, "You don't have enough eth to send");
        listofProposals[index].alreadyExecuted == true;
        return tryToSend;
    }

    //vote execution


    function revokeVote(uint index) onlyOwner public {
        require(alreadyVoted[msg.sender][index] == true, "You haven't voted yet");
        listofProposals[index].approval -= 1;
        alreadyVoted[msg.sender][index] = false;
    }

    //set a way to revoke a vote


    function setVotesRequired(uint noOfVotes) onlyOwner public {
        maxVote = noOfVotes;
    }

    //set a way to change the number of votes required

      function setOwners(address _add) public onlyOwner{
        ownerList[_add] = true;
    }

    //set list of owner
}