// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Enums.sol";
import "./Eggs.sol";
import "./Whitelist.sol";
import "./Items.sol";
import "./IEggParametersProvider.sol";
import "./IMintable.sol";

contract EggSeller is Ownable {
    Eggs private _eggs;
    Whitelist private  _whitelist;
    IMintableWithAmount private _starDust;
    IMintableWithType private _items;

    address payable public profitAddress;
    address public parametersAddress;

    bool public isContractActive = true;
    // Is whitelist (or free-mint) required to by any egg bundle
    bool public isWhitelistRequired = false;

    // Eggs count need to be bought in a single call to get a single LandDeedVoucher reward
    uint public landDeedRewardMinEggs = 20;
    // LandDeedVouchers given if user buys at least landDeedRewardMinEggs eggs
    uint public landDeedRewardCount = 2;
    // How many eggs we can sell without using FreeMints
    uint public publicSaleEggsMaxCount = 2948;
    uint public publicSaleEggsSoldCount;

    struct WhitelistTypeDetails {
        uint allowedCount;
        uint discount;
        uint256 starDustCount;
    }

    struct BundleDetails {
        uint eggsCount;
        uint256 price;
    }

    struct FreeMintDetails {
        uint eggsCount;
    }

    mapping (uint => WhitelistTypeDetails) public whitelistTypeDetails;
    mapping (uint => BundleDetails) public bundleDetails;
    mapping (uint256 => FreeMintDetails) public freeMintDetails;

    event ContractActivityChanged(bool indexed newActiveStatus, address indexed caller);
    event WhitelistRequiredChanged(bool indexed newIsRequired, address indexed caller);
    event ProfitAddressChanged(address indexed oldProfitAddress, address indexed newProfitAddress, address indexed caller);
    event ParametersAddressChanged(address indexed oldParametersAddress, address indexed newParametersAddress, address indexed caller);

    constructor(address payable profitAddress_, Eggs eggs, Whitelist whitelist, IMintableWithAmount starDust, IMintableWithType items) {
        require(profitAddress_ != address(0), "ProfitAddr is zero");
        require(address(eggs) != address(0), "EggsAddr is zero");
        require(address(whitelist) != address(0), "WLAddr is zero");
        require(address(starDust) != address(0), "StartdustAddr is zero");
        require(address(items) != address(0), "ItemsAddr is zero");

        profitAddress = profitAddress_;
        _whitelist = whitelist;
        _eggs = eggs;
        _starDust = starDust;
        _items = items;

        freeMintDetails[100].eggsCount = 1;
        freeMintDetails[101].eggsCount = 3;
        freeMintDetails[102].eggsCount = 5;
        freeMintDetails[103].eggsCount = 20;

        bundleDetails[100].eggsCount = 1;
        bundleDetails[100].price = 990 ether;

        bundleDetails[101].eggsCount = 3;
        bundleDetails[101].price = 2850 ether;

        bundleDetails[102].eggsCount = 5;
        bundleDetails[102].price = 4700 ether;

        bundleDetails[103].eggsCount = 20;
        bundleDetails[103].price = 18000 ether;

        whitelistTypeDetails[1].allowedCount = 5;
        whitelistTypeDetails[1].discount = 5;
        whitelistTypeDetails[1].starDustCount = 500 ether;

        whitelistTypeDetails[2].allowedCount = 3;
        whitelistTypeDetails[2].discount = 5;
        whitelistTypeDetails[2].starDustCount = 300 ether;

        whitelistTypeDetails[3].allowedCount = 3;
        whitelistTypeDetails[3].discount = 10;
        whitelistTypeDetails[3].starDustCount = 600 ether;

        whitelistTypeDetails[4].allowedCount = 1;
        whitelistTypeDetails[4].discount = 5;
        whitelistTypeDetails[4].starDustCount = 100 ether;
    }

    function setPublicSaleEggsMaxCount(uint256 maxCount) public onlyOwner {
        publicSaleEggsMaxCount = maxCount;    
    }

    function setWhitelistTypeDetails(uint whitelistType, uint allowedCount, uint discount, uint256 starDustCount) public onlyOwner {
        require(discount >= 0 && discount < 100, "Invalid whitelist discount");

        whitelistTypeDetails[whitelistType].allowedCount = allowedCount;
        whitelistTypeDetails[whitelistType].discount = discount;
        whitelistTypeDetails[whitelistType].starDustCount = starDustCount;
    }

    function setBundleDetails(uint bundleId, uint eggsCount, uint price) public onlyOwner {
        require(price > 0, "Invalid price");

        bundleDetails[bundleId].eggsCount = eggsCount;
        bundleDetails[bundleId].price = price;
    }

    function getFreeMintDetails(uint256 whitelistType) public view returns (uint eggsCount) {
        eggsCount = freeMintDetails[whitelistType].eggsCount;
    }

    function getFreeMintEggsCount(uint256 whitelistType) public view returns (uint eggsCount) {
        eggsCount = freeMintDetails[whitelistType].eggsCount;
    }

    function setFreeMintDetails(uint256 whitelistType, uint eggsCount) public onlyOwner {
        freeMintDetails[whitelistType].eggsCount = eggsCount;
    }

    function getBundleDetails(uint bundleId) public view returns (uint eggsCount, uint256 price) {
        eggsCount = bundleDetails[bundleId].eggsCount;
        price = bundleDetails[bundleId].price;
    }

    function setContractActive(bool isContractActive_) public onlyOwner {
        emit ContractActivityChanged(isContractActive_, msg.sender);
        isContractActive = isContractActive_;
    }

    function setWhitelistRequired(bool isWhitelistRequired_) public onlyOwner {
        emit WhitelistRequiredChanged(isWhitelistRequired_, msg.sender);
        isWhitelistRequired = isWhitelistRequired_;
    }

    function setProfitAddress(address payable newProfitAddress) public onlyOwner {
        emit ProfitAddressChanged(profitAddress, newProfitAddress, msg.sender);
        profitAddress = newProfitAddress;
    }

    function setParametersAddress(address newParametersAddress) public onlyOwner {
        emit ParametersAddressChanged(parametersAddress, newParametersAddress, msg.sender);
        parametersAddress = newParametersAddress;
    }

    function setLandDeedRewardDetails(uint minEggsCount, uint landDeedRewardCount_) public onlyOwner {
        landDeedRewardMinEggs = minEggsCount;
        landDeedRewardCount = landDeedRewardCount_;
    }

    function calculateEggBundlesPrice(uint bundleId, uint count, uint256[] calldata whitelistTokenIds) public view returns (uint256 price) {
        require(count > 0, "Invalid count");

        BundleDetails storage details = bundleDetails[bundleId];
        require(details.eggsCount > 0, "Invalid bundle details");

        price = details.price * count;
        uint eggsCount = details.eggsCount * count;
        uint256 bundleEggPrice = details.price / details.eggsCount;
        uint freeMintEggsCount = _getFreeMintTokensEggsCount(whitelistTokenIds);

        require(eggsCount >= freeMintEggsCount, "Too many FreeMints");
        
        eggsCount -= freeMintEggsCount;
        price = eggsCount == 0 ? 0 : eggsCount * bundleEggPrice;

        for (uint i = 0; i < whitelistTokenIds.length && eggsCount > 0; i++) {
            uint256 whitelistTokenId = whitelistTokenIds[i];
            uint freeMintCount = _getWhitelistTokenFreeMintCount(whitelistTokenId);
            if (freeMintCount > 0) {
                // we already accounted free-mints
                continue;
            }

            WhitelistTypeDetails storage typeDetails = _getWhitelistTokenDetails(whitelistTokenId);
            require(typeDetails.allowedCount > 0, "Invalid whitelist token details");
            
            uint usedEggs = eggsCount >= typeDetails.allowedCount ? typeDetails.allowedCount : eggsCount;
            uint256 discount = typeDetails.discount * bundleEggPrice / 100;
            price -= usedEggs * discount;
        }
    }

    function buyEggBundles(uint bundleId, uint count, uint256[] calldata whitelistTokenIds) external payable returns (uint256[] memory eggs, uint256[] memory landDeedVouchers) {
        require(isContractActive, "Not active");
        require(parametersAddress != address(0), "EggParams not set");
        require(profitAddress != address(0), "ProfitAddr not set");
        require(!isWhitelistRequired || whitelistTokenIds.length > 0, "WL required");

        uint256 price = calculateEggBundlesPrice(bundleId, count, whitelistTokenIds);
        require(msg.value >= price, "Not enough $ONE");

        BundleDetails storage details = bundleDetails[bundleId];
        require(details.eggsCount > 0, "Invalid bundle details");

        uint256 totalEggsCount = details.eggsCount * count;
        uint freeMintEggsCount = _getFreeMintTokensEggsCount(whitelistTokenIds);
        uint256 publicEggsLeft = publicSaleEggsMaxCount - publicSaleEggsSoldCount;
        // We already checked in calculateEggBundlesPrice that freeMintEggsCount is small or equal to all eggs in this call
        uint256 publicEggsBuyCount = totalEggsCount - freeMintEggsCount;
        if (publicEggsBuyCount > 0) {
            require(publicEggsLeft >= publicEggsBuyCount, "Not enough public eggs");
        }

        publicSaleEggsSoldCount += publicEggsBuyCount;

        if (msg.value > 0) {
            profitAddress.transfer(msg.value);
        }

        // burn whitelist tokens 
        int eggsCounter = int(details.eggsCount * count);
        for (uint i = 0; i < whitelistTokenIds.length && eggsCounter > 0; i++) {
            uint256 whitelistTokenId = whitelistTokenIds[i];
            require(_whitelist.isTokenOwner(whitelistTokenId, msg.sender), "Invalid owner of whitelist token");            
            
            uint freeMintCount = _getWhitelistTokenFreeMintCount(whitelistTokenId);
            if (freeMintCount > 0) {
                eggsCounter -= int(freeMintCount);
            }
            else {
                WhitelistTypeDetails storage wlDetails = _getWhitelistTokenDetails(whitelistTokenId);
                eggsCounter -= int(wlDetails.allowedCount);

                if (wlDetails.starDustCount > 0) {
                    _starDust.mint(msg.sender, wlDetails.starDustCount);
                }
            }

            _burnWhitelist(whitelistTokenId);
        }

        if (isWhitelistRequired && eggsCounter > 0) {
            // We require WL for ALL eggs, but there are some eggs still not covered with WL-s
            revert("WL required");
        }
        
        // mint eggs
        eggs = _mintEggs(totalEggsCount);

        // mint land-deed vouchers
        if (landDeedRewardMinEggs > 0 && landDeedRewardCount > 0) {
            uint landDeedVouchersCount = landDeedRewardCount * totalEggsCount / landDeedRewardMinEggs;
            landDeedVouchers = new uint256[](landDeedVouchersCount);
            for (uint i = 0; i < landDeedVouchers.length; i++) {
                landDeedVouchers[i] = _items.mint(msg.sender, ITEM_LAND_DEED_VOUCHER);
            }
        }
    }

    function _burnWhitelist(uint256 whitelistId) private {
        _whitelist.approve(address(this), whitelistId);
        _whitelist.burn(whitelistId);
    }

    function _mintEggs(uint count) private returns (uint256[] memory eggs) {
        eggs = new uint256[](count);
        for (uint i = 0; i < eggs.length; i++) {
            (uint rarity, uint color) = IEggParametersProvider(parametersAddress).getEggParameters();
            eggs[i] = _eggs.mint(msg.sender, rarity, color);
        }
    }

    function _getWhitelistTokenDetails(uint256 whitelistTokenId) private view returns (WhitelistTypeDetails storage) {
        uint whitelistType = _whitelist.getTokenType(whitelistTokenId);

        WhitelistTypeDetails storage typeDetails = whitelistTypeDetails[whitelistType];
        require(typeDetails.allowedCount > 0, "Whitelist details not set");
        return typeDetails;
    }

    function _getWhitelistTokenFreeMintCount(uint256 whitelistTokenId) private view returns (uint) {
        uint whitelistType = _whitelist.getTokenType(whitelistTokenId);
        return freeMintDetails[whitelistType].eggsCount;
    }

    function _getFreeMintTokensEggsCount(uint256[] calldata whitelistTokenIds) private view returns (uint count) {
        count = 0;
        for (uint i = 0; i < whitelistTokenIds.length; i++) {
            uint256 whitelistTokenId = whitelistTokenIds[i];
            uint freeMintCount = _getWhitelistTokenFreeMintCount(whitelistTokenId);
            count += freeMintCount;
        }
    }

    function getAllowedEggsToBuy(uint256 whitelistTokenId) public view returns (uint) {
        WhitelistTypeDetails storage typeDetails = _getWhitelistTokenDetails(whitelistTokenId);
        return typeDetails.allowedCount;
    }
}
