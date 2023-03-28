//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//wallet contract
contract WalletContract {
    struct Node {
        address ownerAddress;
        string userName;
        address[] shareHolders;
        address[] temporaryShareHolders;
        address[] holderRequestAcceptedHolders;
        address[] holderRequestRejectedHolders;
        string[] myShares;
        string[] releasedShares;
        address[] secretOwners;
        string email;
        string encryptedVault;
        State state;
    }
    struct OwnerShareAndHolder {
        address owner;
        address holder;
        string share;
    }
    struct HolderRequest {
        address requesterAddress;
        address receiverAddress;
    }
    struct ShareRequest {
        address requesterAddress;
        string userName;
    }
    struct Share {
        address secretOwner;
        address shareHolder;
        string sharedString;
    }
    enum State {
        REGISTERED,
        SHAREHOLDER_REQUESTED,
        SHAREHOLDER_ACCEPTED,
        DISTRIBUTED,
        RECOVERY_REQUESTED,
        RECOVERY_ACCEPTED
    }
    mapping(address => Node) private publicAddressToNodeMap;
    mapping(string => address) private userNameToPublicAddressMap;
    string[] private userNames;
    address[] private users;
    HolderRequest[] private holderRequestPool;
    ShareRequest[] private shareRequestPool;
    mapping(address => OwnerShareAndHolder[]) private holderAddressToSharesMap;

    //!Modifiers and commin functions-------------------------------------------------------------------------//

    modifier checkIsRegistered() {
        require(
            isUserRegistered(msg.sender),
            "Owner has to register to public contract"
        );
        _;
    }

    //check the user is registered
    function isUserRegistered(address addr) public view returns (bool) {
        for (uint i = 0; i < users.length; i++) {
            if (users[i] == addr) {
                return true;
            }
        }
        return false;
    }

    //register to the wallet contract
    function registerToWalletContract(string memory name) public {
        require((!isUserRegistered(msg.sender)), "User has already registered");
        // OwnerShareAndHolder[] memory sharesMapTemp=new OwnerShareAndHolder[](0);
        // OwnerShareAndHolder[] memory shareHoldersMapTemp=new OwnerShareAndHolder[](0);
        Node memory newNode = Node({
            ownerAddress: msg.sender,
            userName: name,
            shareHolders: new address[](0),
            temporaryShareHolders: new address[](0),
            holderRequestAcceptedHolders: new address[](0),
            holderRequestRejectedHolders: new address[](0),
            myShares: new string[](0),
            releasedShares: new string[](0),
            secretOwners: new address[](0),
            // sharesMap: sharesMapTemp,
            // shareHoldersMap: shareHoldersMapTemp,
            email: "",
            encryptedVault: "",
            state: State.REGISTERED
        });
        publicAddressToNodeMap[msg.sender] = newNode;
        userNameToPublicAddressMap[name] = msg.sender;
        userNames.push(name);
        users.push(msg.sender);
        return;
    }

    //get my user name
    function getUserName()
        public
        view
        checkIsRegistered
        returns (string memory)
    {
        Node memory tempNode = publicAddressToNodeMap[msg.sender];
        return tempNode.userName;
    }

    //get email address
    function getmyEmailAddress()
        public
        view
        checkIsRegistered
        returns (string memory)
    {
        Node memory tempNode = publicAddressToNodeMap[msg.sender];
        return tempNode.email;
    }

    //set email address
    function setEmail(string memory email) public view {
        Node memory tempNode = publicAddressToNodeMap[msg.sender];
        tempNode.email = email;
        return;
    }

    //set vault hash value
    function setEncryptedVault(string memory vault) public view {
        Node memory tempNode = publicAddressToNodeMap[msg.sender];
        tempNode.encryptedVault = vault;
        return;
    }

    //!Share Holder's role-------------------------------------------------------------------------//
    //Check the requests from the secret owner to a node to add as a share holder
    function checkRequestsForBeAHolder()public view checkIsRegistered returns (address[] memory)
    {
        uint256 tot = getSecretOwnerAddressesCountInHolderRequests(); // write a method named getSecretOwnerAddressesCount() to get secretOwnerAddresses count

        //Node memory tempNode = publicAddressToNodeMap[msg.sender];
        // address[] memory _requestsForMe = defaultPublicContract.checkRequestsByShareholder(owner);
        // return _requestsForMe;  uint256 tot = getSecretOwnerAddressesCountInHolderRequests(holderAddress); // write a method named getSecretOwnerAddressesCount() to get secretOwnerAddresses count
        uint256 count = 0;
        address[] memory _secretOwnerAddress = new address[](tot);
        for (uint256 i = 0; i < holderRequestPool.length; i++) {
            HolderRequest memory holderRequest = holderRequestPool[i];
            if (holderRequest.receiverAddress == msg.sender) {
                _secretOwnerAddress[count] = holderRequest.requesterAddress;
                count = count + 1;
            }
        }
        return _secretOwnerAddress;
    }

    function getSecretOwnerAddressesCountInHolderRequests() public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < holderRequestPool.length; i++) {
            HolderRequest memory holderRequest = holderRequestPool[i];
            if (holderRequest.receiverAddress == msg.sender) {
                count = count + 1;
            }
        }
        return count;
    }

    //Accept the share holder invitation
    function acceptInvitation(address secretOwner) public checkIsRegistered {
        for (uint256 i = 0; i < holderRequestPool.length; i++) {
            HolderRequest memory request = holderRequestPool[i];
            if (
                request.receiverAddress == msg.sender &&
                request.requesterAddress == secretOwner
            ) {
                delete holderRequestPool[i];
                //add to secret owners permenent list
            }
        }
    }

    //Reject the share holder invitation
    function rejectInvitation(address secretOwner) public checkIsRegistered {
            for (uint256 i = 0; i < holderRequestPool.length; i++) {
            HolderRequest memory request = holderRequestPool[i];
            if (
                request.receiverAddress == msg.sender &&
                request.requesterAddress == secretOwner
            ) {
                delete holderRequestPool[i];
                //remove from the secret owners temporary list
            }
        }
    }
    //Take the secret form the secret owner and write the share in the shares map
    //( this is access though the public contract by the secret owner )

    

    //Check the requests from the requester to release the secret
    function checkRequestsForShare()public view checkIsRegistered returns (address[] memory){
        Node memory tempNode = publicAddressToNodeMap[msg.sender];
       uint256 tot = getSecretOwnerAddressesCountInSecretRequests(tempNode.secretOwners); // write a method named getSecretOwnerAddressesCount() to get secretOwnerAddresses count
        uint256 count = 0;
        address[] memory _secretOwnerAddresses = new address[](tot);
    
        for (uint256 i = 0; i<tempNode.secretOwners.length; i++){
            address  tempOwner=tempNode.secretOwners[i];
            for (uint256 j = 0; j<shareRequestPool.length; j++){
                ShareRequest memory tempSecretRequest=shareRequestPool[j];
                if (userNameToPublicAddressMap[tempSecretRequest.userName]==tempOwner){
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
            for (uint256 j = 0; j<shareRequestPool.length; j++){
                ShareRequest memory tempSecretRequest=shareRequestPool[j];
                if (userNameToPublicAddressMap[tempSecretRequest.userName]==tempOwner){
                    count = count + 1;
                }

            }

        }
        return count;
    }
    //delete secret owner from the holding secret owners list
    function deleteSecretOwnerFromListAfterReleasing(address secretOwnerAddress) public checkIsRegistered {
        // for (uint256 i = 0; i < secretOwners.length; i++) {
        //     if (secretOwners[i] == secretOwnerAddress) {
        //         delete secretOwners[i];
        //     }
        // }
    }

    //release the secret to the requester
    function releaseSecret(address secretOwnerAddress) public checkIsRegistered {
        // string memory myShare = sharesMap[secretOwnerAddress];
        // defaultPublicContract.releaseTheSecret(secretOwnerAddress, myShare);
        // defaultPublicContract.updateOwnersAcceptedToReleaseList(
        //     secretOwnerAddress,
        //     msg.sender
        // );
        // //defaultPublicContract.deleteShareRequest(msg.sender,secretOwnerAddress);
        // deleteSecretOwnerFromList(secretOwnerAddress);
    }

    //!secret owner's role-------------------------------------------------------------------------//
     function addTemporaryShareHolders(address[] memory tempShareHolders)  public checkIsRegistered {
        Node memory tempNode = publicAddressToNodeMap[msg.sender];
         Node memory newNode = Node({
            ownerAddress: msg.sender,
            userName: tempNode.userName,
            shareHolders: new address[](0),
            temporaryShareHolders: tempShareHolders,
            holderRequestAcceptedHolders: new address[](0),
            holderRequestRejectedHolders: new address[](0),
            myShares: new string[](0),
            releasedShares: new string[](0),
            secretOwners: new address[](0),
            // sharesMap: sharesMapTemp,
            // shareHoldersMap: shareHoldersMapTemp,
            email: "",
            encryptedVault: "",
            state: State.REGISTERED
        });
        publicAddressToNodeMap[msg.sender]=newNode;
        delete tempNode;
        return;
        
    }
    function getTemporaryShareHolders() view public checkIsRegistered returns(address[] memory){
        Node memory tempNode = publicAddressToNodeMap[msg.sender];
       
        return  tempNode.temporaryShareHolders;
    }
    //Make a request to add a node as a share holder
    function makeHolderRequests()public checkIsRegistered{
        Node memory tempNode = publicAddressToNodeMap[msg.sender];
        for (uint256 j = 0; j<tempNode.temporaryShareHolders.length; j++){
        HolderRequest memory new_request= HolderRequest(msg.sender,tempNode.temporaryShareHolders[j]);
        holderRequestPool.push(new_request);
                

        }
    }


 

}
