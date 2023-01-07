//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./PublicContract.sol";
// contract of a node
contract Node {
    address public owner;
    address payable[] public requestedShareHolders; //temporary list of share holders
    address[] public  shareHolders; //My secret holders
    string[] public shares;    //Shares list belonging to the user 
    mapping(address => string) public shareHoldersMap; //My secret baring holders

    mapping(address => string) public sharesMap; //The secrets I'm holding

    address[] public secretOwners;  //The owners of the secrets that I'm holding 

    string[] public regeneratedShares;      //regenerated shares as a requester
    
    address public myContractAddress; //mycontract address 

    PublicContract contract_new; 

    constructor(string[] memory secretShares) {
        owner = msg.sender;
        shares =secretShares ;
        //Hard coded deployment of the public contract
        contract_new=PublicContract(0xd9145CCE52D386f254917e481eB44e9943F39138);
        myContractAddress = address(this);

    }
    struct AddHolderRequest{
        address secretOwner;
        address shareHolder;
    }

    // msg.data (bytes): complete calldata
    // msg.gas (uint): remaining gas
    // msg.sender (address): sender of the message (current call)
    // msg.sig (bytes4): first four bytes of the calldata (i.e. function identifier)
    // msg.value (uint): number of wei sent with the message


    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner has the privilege");
        _;
    }

//Every node should register with a name into the public contract 
    function registerToPublicContract(string memory name)public onlyOwner{
        contract_new.register(name,owner,myContractAddress);
        return;

    }


//Share Holder's role-------------------------------------------------------------------------//

//Check the requests from the secret owner to a node to add as a share holder
    function checkRequestsForBeAHolder()public onlyOwner view returns (address[] memory){
    address[] memory _requestsForMe = contract_new.checkRequestsByShareholder(owner);
    return _requestsForMe;
    }


    function acceptInvitation(address secretOwner) public onlyOwner  {
        contract_new.respondToBeShareHolder(owner,secretOwner,true);
    }
    function rejectInvitation(address secretOwner) public onlyOwner {
       contract_new.respondToBeShareHolder(owner,secretOwner,true);
        
    }

    //Take the secret form the secret owner and write the share in the shares map 
    //( this is access though the public contract by the secret owner ) 

    function takeTheSecretFromTheOwner(address ownerAddress,string memory sharedString) public{
        secretOwners.push(ownerAddress);
        sharesMap[ownerAddress]=sharedString;
    }


    //Check the requests from the requester to release the secret
    function checkRequestsForShare()public onlyOwner view returns (address[] memory){
    address[] memory _shareRequests = contract_new.checkRequestsForTheSeceret(secretOwners);
    return _shareRequests;
    }

    //release the secret to the requester
    function releaseSecret(address secretOwnerAddress) public onlyOwner  {
        string memory myShare =sharesMap[secretOwnerAddress];
        contract_new.releaseTheSecret(secretOwnerAddress,myShare);
        
    }


    
    

//!Secret owners role----------------------------------------------------------------------//


//Addiing a share holder to a temporary list
    function addTemporaryShareHolders(address payable shareHolder) public onlyOwner {
        requestedShareHolders.push(shareHolder);
       
    }



//get my share holders 
    function getShareHolders() public view returns (address[] memory) {
        return shareHolders;
    } 


    function remove(uint256 index) public {
        // Move the last element into the place to delete
        requestedShareHolders[index] = requestedShareHolders[requestedShareHolders.length - 1];
        // Remove the last element
        requestedShareHolders.pop();
    }

//Removing a share holder from the list 
    function removeShareHolders(address payable shareHolder) public onlyOwner {
        uint256 i = 0;
        for (i; i < requestedShareHolders.length; i++) {
            if (requestedShareHolders[i] == shareHolder) {
                break;
            }
        }
        remove(i);
    }



//Make the be holder requests 
    function makingBeHolderRequests() public onlyOwner {
        uint256 i = 0;
        for (i; i<requestedShareHolders.length; i++){
            address temporaryHolder= requestedShareHolders[i];
            contract_new.makeARequestToBeAShareHolder(owner,temporaryHolder);

        }
    }

//check the holder request acceptance and make the share holders list 
    function MakeShareHoldersListToDistribute()public  onlyOwner{
        address[] memory _requestAcceptedHolders=contract_new.getRequestAcceptedHoldersList(owner);  

        for (uint256 i = 0; i<_requestAcceptedHolders.length; i++){
            address temporaryHolder= _requestAcceptedHolders[i];
            shareHolders.push(temporaryHolder);
            //shareHolders[i]=temporaryHolder;

        }
    }

//Distribute the share function 
//Need to improve this with validations 
    function distribute() public onlyOwner {
        require(shares.length <= shareHolders.length, "Not enough share holders!!");
        if (shares.length <= shareHolders.length) {
            for (uint256 i = 0; i < shares.length; i++) {
                shareHoldersMap[shareHolders[i]] = shares[i]; 
                contract_new.makeSharesAccessibleToTheHolders(owner,shareHolders[i],shares[i]);
            }
        }

    }

//requesting the shares from share holders 
    function requestSharesFromHolders(string memory name) public   {
        contract_new.makeARequestToGetShares(name,owner);
        return ;
    }

//saves the share to the requested nodes regenerated shsres list
    function saveToRegeneratedShares(string memory share)public{
        regeneratedShares.push(share);
        return;
    }

//Regenerate the secret after the responses from the holders 
    function regenerate() public view returns (string[] memory){
        //This should generate from the other nodes 
        return regeneratedShares;
    }
//Repay the gas fee to the holders 
    function repayGasFee()public onlyOwner{

    }

}

