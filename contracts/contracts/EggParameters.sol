// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IEggParametersProvider.sol";
import "./Random.sol";

contract EggParameters is IEggParametersProvider, Ownable {
    Random public random;

    // Rarity => Generated count
    mapping (uint256 => uint256) public rarityCounts;
    mapping (address => bool) public generators;
    uint[] public maxCounts;

    event ParametersGenerated(uint256 indexed rarity, uint256 indexed color);

    constructor(Random random_) {
        require(address(random_) != address(0), "Addr is zero");
        random = random_;
        
        maxCounts.push(7630); // RARITY_COMMON
        maxCounts.push(2100); // RARITY_RARE
        maxCounts.push(210);  // RARITY_EPIC
        maxCounts.push(60);   // RARITY_LEGENDARY
    }

    function setRandom(Random random_) public onlyOwner {
        require(address(random_) != address(0), "Addr is zero");
        random = random_;
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
    
    function getEggParameters(uint minRarity) external returns (uint rarity, uint color) {
        require(generators[msg.sender], "Not generator");
        rarity = _decideRarity(minRarity);
        color = _decideColor();

        emit ParametersGenerated(rarity, color);
    }

    function getEggParameters() external override returns (uint rarity, uint color) {
        require(generators[msg.sender], "Not generator");

        rarity = _decideRarity(0);
        color = _decideColor();

        emit ParametersGenerated(rarity, color);
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

    function _decideColor() internal returns (uint) {
        return random.random() % 3;
    }

    function _decideRarity(uint minRarity) internal returns (uint) {
        uint totalSupply = totalLeft();
        require(totalSupply > 0, "Pools empty");

        uint256 rnd = random.random() % totalSupply;
        uint256 accumCount = 0;

        for (uint rarity = 0; rarity < maxCounts.length; rarity++) {
            uint maxCount = maxCounts[rarity];
            uint256 leftCount = maxCount - rarityCounts[rarity];

            if (leftCount == 0) {
                continue;
            }

            if (rnd < (accumCount + leftCount)) {
                if (rarity < minRarity) {
                    rarity = minRarity;
                }

                rarityCounts[rarity]++;
                return rarity;
            }

            accumCount += leftCount;
        }

        revert("Limit reached");
    }

    function setGenerator(address generatorAddress, bool enabled) public onlyOwner {
        require(generatorAddress != address(0), "Invalid addr");
        generators[generatorAddress] = enabled;
    }

    function getGenerator(address generatorAddress) public view returns (bool) {
        return generators[generatorAddress];
    }
}
