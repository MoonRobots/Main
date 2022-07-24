// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./IMintable.sol";

contract Items is ERC721Enumerable, Proxy, Ownable, IMintableWithType {
    using Strings for uint256;

    // Address of possible extension-contract.
    // Extension-contract must inherit this contract and do not modify existing data layout, only extend it.
    address public extension;
    uint256 public counter;
    
    string public baseURI;
    bool public canOwnerBurn;

    mapping(address => bool) public minters;
    mapping(address => bool) public burners;
    mapping(uint256 => uint256) public types;

    constructor () ERC721("Moon Robots Items", "MRITEM") {
        baseURI = "https://api.moonrobots.one/items";
        setMinter(msg.sender, true);
    }

    function setBaseURI(string memory baseURI_) public onlyOwner {
        baseURI = baseURI_;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Not exist");

        string memory uri = _baseURI();
        uint256 tokenType = types[tokenId];
        return bytes(uri).length > 0 ? string(abi.encodePacked(uri, "?id=", tokenId.toString(), "&type=", tokenType.toString())) : "";
    }

    function _implementation() internal view override returns (address) {
        return extension;
    }

    function setExtension(address extension_) public onlyOwner {
        require(extension_ != address(0), "Extension is zero");
        extension = extension_;
    }
    
    function mint(address to, uint256 itemType) public override returns (uint256 tokenId) {
        require(to != address(0), "Addr is zero");
        require(minters[msg.sender], "Not minter");
        
        uint256 itemId = counter;

        _mint(to, itemId);
        types[itemId] = itemType;

        ++counter;
        return itemId;
    }

    function mintBulk(address to, uint256 itemType, uint256 count) public {
        for (uint256 i = 0; i < count; i++) {
            mint(to, itemType);
        }
    }

    function approveBulk(address to, uint256[] calldata itemIds) public {
        require(itemIds.length > 0, "itemsIds is empty");

        for (uint256 i = 0; i < itemIds.length; i++) {
            approve(to, itemIds[i]);
        }
    }

    function mintBulk(address[] calldata to, uint256 itemType) public {
        require(minters[msg.sender], "Not minter");
        require(to.length > 0, "To is empty");

        for (uint256 i = 0; i < to.length; i++) {
            mint(to[i], itemType);
        }
    }

    function setMinter(address to, bool canMint) public onlyOwner {
        require(to != address(0), "Invalid addr");
        minters[to] = canMint;
    }

    function burn(uint256 itemId) public {
        require(burners[msg.sender] || (canOwnerBurn && _isApprovedOrOwner(msg.sender, itemId)), "Not burner");
        
        _burn(itemId);
    }

    function setBurner(address to, bool canBurn) public onlyOwner {
        require(to != address(0), "Invalid addr");
        burners[to] = canBurn;
    }
    
    function setCanOwnerBurn(bool canOwnerBurn_) public onlyOwner {
        canOwnerBurn = canOwnerBurn_;
    }

    function balanceOfType(address owner, uint256 itemType) public view returns (uint256 count) {
        require(owner != address(0), "Owner is zero");

        uint256 n = balanceOf(owner);
        count = 0;
        for (uint256 i = 0; i < n; i++) {
            if (types[tokenOfOwnerByIndex(owner, i)] == itemType) {
                ++count;
            }
        }
    }
}