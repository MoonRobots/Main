// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./Enums.sol";

struct EggDetails {
    uint rarity;
    uint color;
    uint level;
    uint256 lastPayout;
    uint256 lastColorPayout;
    uint256 oilLevel;
    uint256 reward; // Not claimed reward, can be set during egg upgrade
    uint256 colorReward; // Not claimed reward, can be set during EggColorProfit.claim or egg upgrade
}

contract Eggs is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string private _eggBaseURI;
    uint256 public mintedCounter;
    uint256 public totalSupplyLimit = 10000;

    address public upgraderAddress;
    address public eggProfitAddress;
    address public eggColorProfitAddress;
    address public hatcheryAddress;

    bool public canOwnerBurn;
    uint256 public startPayoutDate;
    mapping(address => bool) public minters;
    mapping(address => bool) public burners;

    mapping(uint256 => EggDetails) public eggDetails;

    constructor (uint256 startPayoutDate_) ERC721("Moon Robots Egg", "EGG") {
        _eggBaseURI = "https://api.moonrobots.one/eggs";
        startPayoutDate = startPayoutDate_;
        //startPayoutDate = 1651251600; //Fri Apr 29 2022 17:00:00 GMT+0000
    }

    /**
     * @dev See {ERC721-_baseURI}.
     */
    function _baseURI() internal view override returns (string memory) {
        return _eggBaseURI;
    }

    function baseURI() public view returns (string memory) {
        return _baseURI();
    }

    function setBaseURI(string memory baseURI_) public {
        _checkOwner();
        _eggBaseURI = baseURI_;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Not exist");

        string memory uri = _baseURI();
        EggDetails storage details = eggDetails[tokenId];
        return bytes(uri).length > 0 ? string(abi.encodePacked(uri, 
            "?id=", tokenId.toString(), 
            "&level=", details.level.toString(),
            "&color=", details.color.toString(),
            "&rarity=", details.rarity.toString())) : "";
    }

    function _checkOwner() private view {
        require(owner() == msg.sender, "Not owner");
    }

    function mint(address to, uint rarity, uint color) public virtual returns (uint256 tokenId) {
        require(minters[msg.sender], "Not minter");
        require(mintedCounter < totalSupplyLimit, "Limit Reached");

        uint256 eggId = mintedCounter;

        _mint(to, eggId);

        eggDetails[eggId].rarity = rarity;
        eggDetails[eggId].color = color;
        eggDetails[eggId].level = 0;
        eggDetails[eggId].oilLevel = 0 ether;
        eggDetails[eggId].lastPayout = startPayoutDate;
        eggDetails[eggId].lastColorPayout = startPayoutDate;
        eggDetails[eggId].reward = 0 ether;
        eggDetails[eggId].colorReward = 0 ether;

        mintedCounter++;
        return eggId;
    }

    function mint(address to, EggDetails calldata eggDetails_) public virtual returns (uint256 tokenId) {
        require(minters[msg.sender], "Not minter");
        require(mintedCounter < totalSupplyLimit, "Limit Reached");

        uint256 eggId = mintedCounter;

        _mint(to, eggId);

        eggDetails[eggId] = eggDetails_;

        mintedCounter++;
        return eggId;
    }

    function setMinter(address _minterAddress, bool _canMint) public {
        _checkOwner();
        minters[_minterAddress] = _canMint;
    }

    function burn(uint256 eggId) public {
        require(burners[msg.sender] || (canOwnerBurn && _isApprovedOrOwner(msg.sender, eggId)), "Not burner");
        
        _burn(eggId);
    }

    function setBurner(address to, bool canBurn) public {
        _checkOwner();
        require(to != address(0), "Invalid addr");
        burners[to] = canBurn;
    }
    
    function setCanOwnerBurn(bool canOwnerBurn_) public {
        _checkOwner();
        canOwnerBurn = canOwnerBurn_;
    }

    function setTotalSupplyLimit(uint256 newLimit) public {
        _checkOwner();
        require(newLimit > totalSupplyLimit, "Invalid limit"); // Allow only grow
        totalSupplyLimit = newLimit;
    }

    function setHatcheryAddress(address harcheryAddress) public {
        _checkOwner();
        hatcheryAddress = harcheryAddress;
    }

    function setHatched(uint256 eggId) external {
        require(hatcheryAddress != address(0), "Hatchery invalid");
        require(hatcheryAddress == msg.sender, "Not Hatchery");
        require(ERC721.ownerOf(eggId) != address(0), "Egg not owned");
        
        _burn(eggId);
    }

    function setUpgraderAddress(address upgraderAddress_) public {
        _checkOwner();
        upgraderAddress = upgraderAddress_;
    }

    function setEggProfitAddress(address eggProfitAddress_) public {
        _checkOwner();
        eggProfitAddress = eggProfitAddress_;
    }

    function setEggColorProfitAddress(address eggColorProfitAddress_) public {
        _checkOwner();
        eggColorProfitAddress = eggColorProfitAddress_;
    }

    function setEggLevel(uint256 eggId, uint256 _level) public {
        require(upgraderAddress != address(0), "Upgrade invalid");
        require(msg.sender == upgraderAddress 
                || msg.sender == owner(), // For Testing only
                "Not allowed");
        eggDetails[eggId].level = _level;
    }

    function setOilLevel(uint256 eggId, uint256 level) public {
        require(upgraderAddress != address(0), "Upgrade invalid");
        require(msg.sender == upgraderAddress
            || msg.sender == owner(), // For Testing only
            "Not allowed");
        eggDetails[eggId].oilLevel = level;
    }

    function isTokenOwner(uint256 eggId, address _owner) public view returns (bool) {
        address owner = ERC721.ownerOf(eggId);
        return owner == _owner;
    }

    function setStartPayoutDate(uint256 startPayoutDate_) public {
        _checkOwner();
        startPayoutDate = startPayoutDate_;
    }

    function getEggLastPayoutDate(uint256 eggId) public view returns (uint256) {
      return eggDetails[eggId].lastPayout;
    }

    function getEggLastColorPayoutDate(uint256 eggId) public view returns (uint256) {
      return eggDetails[eggId].lastColorPayout;
    }

    function setEggLastPayoutDate(uint256 eggId, uint256 timestamp) public {
        require(eggProfitAddress != address(0), "Profit invalid");
        require(msg.sender == eggProfitAddress
            || msg.sender == owner(), // For testing
            "Not allowed");

        eggDetails[eggId].lastPayout = timestamp;
    }
    
    function setEggLastColorPayoutDate(uint256 eggId) public {
        require(eggColorProfitAddress != address(0), "ColorProfit invalid");
        require(msg.sender == eggColorProfitAddress, "Not allowed");
        eggDetails[eggId].lastColorPayout = block.timestamp;
    }

    function getEggRarity(uint256 eggId) public view returns (uint) {
      return eggDetails[eggId].rarity;
    }

    function getEggColor(uint256 eggId) public view returns (uint) {
      return eggDetails[eggId].color;
    }

    function getEggLevel(uint256 eggId) public view returns (uint) {
      return eggDetails[eggId].level;
    }

    function getEggOilLevel(uint256 eggId) public view returns (uint256) {
      return eggDetails[eggId].oilLevel;
    }

    function getEggReward(uint256 eggId) public view returns (uint256) {
      return eggDetails[eggId].reward;
    }

    function setEggReward(uint256 eggId, uint256 reward) public {
        require(eggProfitAddress != address(0), "Profit invalid");
        require(upgraderAddress != address(0), "Upgrader invalid");

        require(msg.sender == eggProfitAddress
                || msg.sender == upgraderAddress,
                "Not allowed");

        eggDetails[eggId].reward = reward;
    }

    function getEggColorReward(uint256 eggId) public view returns (uint256) {
      return eggDetails[eggId].colorReward;
    }

    function setEggColorReward(uint256 eggId, uint256 reward) public {
        require(eggColorProfitAddress != address(0), "ColorProfit invalid");
        require(upgraderAddress != address(0), "Upgrader invalid");

        require(msg.sender == eggColorProfitAddress
                || msg.sender == upgraderAddress
                || msg.sender == owner(), // For Testing only
                "Not allowed");

        eggDetails[eggId].colorReward = reward;
    }
}
