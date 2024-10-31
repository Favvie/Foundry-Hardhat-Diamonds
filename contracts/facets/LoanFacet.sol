// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {LibDiamond} from "../libraries/LibDiamond.sol";
import {IERC721} from "../interfaces/IERC721.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {ERC20} from "./ERC20.sol";

contract LoanFacet {
    
    function createLoan(address _nft, uint _tokenId, uint _loanDuration) external {
        require(msg.sender != address(0), "LoanFacet: caller is not a valid address");
        require(IERC721(_nft).ownerOf(_tokenId) == msg.sender, "LoanFacet: caller is not the owner");
        require(!nftUsedAsCollateral[_nft][_tokenId], "NFT already collateralized");

        // Transfer the NFT to the contract as collateral
        IERC721(_nft).transferFrom(msg.sender, address(this), _tokenId);

        // Store loan information
        loans[msg.sender] = Loan({
            loanId: loans.length,
            nft: _nft,
            tokenId: _tokenId,
            isActive: true,
            borrower: msg.sender,
            amount: _amount,
            interestRate: 5,
            dueDate: block.timestamp + _loanDuration
        });
        IERC20("0x0000000000000000000000000000000000000000").transfer(msg.sender, _amount);
        nftUsedAsCollateral[_nft][_tokenId] = true;


    }

    function calculateInterest() external view returns (uint256) {}

    function repayLoan(uint256 loanId) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(ds.loans[loanId].isActive, "Loan does not exist");
        require(ds.loans[loanId].borrower == msg.sender, "Caller is not the borrower");
        // require(ds.loans[loanId].amount != 0, "Loan is fully repaid");
        require(IERC20("0x0000000000000000000000000000000000000000").balanceOf(msg.sender) >= ds.loans[loanId].amount, "Not enough balance");

        IERC20("0x0000000000000000000000000000000000000000").transferFrom(msg.sender, address(this), ds.loans[loanId].amount);
        IERC721(ds.loans[loanId].nft).transferFrom(address(this), msg.sender, ds.loans[loanId].tokenId);

        ds.loans[loanId].isActive = false;
        nftUsedAsCollateral[loan.nft][loan.tokenId] = false;

    }

    function liquidate() external {}


}

