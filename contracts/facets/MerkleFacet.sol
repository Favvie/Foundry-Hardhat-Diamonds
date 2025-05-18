// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// import "./interfaces/IERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; 
// import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {MerkleProof} from "../libraries/LibMerkle.sol";
import {IERC721} from "../interfaces/IERC721.sol";

/**
 * @title MerkleAirdrop
 * @dev This contract allows users to claim airdropped ERC20 tokens using a Merkle proof. 
 * The contract uses a Merkle tree to efficiently and securely verify that a user is eligible 
 * to claim a specific amount of tokens.
 */
contract MerkleAirdrop {
    // Address of the ERC20 token to be airdropped
    address public airdropNFTAddress;

    // Root of the Merkle tree containing all eligible addresses and amounts
    bytes32 public merkleRoot;

    // Mapping to keep track of addresses that have already claimed their airdrop
    mapping(address => bool) public hasClaimed;

    // Event that is emitted when a successful claim is made
    event SuccessfulClaim(address indexed _address, uint256 _amount);

    /**
     * @dev Constructor to initialize the airdrop contract.
     * @param _airDropTokenAddress The address of the ERC20 token to be distributed.
     * @param _merkleRoot The root of the Merkle tree containing the airdrop data (addresses and amounts).
     */
    constructor(address _airDropTokenAddress, bytes32 _merkleRoot) {
        airdropNFTAddress = _airDropTokenAddress;
        merkleRoot = _merkleRoot;
    }

    /**
     * @dev Function to claim airdrop tokens.
     * @param amount The amount of tokens the caller is claiming.
     * @param proof A Merkle proof proving that the caller is entitled to claim the specified amount.
     */
    function claimAirdrop(uint256 tokenId, bytes32[] calldata proof) external {
        // Ensure that the caller has not already claimed their airdrop
        require(!hasClaimed[msg.sender], "Airdrop already claimed.");
        
        // Create the leaf node by hashing the caller's address and the amount they are claiming
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, tokenId))));
        
        // Verify the Merkle proof against the stored Merkle root
        // The proof ensures that the leaf (address and amount) exists in the Merkle tree with the given root
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof.");

        // Mark the caller's address as having claimed the airdrop
        hasClaimed[msg.sender] = true;

         // Transfer the NFT to the caller
        IERC721(airdropNFTAddress).safeTransferFrom(address(this), msg.sender, tokenId);
        
        // Emit an event to log the successful claim
        emit SuccessfulClaim(msg.sender, tokenId);
    }

    //  function getContractBalance() external view returns(uint256) {
    //     // onlyOwner();
    //     return IERC20(airDropTokenAddress).balanceOf(address(this));
    // }
}