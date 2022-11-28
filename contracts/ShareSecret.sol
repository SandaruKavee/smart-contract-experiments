//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


// contract of a node
contract Node {
    address public owner;
    address payable[] public shareHolders; //My secret holders
    string[] public shares;    //Shares list belonging to the user 
    mapping(address => string) public shareHoldersMap; //My secret baring holders
    mapping(address => string) public sharesMap; //The secrets I'm holding

    constructor(string[] memory secretShares) {
        owner = msg.sender;
        shares =secretShares ;
    }

    // msg.data (bytes): complete calldata
    // msg.gas (uint): remaining gas
    // msg.sender (address): sender of the message (current call)
    // msg.sig (bytes4): first four bytes of the calldata (i.e. function identifier)
    // msg.value (uint): number of wei sent with the message


    modifier onlyOwner() {
        require(msg.sender == owner, "only owner has the privilege");
        _;
    }


//!Secret owners role----------------------------------------------------------------------//

//Distribute the share function 
//Need to improve this with validations 
    function distribute() public onlyOwner {
        if (shares.length <= shareHolders.length) {
            for (uint256 i = 0; i < shares.length; i++) {
                shareHoldersMap[shareHolders[i]] = shares[i];
                notifySendingToHolders(shareHolders[i], shares[i]);
            }
        }
    }

    function getShareHolders() public view returns (address payable[] memory) {
        return shareHolders;
    }

    function getShares() public view returns (string[] memory) {
        return shares;
    }
    

    //Addiing a share holder to the list
    function addShareHolders(address payable shareHolder) public onlyOwner {
        shareHolders.push(shareHolder);
    }

    function remove(uint256 index) public {
        // Move the last element into the place to delete
        shareHolders[index] = shareHolders[shareHolders.length - 1];
        // Remove the last element
        shareHolders.pop();
    }

//Removing a share holder from the list 
    function removeShareHolders(address payable shareHolder) public onlyOwner {
        uint256 i = 0;
        for (i; i < shareHolders.length; i++) {
            if (shareHolders[i] == shareHolder) {
                break;
            }
        }
        remove(i);
    }

    function regenerate() public view returns (string[] memory){
        return shares;
    }

    function notifySendingToHolders(address payable holder, string memory share)public onlyOwner{

    }

    function askingFromHolders() public onlyOwner {

    }
    function repayGasFee()public onlyOwner{

    }

//Secret Holder's role-------------------------------------------------------------------------//
    function acceptInvitation() public returns (bool){
        notifySecretOwner(true);
        return true;
    }
    function rejectInvitation() public returns (bool){
        notifySecretOwner(false);
        return false;
    }
    function notifySecretOwner(bool acceptStatus) public {

    }
    function releaseSecret(address ownerAddress) public view returns (string memory){
        string memory secret =sharesMap[ownerAddress];
        return secret;
    }
    function rejectSecretRequest(address ownerAddress)public view{

    }
    

}

//secretHolder 
contract PublicContract {
    mapping(string => Node) public nodesMap;

    function getAddress(string memory name) public view returns(Node){
        return nodesMap[name];
    }
    function register(string memory name,Node node)public {
        nodesMap[name]=node;
        return;
    }
    function notifyShareHolders(string memory name)public {
        Node myNode= nodesMap[name];
        myNode.askingFromHolders();
        return;
    }
    function regenerateSecret(string memory name)public view returns (string[] memory){
        Node myNode= nodesMap[name];
        string[] memory shares_new=myNode.regenerate();
        return shares_new;
    }


    
}
