// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Items.sol";

// Must be minter in Items
// Must be burner in Items
contract ItemsUtils is Ownable {
    Items public items;

    // V3
    mapping(address => bool) public minters;
    bool public canMint = true;
    //---

    // V4
    mapping(address => bool) public burners;
    bool public canBurn = true;
    //---

    constructor(Items items_) {
        setItems(items_);
        setMinter(msg.sender, true);
        setBurner(msg.sender, true);
    }

    function setItems(Items items_) public onlyOwner {
        require(address(items_) != address(0), "Items is zero");
        items = items_;
    }

    function itemsOf(address owner, uint offset, uint limit) public view returns (uint256[] memory ids) {
        require(owner != address(0), "Addr is zero");
        uint256 count = items.balanceOf(owner);
        
        if (offset > count) {
            offset = count;
        }

        uint resultLen = count - offset;
        resultLen = (limit > 0 && limit < resultLen) ? limit : resultLen;
        
        ids = new uint256[](resultLen);
        for (uint256 i = 0; i < resultLen; i++) {
            ids[i] = items.tokenOfOwnerByIndex(owner, offset + i);
        }
    }

    function itemsDetailsOf(address owner, uint offset, uint limit)
        public
        view
        returns (
            uint256[] memory ids,
            uint256[] memory types
        ) {
        
        require(owner != address(0), "Addr is zero");
        uint256 count = items.balanceOf(owner);

        if (offset > count) {
            offset = count;
        }

        uint resultLen = count - offset;
        resultLen = limit > 0 && limit < resultLen ? limit : resultLen;

        ids = new uint256[](resultLen);
        types = new uint256[](resultLen);

        for (uint256 i = 0; i < resultLen; i++) {
            uint256 itemId = items.tokenOfOwnerByIndex(owner, offset + i);
            uint256 itemType = items.types(itemId);
            ids[i] = itemId;
            types[i] = itemType;
        }
    }

    function getItems(uint offset, uint limit) public view returns (uint256[] memory ids, address[] memory owners, uint256[] memory types) {
        
        uint256 count = items.totalSupply();
        
        if (offset > count) {
            offset = count;
        }

        uint resultLen = count - offset;
        resultLen = (limit > 0 && limit < resultLen) ? limit : resultLen;
        
        ids = new uint256[](resultLen);
        owners = new address[](resultLen);
        types = new uint256[](resultLen);

        for (uint256 i = 0; i < resultLen; i++) {
            ids[i] = items.tokenByIndex(offset + i);
            owners[i] = items.ownerOf(ids[i]);
            types[i] = items.types(ids[i]);
        }
    }

    // V3
    function setMinter(address to, bool canMint_) public onlyOwner {
        require(to != address(0), "Addr is zero");
        minters[to] = canMint_;
    }

    function setCanMint(bool canMint_) public onlyOwner {
        canMint = canMint_;
    }

    function mintBulkWithTypes(address[] calldata to, uint256[] calldata itemTypes) public {
        require(canMint, "Mint disabled");
        require(minters[msg.sender], "Not minter");
        require(to.length == itemTypes.length, "Inputs must be same length");
        require(to.length > 0, "Input is empty");

        for (uint256 i = 0; i < to.length; i++) {
            items.mint(to[i], itemTypes[i]);
        }
    }
    //---

    // V4
    function setBurner(address to, bool canBurn_) public onlyOwner {
        require(to != address(0), "Addr is zero");
        burners[to] = canBurn_;
    }

    function setCanBurn(bool canBurn_) public onlyOwner {
        canBurn = canBurn_;
    }

    function burnBulk(uint256[] calldata itemIds) public {
        require(canBurn, "Burn disabled");
        require(burners[msg.sender], "Not burner");
        require(itemIds.length > 0, "Input is empty");

        for (uint256 i = 0; i < itemIds.length; i++) {
            items.burn(itemIds[i]);
        }
    }
    //---

}
