// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Items.sol";
import "./IMintable.sol";
import "./Enums.sol";
import "./ILandDeedParametersProvider.sol";
import "./IBuyCountLimiter.sol";

contract ItemSeller is Ownable {
    Items public items;
    IERC20 public oil;
    IERC20 public starDust;
    ILandDeedParametersProvider public landDeedParameters;
    IBuyCountLimiter public landDeedBuyCountLimiter;

    address payable public profitAddress;
    address public profitOilAddress;
    address public profitStardustAddress;
    bool public isContractActive = true;
    uint256 public landDeedSellLimit = 707;
    uint256 public landDeedSoldCount;
    
    struct BundleDetails {
        uint256 itemType;
        uint count;
        uint256 price;
        address payable profitAddress;
    }

    struct LandDeedBundleDetails {
        uint256 price;
        uint256 priceOil;
        uint256 priceStardust;
        uint256 voucherType;
        uint priceVouchers;
        uint count;
        uint[] rarityWeights;
        bool checkUserBuyLimit;
    }

    mapping (uint => BundleDetails) public bundles;
    mapping (uint => LandDeedBundleDetails) public landDeedBundles;

    event ContractActivityChanged(bool indexed newActiveStatus, address indexed caller);
    event ProfitAddressChanged(address indexed oldProfitAddress, address indexed newProfitAddress, address indexed caller);
    event ProfitOilAddressChanged(address indexed oldProfitAddress, address indexed newProfitAddress, address indexed caller);
    event ProfitStardustAddressChanged(address indexed oldProfitAddress, address indexed newProfitAddress, address indexed caller);
    event ItemMinted(address indexed to, uint256 indexed itemType, uint256 indexed itemId);
    
    constructor(Items items_, IERC20 oil_, IERC20 starDust_, address payable profitAddress_, address profitOilAddress_, address profitStardustAddress_) {
        require(address(oil_) != address(0), "Oil is zero");
        require(address(starDust_) != address(0), "SD is zero");

        setItems(items_);       
        oil = oil_;
        starDust = starDust_;

        setProfitAddress(profitAddress_);
        setProfitOilAddress(profitOilAddress_);
        setProfitStardustAddress(profitStardustAddress_);

        bundles[1].itemType = ITEM_REPAIR_KIT_VOUCHER;
        bundles[1].count = 1;
        bundles[1].price = 490 ether;
        // https://unchain.fund/#donate
        bundles[1].profitAddress = payable(0x50239f0D06636a4Ca97Fb2Ad7125fDDa63E692A4);

        setLandDeedBundleDetails(100, 0, 7000 ether, 0, 0, 0, 1, [uint(722), 232, 38, 8], true);
        setLandDeedBundleDetails(101, 0, 0, 0, ITEM_LAND_DEED_VOUCHER, 1, 1, [uint(722), 232, 38, 8], false);

        setLandDeedBundleDetails(110, 0, 7000 ether, 5000 ether, 0, 0, 1, [uint(630), 300, 56, 14], true);
        setLandDeedBundleDetails(111, 0, 0, 5000 ether, ITEM_LAND_DEED_VOUCHER, 1, 1, [uint(630), 300, 56, 14], false);

        setLandDeedBundleDetails(120, 0, 7000 ether, 20000 ether, 0, 0, 1, [uint(498), 400, 80, 22], true);
        setLandDeedBundleDetails(121, 0, 0, 20000 ether, ITEM_LAND_DEED_VOUCHER, 1, 1, [uint(498), 400, 80, 22], false);
    }

    function setContractActive(bool isContractActive_) public onlyOwner {
        emit ContractActivityChanged(isContractActive_, msg.sender);
        isContractActive = isContractActive_;
    }

    function setLandDeedSellLimit(uint256 limit) public onlyOwner {
        landDeedSellLimit = limit;
    }

    function setBundleDetails(uint bundleId, uint256 itemType, uint count, uint256 price, address payable profitAddress_) public onlyOwner {
        bundles[bundleId].itemType = itemType;
        bundles[bundleId].count = count;
        bundles[bundleId].price = price;
        bundles[bundleId].profitAddress = profitAddress_;
    }
         
    function setLandDeedBundleDetails(
        uint bundleId, 
        uint256 price, 
        uint256 priceOil, 
        uint256 priceStardust, 
        uint256 voucherType, 
        uint priceVouchers, 
        uint count, uint[4] memory rarityWeights, 
        bool checkUserBuyLimit) public onlyOwner {
        
        landDeedBundles[bundleId].price = price; 
        landDeedBundles[bundleId].priceOil = priceOil; 
        landDeedBundles[bundleId].priceStardust = priceStardust; 
        landDeedBundles[bundleId].voucherType = voucherType; 
        landDeedBundles[bundleId].priceVouchers = priceVouchers; 
        landDeedBundles[bundleId].count = count; 
        landDeedBundles[bundleId].checkUserBuyLimit = checkUserBuyLimit;
        
        delete landDeedBundles[bundleId].rarityWeights;
        for (uint i = 0; i < rarityWeights.length; i++) {
            landDeedBundles[bundleId].rarityWeights.push(rarityWeights[i]);
        }
    }

    function setItems(Items items_) public onlyOwner {
        require(address(items_) != address(0), "Items is zero");
        items = items_;
    }

    function setLandDeedBuyCountLimiter(IBuyCountLimiter buyCountLimiter_) public onlyOwner {
        require(address(buyCountLimiter_) != address(0), "BuyLimiter is zero");
        landDeedBuyCountLimiter = buyCountLimiter_;
    }

    function setProfitAddress(address payable newProfitAddress) public onlyOwner {
        require(address(newProfitAddress) != address(0), "Profit is zero");
        emit ProfitAddressChanged(profitAddress, newProfitAddress, msg.sender);
        profitAddress = newProfitAddress;
    }

    function setProfitStardustAddress(address newProfitStardustAddress) public onlyOwner {
        require(address(newProfitStardustAddress) != address(0), "ProfitStardust is zero");
        emit ProfitStardustAddressChanged(profitStardustAddress, newProfitStardustAddress, msg.sender);
        profitStardustAddress = newProfitStardustAddress;
    }

    function setProfitOilAddress(address newProfitOilAddress) public onlyOwner {
        require(address(newProfitOilAddress) != address(0), "ProfitOil is zero");
        emit ProfitOilAddressChanged(profitOilAddress, newProfitOilAddress, msg.sender);
        profitOilAddress = newProfitOilAddress;
    }

    function setLandDeedParameters(ILandDeedParametersProvider landDeedParameters_) public onlyOwner {
        require(address(landDeedParameters_) != address(0), "LD Params is zero");
        landDeedParameters = landDeedParameters_;
    }

    function buyItemBundles(uint bundleId, uint count) external payable returns (uint256[] memory itemIds) {
        require(isContractActive, "Not active");
        
        BundleDetails storage details = bundles[bundleId];
        require(details.count > 0, "Invalid bundle");
        require(msg.value >= count * details.price, "Not enough $ONE");
        
        address payable profitAddress_ = details.profitAddress == address(0) ? profitAddress : details.profitAddress;
        require(profitAddress_ != address(0), "Profit is zero");
        
        profitAddress_.transfer(msg.value);
        
        uint256 totalItemsCount = count * details.count;
        itemIds = new uint256[](totalItemsCount);
        for (uint i = 0; i < itemIds.length; i++) {
            itemIds[i] = items.mint(msg.sender, details.itemType);

            emit ItemMinted(msg.sender, details.itemType, itemIds[i]);
        }
    }   

    function buyLandDeedBundles(uint bundleId, uint count, uint256[] calldata voucherIds) external payable returns (uint256[] memory itemIds) {
        require(isContractActive, "Not active");
        require(address(landDeedParameters) != address(0), "LD Params not set");
        require(count > 0, "Count is zero");
        
        LandDeedBundleDetails storage details = landDeedBundles[bundleId];
        require(details.count > 0, "Invalid LandDeed bundle");

        uint256 totalItemsCount = count * details.count;                
        landDeedSoldCount += totalItemsCount;
        require(landDeedSoldCount <= landDeedSellLimit, "Limit reached");

        if (details.checkUserBuyLimit) {
            require(address(landDeedBuyCountLimiter) != address(0), "BuyLimiter not set");
            require(landDeedBuyCountLimiter.canBuy(msg.sender, totalItemsCount), "User buy limit");
            landDeedBuyCountLimiter.addToBoughtCount(msg.sender, totalItemsCount);
        }
        
        if (details.price > 0) {
            require(msg.value >= count * details.price, "Not enough $ONE");
            profitAddress.transfer(msg.value);
        }

        if (details.priceOil > 0) {
            oil.transferFrom(msg.sender, profitOilAddress, details.priceOil * count);
        }

        if (details.priceStardust > 0) {
            starDust.transferFrom(msg.sender, profitStardustAddress, details.priceStardust * count);
        }

        if (details.priceVouchers > 0) {
            require(details.voucherType > 0, "Voucher type not set");

            uint requiredVouchersCount = details.priceVouchers * count;
            require(voucherIds.length >= requiredVouchersCount, "Not enough vouchers");

            for (uint256 i = 0; i < requiredVouchersCount; i++) {
                uint256 voucherId = voucherIds[i];
                require(items.ownerOf(voucherId) == address(msg.sender), "Not voucher owner");
                require(items.types(voucherId) == details.voucherType, "Invalid voucher type");

                items.burn(voucherIds[i]);
            }
        }

        itemIds = new uint256[](totalItemsCount);
        for (uint i = 0; i < itemIds.length; i++) {
            uint rarity = landDeedParameters.getLandDeedParameters(details.rarityWeights);
            uint256 itemType = getLandDeedTypeWithRarity(rarity);

            itemIds[i] = items.mint(msg.sender, itemType);

            emit ItemMinted(msg.sender, itemType, itemIds[i]);
        }
    }
}
