// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Items.sol";
import "./Enums.sol";

// Must be minter of Items
// Must be burner of Items
contract ExpeditionItemMerger is Proxy, Ownable {
    struct MergeDetails {
        uint256 inputCount;
        uint256 outputType;
    }

    // Address of possible extension-contract.
    // Extension-contract must inherit this contract and do not modify existing data layout, only extend it.
    address public extension;
    Items public items;
    bool public isContractActive = true;

    // InputItemType => MergeDetails
    mapping (uint256 => MergeDetails) public mergeDetails;

    event ItemMerged(address indexed to, uint256 indexed inputType, uint256 indexed tokenId, uint256 outputType);

    constructor(Items items_) {
        setItems(items_);

        mergeDetails[ITEM_EXP_PIECE_TRIPOD] =    MergeDetails({inputCount: 6, outputType: ITEM_EXP_TRIPOD});
        mergeDetails[ITEM_EXP_PIECE_DRONE] =     MergeDetails({inputCount: 6, outputType: ITEM_EXP_DRONE});
        mergeDetails[ITEM_EXP_PIECE_SCOUT] =     MergeDetails({inputCount: 5, outputType: ITEM_EXP_SCOUT});
        mergeDetails[ITEM_EXP_PIECE_ROVER] =     MergeDetails({inputCount: 5, outputType: ITEM_EXP_ROVER});
        mergeDetails[ITEM_EXP_PIECE_SATELLITE] = MergeDetails({inputCount: 4, outputType: ITEM_EXP_SATELLITE});
    }

    function _implementation() internal view override returns (address) {
        return extension;
    }

    function setExtension(address extension_) public onlyOwner {
        require(extension_ != address(0), "Extension is zero");
        extension = extension_;
    }

    function setContractActive(bool isContractActive_) public onlyOwner {
        isContractActive = isContractActive_;
    }

    function setItems(Items items_) public onlyOwner {
        require(address(items_) != address(0), "Items is zero");
        items = items_;
    }

    function setMergeDetails(uint256 inputType, uint256 inputCount, uint256 outputType) public onlyOwner {
        mergeDetails[inputType] = MergeDetails({inputCount: inputCount, outputType: outputType});
    }

    function mergeItems(uint256[] calldata itemIds) public returns (uint256 tokenId) {
        require(isContractActive, "Not active");
        require(itemIds.length > 0, "Input is empty");
        
        uint256 inputType = items.types(itemIds[0]);
        
        MergeDetails storage details = mergeDetails[inputType];
        require(details.inputCount > 0, "Unknown input item type");
        require(details.inputCount <= itemIds.length, "Not enough items");

        for (uint256 i = 0; i < details.inputCount; i++) {
            uint256 itemId = itemIds[i];
            require(items.ownerOf(itemId) == address(msg.sender), "Not item owner");
            require(items.types(itemId) == inputType, "Items not the same type");

            items.burn(itemId);
        }

        tokenId = items.mint(msg.sender, details.outputType);

        emit ItemMerged(msg.sender, inputType, tokenId, details.outputType);
    }
}
