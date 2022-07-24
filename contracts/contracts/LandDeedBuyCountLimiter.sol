// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./IBuyCountLimiter.sol";

contract LandDeedBuyCountLimiter is Proxy, Ownable, IBuyCountLimiter {
    // Address of possible extension-contract.
    // Extension-contract must inherit this contract and do not modify existing data layout, only extend it.
    address public extension;

    mapping(address => bool) public updaters;

    struct BuyerDetails {
        uint boughtCount;
        uint buyLimit;
    }

    mapping(address => BuyerDetails) public details;
    // For Enumerability
    address[] public buyers;

    constructor() {
        setUpdater(msg.sender, true);
    }

    function _implementation() internal view override returns (address) {
        return extension;
    }

    function setExtension(address extension_) public onlyOwner {
        require(extension_ != address(0), "Extension is zero");
        extension = extension_;
    }

    function addBuyersBulk(address[] calldata buyers_, uint buyLimit) public onlyOwner {
        require(buyers_.length > 0, "Input is empty");

        for (uint i = 0; i < buyers_.length; ++i) {
            addBuyer(buyers_[i], 0, buyLimit);
        }
    }

    function removeBuyers(uint offset, uint limit, bool deleteKeys) public onlyOwner {
        uint256 count = buyers.length;
        
        if (offset > count) {
            offset = count;
        }

        uint resultLen = count - offset;
        resultLen = (limit > 0 && limit < resultLen) ? limit : resultLen;

        for (uint256 i = 0; i < resultLen; i++) {
            address buyer = buyers[offset + i];
            delete details[buyer];
        }

        if (deleteKeys) {
            delete buyers;
        }
    }

    function getBuyers(uint offset, uint limit) public view returns (address[] memory buyers_) {
        uint256 count = buyers.length;
        
        if (offset > count) {
            offset = count;
        }

        uint resultLen = count - offset;
        resultLen = (limit > 0 && limit < resultLen) ? limit : resultLen;
        
        buyers_ = new address[](resultLen);

        for (uint256 i = 0; i < resultLen; i++) {
            buyers_[i] = buyers[offset + i];
        }
    }


    function addBuyer(address buyer, uint boughtCount, uint buyLimit) public onlyOwner {
        require(buyLimit > 0, "BuyLimit is zero");
        require(!buyerExists(buyer), "Buyer already exists");
        
        details[buyer].boughtCount = boughtCount;
        details[buyer].buyLimit = buyLimit;
        
        buyers.push(buyer);
    }

    function setBuyerDetails(address buyer, uint boughtCount, uint buyLimit) public onlyOwner {
        require(buyLimit > 0, "BuyLimit is zero");
        require(buyerExists(buyer), "Buyer not found");
        
        details[buyer].boughtCount = boughtCount;
        details[buyer].buyLimit = buyLimit;
    }

    function setBuyerLimit(address buyer, uint buyLimit) public onlyOwner {
        require(buyLimit > 0, "BuyLimit is zero");
        require(buyerExists(buyer), "Buyer not found");
        
        details[buyer].buyLimit = buyLimit;
    }

    function buyerExists(address buyer) public view returns(bool) {
        require(buyer != address(0), "Buyer is zero");
        return details[buyer].buyLimit > 0;
    }

    function buyersCount() public view returns (uint256) {
        return buyers.length;
    }

    function setUpdater(address updater, bool canUpdate) public onlyOwner {
        require(updater != address(0), "Updater is zero");
        updaters[updater] = canUpdate;
    }

    function buyerCountLeft(address buyer) public view returns (int256) {
        require(buyer != address(0), "Buyer is zero");

        if (buyerExists(buyer)) {
            return int256(details[buyer].buyLimit) - int256(details[buyer].boughtCount);
        }
        else {
            return -1;
        }
    }

    // region IBuyCountLimiter
    function canBuy(address buyer, uint256 count) public override view returns (bool) {
        require(buyer != address(0), "Buyer is zero");
        return details[buyer].boughtCount + count <= details[buyer].buyLimit;
    }

    function addToBoughtCount(address buyer, uint256 count) public override {
        require(buyer != address(0), "Buyer is zero");
        require(updaters[msg.sender], "Not updater");

        BuyerDetails storage detail = details[buyer];
        require(detail.boughtCount + count <= detail.buyLimit, "Buyer limit reached");

        detail.boughtCount += count;
    }
    // endregion
}
