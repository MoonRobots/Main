// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Items.sol";
import "./Random.sol";
import "./Enums.sol";

// Must be minter of Items
contract ExpeditionItemSeller is Proxy, Ownable {
    // Address of possible extension-contract.
    // Extension-contract must inherit this contract and do not modify existing data layout, only extend it.
    address public extension;
    Items public items;
    IERC20 public oil;
    IERC20 public starDust;
    Random public random;
    address public profitOilAddress;
    address public profitStardustAddress;
    bool public isContractActive = true;

    struct BundleDetails {
        uint256 itemType;
        uint count;
        uint256 priceOil;
        uint256 priceStardust;
    }

    struct LootBoxDetails {
        bool isEnabled;
        uint256 priceOil;
        uint256[] itemTypes;
        uint256[] weights;
    }

    mapping (uint => BundleDetails) public bundles;
    mapping (uint => LootBoxDetails) public lootBoxes;
    mapping (uint => uint256) public soldInLootBoxesCounts;
    mapping (uint => uint256) public soldCounts;
    mapping (uint => uint256) public maxSellCounts;

    event ItemMinted(address indexed to, uint256 indexed itemType, uint256 indexed itemId);

    constructor(Items items_, IERC20 oil_, IERC20 starDust_, Random random_, address profitOilAddress_, address profitStardustAddress_) {
        require(address(oil_) != address(0), "Oil is zero");
        require(address(starDust_) != address(0), "SD is zero");

        setItems(items_);
        setRandom(random_);
        oil = oil_;
        starDust = starDust_;

        setProfitOilAddress(profitOilAddress_);
        setProfitStardustAddress(profitStardustAddress_);

        bundles[100] = BundleDetails({itemType: ITEM_EXP_TRIPOD,    priceOil:   500 ether, priceStardust:     0,       count: 1});
        bundles[110] = BundleDetails({itemType: ITEM_EXP_DRONE,     priceOil:  1000 ether, priceStardust:     0,       count: 1});
        bundles[140] = BundleDetails({itemType: ITEM_EXP_SCOUT,     priceOil:  1500 ether, priceStardust:  2500 ether, count: 1});
        bundles[120] = BundleDetails({itemType: ITEM_EXP_ROVER,     priceOil:  2500 ether, priceStardust:  5000 ether, count: 1});
        bundles[130] = BundleDetails({itemType: ITEM_EXP_SATELLITE, priceOil: 10000 ether, priceStardust:     0,       count: 1});

        lootBoxes[1000].isEnabled = true;
        lootBoxes[1000].priceOil = 150 ether;
        lootBoxes[1000].itemTypes.push(ITEM_EXP_PIECE_TRIPOD);
        lootBoxes[1000].itemTypes.push(ITEM_EXP_PIECE_DRONE);
        lootBoxes[1000].itemTypes.push(ITEM_EXP_PIECE_SCOUT);
        lootBoxes[1000].itemTypes.push(ITEM_EXP_PIECE_ROVER);
        lootBoxes[1000].itemTypes.push(ITEM_EXP_PIECE_SATELLITE);

        lootBoxes[1000].weights.push(60);
        lootBoxes[1000].weights.push(23);
        lootBoxes[1000].weights.push(10);
        lootBoxes[1000].weights.push(5);
        lootBoxes[1000].weights.push(2);
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

    function setRandom(Random random_) public onlyOwner {
        require(address(random_) != address(0), "Random is zero");
        random = random_;
    }

    function setProfitStardustAddress(address newProfitStardustAddress) public onlyOwner {
        require(address(newProfitStardustAddress) != address(0), "ProfitStardust is zero");
        profitStardustAddress = newProfitStardustAddress;
    }

    function setProfitOilAddress(address newProfitOilAddress) public onlyOwner {
        require(address(newProfitOilAddress) != address(0), "ProfitOil is zero");
        profitOilAddress = newProfitOilAddress;
    }

    function setBundleDetails(uint bundleId, uint256 itemType, uint count, uint256 priceOil, uint256 priceStardust) public onlyOwner {
        bundles[bundleId] = BundleDetails({itemType: itemType, priceOil: priceOil, priceStardust: priceStardust, count: count});
    }

    function setLootBoxDetails(uint lootBoxId, bool isEnabled, uint256[] memory itemTypes, uint256[] memory weights, uint256 priceOil) public onlyOwner {
        require(itemTypes.length > 0, "itemTypes is empty");
        require(itemTypes.length == weights.length, "weights must be same size");

        lootBoxes[lootBoxId].isEnabled = isEnabled;
        lootBoxes[lootBoxId].priceOil = priceOil;

        delete lootBoxes[lootBoxId].itemTypes;
        for (uint256 i = 0; i < itemTypes.length; i++) {
            lootBoxes[lootBoxId].itemTypes.push(itemTypes[i]);
        }

        delete lootBoxes[lootBoxId].weights;
        for (uint256 i = 0; i < weights.length; i++) {
            lootBoxes[lootBoxId].weights.push(weights[i]);
        }
    }

    function setMaxSellCount(uint256 itemType, uint256 maxCount) public onlyOwner {
        maxSellCounts[itemType] = maxCount;
    }

    function setSoldCount(uint256 itemType, uint256 soldCount) public onlyOwner {
        soldCounts[itemType] = soldCount;
    }

    function setSoldInLootBoxesCount(uint256 itemType, uint256 soldCount) public onlyOwner {
        soldInLootBoxesCounts[itemType] = soldCount;
    }

    function getLootBoxItemTypes(uint lootBoxId) public view returns (uint256[] memory itemTypes, uint256[] memory weights) {
        return (lootBoxes[lootBoxId].itemTypes, lootBoxes[lootBoxId].weights);
    }

    function buyItemBundles(uint bundleId, uint count) external returns (uint256[] memory itemIds) {
        require(isContractActive, "Not active");
        
        BundleDetails storage details = bundles[bundleId];
        require(details.count > 0, "Invalid bundle");
        
        uint256 totalCount = count * details.count;
        uint256 maxSellCount = maxSellCounts[details.itemType];
        if (maxSellCount > 0) {
            require(soldCounts[details.itemType] + totalCount <= maxSellCount, "Limit reached");
        }
        
        
        if (details.priceOil > 0) {
            oil.transferFrom(msg.sender, profitOilAddress, details.priceOil * count);
        }

        if (details.priceStardust > 0) {
            starDust.transferFrom(msg.sender, profitStardustAddress, details.priceStardust * count);
        }

        soldCounts[details.itemType] += totalCount;

        itemIds = new uint256[](totalCount);
        for (uint i = 0; i < itemIds.length; i++) {
            itemIds[i] = items.mint(msg.sender, details.itemType);

            emit ItemMinted(msg.sender, details.itemType, itemIds[i]);
        }
    }

    function buyItemLootBoxes(uint lootBoxId, uint count) external returns  (uint256[] memory itemIds) {
        require(isContractActive, "Not active");

        LootBoxDetails storage details = lootBoxes[lootBoxId];
        require(details.isEnabled, "LootBox disabled");
        
        if (details.priceOil > 0) {
            oil.transferFrom(msg.sender, profitOilAddress, details.priceOil * count);
        }

        itemIds = new uint256[](count);
        for (uint i = 0; i < count; i++) {
            uint256 rnd = random.random();
            uint index = randomChoice(rnd, details.weights);
            uint256 itemType = details.itemTypes[index];

            itemIds[i] = items.mint(msg.sender, itemType);
    
            soldInLootBoxesCounts[itemType] += 1;

            emit ItemMinted(msg.sender, itemType, itemIds[i]);
        }
    }
}

