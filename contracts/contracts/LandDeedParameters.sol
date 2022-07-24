// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "./Enums.sol";
import "./ILandDeedParametersProvider.sol";
import "./Random.sol";

contract LandDeedParameters is ILandDeedParametersProvider, Ownable {
    Random public random;

    mapping (address => bool) public generators;
    mapping(uint256 => uint) public rarityCounts;
    uint[] public maxCounts;

    event ParametersGenerated(uint256 indexed rarity);

    constructor(Random random_) {
        setRandom(random_);

        // maxCounts.push(15000); // COMMON
        // maxCounts.push(5000);  // RARE
        // maxCounts.push(800);   // EPIC
        // maxCounts.push(200);   // LEGENDARY

        maxCounts.push(7500); // COMMON
        maxCounts.push(2500);  // RARE
        maxCounts.push(400);   // EPIC
        maxCounts.push(100);   // LEGENDARY
    }

    function totalGenerated() public view returns (uint256 count) {
        count = 0;
        for (uint rarity = 0; rarity < maxCounts.length; rarity++) {
            count += rarityCounts[rarity];
        }
    }

    function totalLeft() public view returns (uint256 count) {
        count = 0;
        for (uint rarity = 0; rarity < maxCounts.length; rarity++) {
            count += maxCounts[rarity] - rarityCounts[rarity];
        }
    }

    function totalSupplyLimit() public view returns (uint256 count) {
        count = 0;
        for (uint rarity = 0; rarity < maxCounts.length; rarity++) {
            count += maxCounts[rarity];
        }
    }

    function setRandom(Random random_) public onlyOwner {
        require(address(random_) != address(0), "Random is zero");
        random = random_;
    }

    function getLandDeedParameters(uint[] calldata rarityWeights) external override returns (uint rarity) {
        require(generators[msg.sender], "Not generator");
        require(rarityWeights.length == maxCounts.length, "Invalid weights");

        rarity = _decideRarity(rarityWeights);

        emit ParametersGenerated(rarity);
    }

    function setMaxCounts(uint[] calldata maxCounts_) public onlyOwner {
        require(maxCounts_.length > 0, "Input empty");
        
        uint len = maxCounts_.length;
        delete maxCounts;
        for (uint rarity = 0; rarity < len; rarity++) {
            // Already generated count must be smaller or equal to the new maxCount
            require(rarityCounts[rarity] <= maxCounts_[rarity], "maxCount too small");
            maxCounts.push(maxCounts_[rarity]);
        }
    }

    function _decideRarity(uint[] calldata rarityWeights) internal returns (uint rarity) {
        uint totalWeight = 0; // Without weights of empty rarity pools
        for (uint i = 0; i < rarityWeights.length; i++) {
            if (rarityCounts[i] >= maxCounts[i]) {
                // Skip empty pools
                continue;
            }

            totalWeight += rarityWeights[i];
        }

        require(totalWeight > 0, "Pools empty");

        uint256 rnd = random.random() % totalWeight;
        uint256 accumWeight = 0;

        for (uint i = 0; i < rarityWeights.length; i++) {
            uint weight = rarityWeights[i];

            if (rarityCounts[i] >= maxCounts[i]) {
                continue;
            }

            accumWeight += weight;

            if (rnd < accumWeight) {
                rarityCounts[i]++;
                return i;
            }
        }

        revert("Limit reached");
    }

    function setGenerator(address generatorAddress, bool enabled) public onlyOwner {
        require(generatorAddress != address(0), "Invalid addr");
        generators[generatorAddress] = enabled;
    }
}
