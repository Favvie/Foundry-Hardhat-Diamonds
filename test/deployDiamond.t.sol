// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/facets/ERC20Facet.sol";
import "../contracts/Diamond.sol";

import "./helpers/DiamondUtils.sol";

contract DiamondDeployer is DiamondUtils, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    ERC20Facet tokenF;

    function setUp() public {
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet), "Diamond Contract", "DCT", 18);
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        tokenF = new ERC20Facet();

        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](3);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            FacetCut({
                facetAddress: address(tokenF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("ERC20Facet")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        // DiamondLoupeFacet(address(diamond)).facetAddresses();

        //call a function
        // ERC20Facet(address(diamond)).balanceOf(address(this));

        // Test ERC20 token
        // assertEq(ERC20Facet(address(diamond)).name(), "Diamond Contract");
        // assertEq(ERC20Facet(address(diamond)).symbol(), "DCT");
        // assertEq(ERC20Facet(address(diamond)).decimals(), 18);
        // // ERC20Facet(address(diamond)).symbol();
        // // ERC20Facet(address(diamond)).decimals();
        // // ERC20Facet(address(diamond)).totalSupply();

        // // ... existing code ...
        // ERC20Facet(address(diamond)).mint(); // Call the new mint function

        // assertEq(ERC20Facet(address(diamond)).balanceOf(address(this)), 1000 * 10**18); // Check the balance

        // uint256 balance = ERC20Facet(address(diamond)).balanceOf(address(this)); // Check the balance
        // // ... existing code ...
        // ERC20Facet(address(diamond)).transfer(address(diamond), balance);

        // assertEq(ERC20Facet(address(diamond)).balanceOf(address(diamond)), 1000 * 10**18); // Check the balance

        // // ERC20Facet(address(diamond)).balanceOf(address(diamond));

        //  assertEq(ERC20Facet(address(diamond)).balanceOf(address(this)), 0); // Check the balance

        // // ERC20Facet(address(diamond)).balanceOf(address(this)); // Check the balance
    }

    function testDeployDiamond() public {
        // Call a function to verify deployment
        assertEq(DiamondLoupeFacet(address(diamond)).facetAddresses().length, 4); // Check that facets are added
    }

    function testERC20Token() public {
        // ERC20Facet(address(diamond)).balanceOf(address(this));

        assertEq(ERC20Facet(address(diamond)).name(), "Diamond Contract");
        assertEq(ERC20Facet(address(diamond)).symbol(), "DCT");
        assertEq(ERC20Facet(address(diamond)).decimals(), 18);

        ERC20Facet(address(diamond)).mint(); // Call the new mint function

        assertEq(ERC20Facet(address(diamond)).balanceOf(address(this)), 1000 * 10**18); // Check the balance

        uint256 balance = ERC20Facet(address(diamond)).balanceOf(address(this)); // Check the balance
        
        ERC20Facet(address(diamond)).transfer(address(diamond), balance);

        assertEq(ERC20Facet(address(diamond)).balanceOf(address(diamond)), 1000 * 10**18); // Check the balance

        assertEq(ERC20Facet(address(diamond)).balanceOf(address(this)), 0); // Check the balance

    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}
