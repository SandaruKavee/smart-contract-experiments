//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Node.sol";
//secretHolder 
contract PublicContract {
    //sample node 
    struct SampleNode{
        address publicAddress;
        address contractAddress;
        
    }

    //Request type to add as a share holder
    struct Request{
        address secretOwner;
        address shareHolder;
    }

    //Share structure
    struct Share{
        address secretOwner;
        address shareHolder;
        string sharedString;
    }

    //Request to release the secret 
    struct ShareRequest{
        address requesterAddress;
        string name;
        address ownerAddress;
    }

    //address to contract address map
    mapping (address => address ) public myAddressToContractAddressMap;

    //name to sample nodes map
    mapping(string => SampleNode) public sampleNodesMap;

    //be a holder requests list
    Request[] public holderRequests;

    //secret requesting list original owner's address and requester's address mapping
    ShareRequest[] public secretRequests;
    

    //Released shares for holders
    Share[] assignedSharesForHolders;

    //Released Shares for owners 
    Share[] releasedSharesByHolders;

    //accepted requests to bea share holder 
    Request[] public acceptedBeShareHolderRequests;

    //Cancelled requests to be a share holder
    Request[] public cancelledBeShareHolderRequests;

    //

//Register to the public contract 
    function register(string memory  name,address publicAddress,address myContractAddress)public {
        //nodesMap[name]=node;
        myAddressToContractAddressMap[publicAddress]=myContractAddress;
        SampleNode memory registeringNode= SampleNode(publicAddress,myContractAddress);
        sampleNodesMap[name]=registeringNode;
        return;
    }

//Get node contract object using the name 
    function getContractAddressByName(string memory name) public view returns(SampleNode memory){
        SampleNode memory new_node= sampleNodesMap[name];
        return new_node;
    }
//Get contractAddress using the publicAddress
    function getContractAddressByPublicAddress(address publicAddress) public view returns(address ){
        return myAddressToContractAddressMap[publicAddress];
    }

// Access public contract as a share holder --------------------------------------------------------

//Check there are any requests to add me as a share holder
    function checkRequestsByShareholder(address holderAddress)public view returns(address[] memory ) {
        uint256 tot = getSecretOwnerAddressesCountInHolderRequests(holderAddress); // write a method named getSecretOwnerAddressesCount() to get secretOwnerAddresses count
        uint256 count = 0;
        address[] memory  _secretOwnerAddress= new address[](tot);
        for (uint256 i = 0; i<holderRequests.length; i++){
            Request memory request= holderRequests[i];
            if (request.shareHolder==holderAddress){
            _secretOwnerAddress[count] = request.secretOwner;
            count = count + 1;
            }

        }
     return _secretOwnerAddress;
    }

    function getSecretOwnerAddressesCountInHolderRequests(address holderAddress)public view returns(uint256) {
        uint256  count = 0;
        uint256 i = 0;
        for (i; i<holderRequests.length; i++){
            Request memory request= holderRequests[i];
            if (request.shareHolder==holderAddress){
                count = count + 1;
            }

        }
        return count;
    }

//Check there is someone asking for the share from me 
    function checkRequestsForTheSeceret(address[]memory secretOwners)public view returns(address[] memory ) {
        uint256 tot = getSecretOwnerAddressesCountInSecretRequests(secretOwners); // write a method named getSecretOwnerAddressesCount() to get secretOwnerAddresses count
        uint256 count = 0;
        address[] memory _secretOwnerAddresses = new address[](tot);
    
        for (uint256 i = 0; i<secretOwners.length; i++){
            address  tempOwner=secretOwners[i];
            for (uint256 j = 0; j<secretRequests.length; j++){
                ShareRequest memory tempSecretRequest=secretRequests[j];
                if (tempSecretRequest.ownerAddress==tempOwner){
                    _secretOwnerAddresses[count] = tempOwner;
                    count = count + 1;
                }

            }

        }
     return _secretOwnerAddresses;
    }
    

    function getSecretOwnerAddressesCountInSecretRequests(address[]memory secretOwners)public view returns(uint256) {
        uint256  count = 0;
        for (uint256 i = 0; i<secretOwners.length; i++){
           address  tempOwner =secretOwners[i];
            for (uint256 j = 0; j<secretRequests.length; j++){
                ShareRequest memory tempSecretRequest=secretRequests[j];
                if (tempSecretRequest.ownerAddress==tempOwner){
                    count = count + 1;
                }

            }

        }
        return count;
    }
//Give my release to the public 
    function releaseTheSecret(address secretOwner,string memory sharedString)public {
         for (uint256 i = 0; i<secretRequests.length; i++){
            ShareRequest memory tempSecretRequest=secretRequests[i];
            if(tempSecretRequest.ownerAddress==secretOwner){
                address requester= tempSecretRequest.requesterAddress;
                address requesterContractAddress=myAddressToContractAddressMap[requester];
                Node requesterContract= Node(requesterContractAddress);
                requesterContract.saveToRegeneratedShares(sharedString);
            }

        }
    }

//remove from holder request list 
function removeFromHolderRequestList(uint256 index) public {
        // Move the last element into the place to delete
        holderRequests[index] = holderRequests[holderRequests.length - 1];
        // Remove the last element
        holderRequests.pop();
    }

//Respond to be the share holder 
    function respondToBeShareHolder(address shareHolder,address secretOwner,bool  acceptance)public {
        uint256 i = 0;
        for (i; i<holderRequests.length; i++){
            Request memory request= holderRequests[i];
            if (request.shareHolder==shareHolder && request.secretOwner==secretOwner){
                removeFromHolderRequestList(i);
                if (acceptance){
                    acceptedBeShareHolderRequests.push(request);
                }else{
                    cancelledBeShareHolderRequests.push(request);
                }
            }
        }
    }




//Access as a secret owner ----------------------------------------------------------------------

//Make a request to add a node as a share holder
    function makeARequestToBeAShareHolder(address secretOwner,address holder)public {
        Request memory new_request= Request(secretOwner,holder);
        holderRequests.push(new_request);


 }
//get the count of the accepted holders list 
    function getSecretHolderAddressesCountInAcceptedHoldersList(address ownerAddress)public view returns(uint256) {
        uint256  count = 0;
        uint256 i = 0;
        for (i; i<acceptedBeShareHolderRequests.length; i++){
            Request memory request= acceptedBeShareHolderRequests[i];
            if (request.secretOwner==ownerAddress){
                count = count + 1;
            }

        }
        return count;
    }

//get the be holder request accepted holders list 
    function getRequestAcceptedHoldersList(address secretOwner)public view returns(address[] memory) {
        uint256 tot = getSecretHolderAddressesCountInAcceptedHoldersList(secretOwner); // write a method named getSecretOwnerAddressesCount() to get secretOwnerAddresses count
        uint256 count = 0;
        address[] memory _shareHolderAddresses = new address[](tot);
        

        for (uint256 i = 0; i<acceptedBeShareHolderRequests.length; i++){
            Request memory request= acceptedBeShareHolderRequests[i];
            if (request.secretOwner==secretOwner){
                _shareHolderAddresses[count] = request.shareHolder;
                count = count + 1;
            }

        }
     return _shareHolderAddresses;
    }

// Make shares accessible to the share holders 
    function makeSharesAccessibleToTheHolders(address secretOwner,address holder,string memory sharedString) public{
        address myContractAddress= myAddressToContractAddressMap[holder];
        Node distributingNode= Node(myContractAddress);
        distributingNode.takeTheSecretFromTheOwner(secretOwner,sharedString);
        return;
    }

//Make a request that I need the shares   
    function makeARequestToGetShares(string memory name,address requesterAddress)public {
        SampleNode memory sampleNode= sampleNodesMap[name];
        ShareRequest memory shareRequest=ShareRequest(requesterAddress,name,sampleNode.publicAddress);
        secretRequests.push(shareRequest);
        return;

    }
// //Regenerate the shares from released shares 
//     function regenerateSecret(string memory name)public view returns (string[] memory){
//         // Node myNode= nodesMap[name];
//         // string[] memory shares_new=myNode.regenerate();
//         // return shares_new;
//     }

    
}