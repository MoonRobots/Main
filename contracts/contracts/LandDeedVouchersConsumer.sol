// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Enums.sol";
import "./Items.sol";
import "./ILandDeedParametersProvider.sol";

contract LandDeedVouchersConsumer is Ownable {
    Items public items;
    ILandDeedParametersProvider public landDeedParameters;
    bool public isContractActive = true;
    uint256[] public weights;

    constructor(Items items_, ILandDeedParametersProvider landDeedParameters_) {
        setItems(items_);
        setLandDeedParameters(landDeedParameters_);

        weights.push(722);
        weights.push(232);
        weights.push(38);
        weights.push(8);
    }

    function setItems(Items items_) public onlyOwner {
        require(address(items_) != address(0), "Items is zero");
        items = items_;
    }

    function setLandDeedParameters(ILandDeedParametersProvider landDeedParameters_) public onlyOwner {
        require(address(landDeedParameters_) != address(0), "LD Params is zero");
        landDeedParameters = landDeedParameters_;
    }

    function setContractActive(bool isContractActive_) public onlyOwner {
        isContractActive = isContractActive_;
    }

    function consumeVouchersBulk(uint256[] calldata voucherIds) public onlyOwner returns (uint256[] memory landDeedIds) {
        require(isContractActive, "Not active");
        require(voucherIds.length > 0, "Input is empty");
        require(address(landDeedParameters) != address(0), "LD Params not set");

        uint256 count = voucherIds.length;
        landDeedIds = new uint256[](count);
        for (uint i = 0; i < count; ++i) {
            uint256 voucherId = voucherIds[i];
            address voucherOwner = items.ownerOf(voucherId);
            require(voucherOwner != address(0), "Burned voucher");
            require(items.types(voucherId) == ITEM_LAND_DEED_VOUCHER, "Invalid voucher type");
            
            items.burn(voucherId);

            uint rarity = landDeedParameters.getLandDeedParameters(weights);
            uint256 itemType = getLandDeedTypeWithRarity(rarity);

            landDeedIds[i] = items.mint(voucherOwner, itemType);
        }
    }
}
