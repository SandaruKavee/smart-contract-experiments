//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract SecretShare {
    address public owner;
    address payable[] public shareHolders;              //My secret holders 
    string[] public shares=["describe", "action", "town", "gift", "capital", "river" ,"enroll", "meat", "wisdom" ,"steel" ,"neck", "defy"];
    mapping(address => string) public shareHoldersMap;  //My secret baring holders 
    mapping(address => string) public sharesMap;        //The secrets I'm holding 



    constructor() {
        owner = msg.sender;
    }
// msg.data (bytes): complete calldata
// msg.gas (uint): remaining gas
// msg.sender (address): sender of the message (current call)
// msg.sig (bytes4): first four bytes of the calldata (i.e. function identifier)
// msg.value (uint): number of wei sent with the message
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can pick the winner");
        _;
    }

    function distribute() public onlyOwner {
        if (shares.length <= shareHolders.length) {
            for (uint256 i = 0; i < shares.length; i++) {
                shareHoldersMap[shareHolders[i]] = shares[i];
                notifySendingToHolders(shareHolders[i], shares[i]);
            }
        }
    }

    function addShareHolders(address payable shareHolder) public onlyOwner {
        shareHolders.push(shareHolder);
    }
    function remove(uint  index ) public {
        // Move the last element into the place to delete
        shareHolders[index] = shareHolders[shareHolders.length - 1];
        // Remove the last element
        shareHolders.pop();
    }
    function removeShareHolders(address payable shareHolder) public onlyOwner {
        uint i=0;
        for (i;i<shareHolders.length;i++){
            if (shareHolders[i]==shareHolder){
                break;
            }
        }
       remove(i);

    }

    function regenerate(address name) public {

    }

    function notifySendingToHolders(address payable holder, string memory share)public onlyOwner{

    }

    function askingFromHolders() public onlyOwner {

    }
}
