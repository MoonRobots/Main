// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Eggs.sol";
import "./IEggLevelUpDetailsProvider.sol";

/// Common code for calculating egg rewards (normal and color-based)
abstract contract EggProfitBase is Ownable {
    Eggs public eggs;

    /// Reward period length define time duration where  reward coeff is constant
    uint256 public rewardPeriodLength = 10 * 24 * 3600;
    /// Percentage coeff-s how the egg reward speed changes for every reward period
    uint[] public rewardPeriodCoeffs = [140, 120, 100, 80];
    /// Percentage of next level speed used to calculate current speed based on the egg's oil level
    uint public maxSpeedCoeff = 50;
    /// Egg level => EggRarity => Reward speed (Oil per day)
    mapping(uint => mapping(uint => uint256)) public levelSpeeds;
    
    constructor(Eggs eggs_) {
        require(address(eggs_) != address(0), "Eggs is zero");
        eggs = eggs_;
    }

    function _getLastPayoutDate(uint256 eggId) internal virtual view returns (uint256);

    function getLevelSpeed(uint level, uint rarity) public view returns (uint256 speed) {
        return levelSpeeds[level][rarity] / 86400; // Returns Oil/s
    }

    function setLevelSpeed(uint level, uint rarity, uint256 oilPerDay) public onlyOwner {
        levelSpeeds[level][rarity] = oilPerDay;
    }

    function setLevelSpeedsAll(uint level, uint256[4] memory speeds) public onlyOwner {
        require(speeds.length > 0, "Input empty");
        
        for (uint256 rarity = 0; rarity < speeds.length; rarity++) {
            levelSpeeds[level][rarity] = speeds[rarity];            
        }
    }

    function setRewardPeriodCoeffs(uint[] calldata coeffs) public onlyOwner {
        require(coeffs.length > 0, "Input empty");
        
        uint len = coeffs.length;
        delete rewardPeriodCoeffs;
        for (uint i = 0; i < len; i++) {
            require(coeffs[i] > 0, "Coeff is zero");
            rewardPeriodCoeffs.push(coeffs[i]);
        }
    }

    function setRewardPeriodLength(uint256 lengthSeconds) public onlyOwner {
        require(lengthSeconds > 0, "Must be gt zero");
        rewardPeriodLength = lengthSeconds;
    }

    function setMaxSpeedCoeff(uint maxSpeedCoeff_) public onlyOwner {
        maxSpeedCoeff = maxSpeedCoeff_;
    }

    function _getRewardPeriodCoeff(uint periodIndex) private view returns (uint) {
        return periodIndex >= rewardPeriodCoeffs.length ? rewardPeriodCoeffs[rewardPeriodCoeffs.length - 1] : rewardPeriodCoeffs[periodIndex];
    }

    function getEggRewardSpeed(uint256 eggId) public view returns (uint256) {
        require(eggs.upgraderAddress() != address(0), "Upgrader not set");

        IEggLevelUpDetailsProvider levelUpDetails = IEggLevelUpDetailsProvider(eggs.upgraderAddress());

        uint256 level = eggs.getEggLevel(eggId);
        uint256 rarity = eggs.getEggRarity(eggId);
        uint256 oilLevel = eggs.getEggOilLevel(eggId);
        uint256 curLevelMinOil = levelUpDetails.getEggLevelUpDetails(level, rarity);
        uint256 nextLevelMinOil = levelUpDetails.getEggLevelUpDetails(level + 1, rarity);

        if (nextLevelMinOil <= curLevelMinOil) {
            return getLevelSpeed(level, rarity);
        }
        
        uint256 curLevelSpeed = getLevelSpeed(level, rarity);
        uint256 nextLevelSpeed = getLevelSpeed(level + 1, rarity);

        if (nextLevelSpeed <= curLevelSpeed) {
            return getLevelSpeed(level, rarity);
        }

        nextLevelSpeed = curLevelSpeed + maxSpeedCoeff * (nextLevelSpeed - curLevelSpeed) / 100;
        // Reward speed grows linearly based on the oil level
        return curLevelSpeed + (nextLevelSpeed - curLevelSpeed) * oilLevel / nextLevelMinOil;
    }

    function calculateEggReward(uint256 eggId, uint256 timestamp) public virtual view returns (uint256 payout) {
        uint256 startPayout = eggs.startPayoutDate();
        uint256 lastPayout = _getLastPayoutDate(eggId);

        uint startPeriod = (lastPayout - startPayout) / rewardPeriodLength;
        uint endPeriod = (timestamp - startPayout) / rewardPeriodLength;

        uint256 eggRewardSpeed = getEggRewardSpeed(eggId); // Oil per second
        uint256 time = lastPayout;
        payout = 0;
        for (uint periodIndex = startPeriod; periodIndex <= endPeriod; ++periodIndex) {
            uint256 endTime = startPayout + (periodIndex + 1) * rewardPeriodLength;
            endTime = endTime > timestamp ? timestamp : endTime;

            uint256 payableTime = endTime - time;
            payout += payableTime * eggRewardSpeed * _getRewardPeriodCoeff(periodIndex) / 100;
            time = endTime;
        }
    }
}
