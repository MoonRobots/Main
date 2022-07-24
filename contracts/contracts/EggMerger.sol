// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";
import "./Random.sol";
import "./Enums.sol";
import "./EggProfit.sol";
import "./EggColorProfit.sol";

// Must increase TotalSupplyLimit in Eggs
// Must be Minter in Eggs
// Must be Burner in Eggs
contract EggMerger is Proxy, Ownable {
    
    struct StageDetails {
        uint256 minLevel;
        uint256 levelBonusMin;
        uint256 levelBonusMax;
        uint256[4] rarityWeights;
    }

    // Address of possible extension-contract.
    // Extension-contract must inherit this contract and do not modify existing data layout, only extend it.
    address public extension;

    Eggs public eggs;
    EggProfit public eggProfit;
    EggColorProfit public eggColorProfit;
    Random public random;
    IERC20 public oil;
    address public profitOilAddress;
    bool public isContractActive = true;
    
    // Rarity -> Stages[]
    mapping(uint256 => StageDetails[]) public stages;
    // Rarity -> Oil Price
    mapping(uint256 => uint256) public oilPrices;

    event EggsMerged(address indexed to, uint256 indexed tokenId, uint256 indexed rarity, uint256 level);
    event RandomChoiceTested(uint256[4] result);

    constructor(IERC20 oil_, Eggs eggs_, EggProfit eggProfit_, EggColorProfit eggColorProfit_, Random random_, address profitOilAddress_) {
        require(address(oil_) != address(0), "Oil is zero");
        
        oil = oil_;
        setEggs(eggs_);
        setEggProfit(eggProfit_);
        setEggColorProfit(eggColorProfit_);
        setRandom(random_);
        setProfitOilAddress(profitOilAddress_);

        // Set default settings
        StageDetails[] memory commonStages = new StageDetails[](3);
        commonStages[0] = StageDetails({ minLevel: 0,  levelBonusMin: 0, levelBonusMax: 1, rarityWeights: [uint256(0), 1000, 0, 0] });
        commonStages[1] = StageDetails({ minLevel: 16, levelBonusMin: 1, levelBonusMax: 2, rarityWeights: [uint256(0), 940, 60, 0] });
        commonStages[2] = StageDetails({ minLevel: 24, levelBonusMin: 1, levelBonusMax: 3, rarityWeights: [uint256(0), 900, 78, 22] });

        setRarityStages(RARITY_COMMON, commonStages);

        StageDetails[] memory rareStages = new StageDetails[](3);
        rareStages[0] = StageDetails({ minLevel: 0,  levelBonusMin: 0, levelBonusMax: 1, rarityWeights: [uint256(0), 0, 1000, 0] });
        rareStages[1] = StageDetails({ minLevel: 16, levelBonusMin: 1, levelBonusMax: 2, rarityWeights: [uint256(0), 0, 940, 60] });
        rareStages[2] = StageDetails({ minLevel: 24, levelBonusMin: 1, levelBonusMax: 3, rarityWeights: [uint256(0), 0, 790, 210] });

        setRarityStages(RARITY_RARE, rareStages);

        StageDetails[] memory epicStages = new StageDetails[](3);
        epicStages[0] = StageDetails({ minLevel: 0,  levelBonusMin: 1, levelBonusMax: 2, rarityWeights: [uint256(0), 0, 0, 1000] });
        epicStages[1] = StageDetails({ minLevel: 16, levelBonusMin: 1, levelBonusMax: 3, rarityWeights: [uint256(0), 0, 0, 1000] });
        epicStages[2] = StageDetails({ minLevel: 24, levelBonusMin: 2, levelBonusMax: 4, rarityWeights: [uint256(0), 0, 0, 1000] });

        setRarityStages(RARITY_EPIC, epicStages);

        setRarityOilPrice(RARITY_COMMON, 1000 ether);
        setRarityOilPrice(RARITY_RARE, 2000 ether);
        setRarityOilPrice(RARITY_EPIC, 4000 ether);
    }

    function setContractActive(bool isContractActive_) public onlyOwner {
        isContractActive = isContractActive_;
    }

    function setRandom(Random random_) public onlyOwner {
        require(address(random_) != address(0), "Random is zero");
        random = random_;
    }

    function setEggs(Eggs eggs_) public onlyOwner {
        require(address(eggs_) != address(0), "Eggs is zero");
        eggs = eggs_;
    }

    function setEggProfit(EggProfit eggProfit_) public onlyOwner {
        require(address(eggProfit_) != address(0), "Profit is zero");
        eggProfit = eggProfit_;
    }

    function setEggColorProfit(EggColorProfit eggColorProfit_) public onlyOwner {
        require(address(eggColorProfit_) != address(0), "ColorProfit is zero");
        eggColorProfit = eggColorProfit_;
    }

    function setProfitOilAddress(address newProfitOilAddress) public onlyOwner {
        require(newProfitOilAddress != address(0), "ProfitOil is zero");
        profitOilAddress = newProfitOilAddress;
    }

    function setRarityOilPrice(uint256 rarity, uint256 oilPrice) public onlyOwner {
        require(rarity >= RARITY_COMMON && rarity <= RARITY_LEGENDARY, "Invalid rarity");
        oilPrices[rarity] = oilPrice;
    }

    function setRarityStages(uint256 rarity, StageDetails[] memory stages_) public onlyOwner {
        require(rarity >= RARITY_COMMON && rarity <= RARITY_LEGENDARY, "Invalid rarity");
        require(stages_.length > 0, "Stages is empty");

        delete stages[rarity];

        int256 lastMinLevel = -1;
        for (uint256 i = 0; i < stages_.length; i++) {
            require(int256(stages_[i].minLevel) > lastMinLevel, "MinLevel must grow");
            require(stages_[i].levelBonusMin <= stages_[i].levelBonusMax, "Min must <= Max");
            require(stages_[i].rarityWeights.length == 4, "RarityWeights len must be 4");

            stages[rarity].push(stages_[i]);
            lastMinLevel = int256(stages_[i].minLevel);
        }
    }

    function getStageRarityWeights(uint256 rarity, uint256 stageIndex) public view returns (uint256[4] memory rarityWeights) {
        require(rarity >= RARITY_COMMON && rarity <= RARITY_LEGENDARY, "Invalid rarity");

        StageDetails[] storage rarityStages = stages[rarity];
        require(stageIndex >= 0 && stageIndex < rarityStages.length, "Invalid rarity");

        rarityWeights = rarityStages[stageIndex].rarityWeights;
    }

    function _implementation() internal view override returns (address) {
        return extension;
    }

    function setExtension(address extension_) public onlyOwner {
        require(extension_ != address(0), "Extension is zero");
        extension = extension_;
    }

    function mergeEggs(uint256[] calldata eggIds) public returns (uint256 tokenId) {
        require(isContractActive, "Not active");
        require(eggIds.length == 3, "Not 3 eggs");
        
        uint256 reward = 0;
        uint256 colorReward = 0;
        uint256 levelSum = 0;
        uint256 levelMin = type(uint256).max;
        uint256 rarity = eggs.getEggRarity(eggIds[0]);

        require(rarity < RARITY_LEGENDARY, "Cannot merge legends");

        uint256 oilPrice = oilPrices[rarity];
        require(oilPrice > 0, "Oil price is not set");
        oil.transferFrom(msg.sender, profitOilAddress, oilPrice);

        for (uint256 i = 0; i < eggIds.length; i++) {
            uint256 eggId = eggIds[i];
            require(eggs.isTokenOwner(eggId, msg.sender), "Not egg owner");
            require(eggs.getEggRarity(eggId) == rarity, "Not same rarity");
            
            reward += eggProfit.calculateEggReward(eggId, block.timestamp);
            colorReward += eggColorProfit.calculateEggReward(eggId, block.timestamp);

            uint256 level = eggs.getEggLevel(eggId);
            if (level < levelMin) {
                levelMin = level;
            }

            levelSum += level;

            eggs.burn(eggId);
        }

        EggDetails memory details;
        StageDetails memory stageDetails = getStageDetails(rarity, levelMin);
        uint256 newRarity = _randomChoice(stageDetails.rarityWeights);

        details.rarity = newRarity < (rarity + 1) ? rarity + 1 : newRarity; // Max(rarity + 1, newRarity)
        details.color = random.random() % 3;
        details.level = levelSum / eggIds.length + _randomRange(stageDetails.levelBonusMin, stageDetails.levelBonusMax);
        details.lastPayout = block.timestamp;
        details.lastColorPayout = block.timestamp;
        details.oilLevel = 0;
        details.reward = reward;
        details.colorReward = colorReward;

        tokenId = eggs.mint(msg.sender, details);

        emit EggsMerged(msg.sender, tokenId, eggs.getEggRarity(tokenId), eggs.getEggLevel(tokenId));
    }

    function _randomRange(uint256 min, uint256 max) internal returns (uint256) {
        require(min <= max, "Invalid MinMax");
        if (min == max) {
            return min;
        }

        return min + random.random() % (max - min + 1);
    }

    function _randomChoice(uint256[4] memory weights) internal returns (uint256) {
        uint totalWeight = 0;
        for (uint i = 0; i < weights.length; i++) {
            totalWeight += weights[i];
        }

        if (totalWeight == 0) {
            // All choices are equal
            return random.random() % weights.length;
        }

        uint256 rnd = random.random() % totalWeight;
        uint256 accumWeight = 0;

        for (uint i = 0; i < weights.length; i++) {
            accumWeight += weights[i];
            if (rnd < accumWeight) {
                return i;
            }
        }

        revert("Unreachable");
    }

    function testRandomChoice(uint256[4] calldata weights, uint256 count) public onlyOwner returns (uint256[4] memory) {
        uint256[4] memory result = [uint256(0),0,0,0];
        for (uint256 i = 0; i < count; i++) {
            result[_randomChoice(weights)]++;
        }

        emit RandomChoiceTested(result);
        return result;
    }

    function getStageDetails(uint256 rarity, uint256 level) public view returns (StageDetails memory) {
        StageDetails[] storage rarityDetails = stages[rarity];
        require(rarityDetails.length > 0, "Stage not set for rarity");

        for (uint256 i = 0; i < rarityDetails.length; i++) {
            if (rarityDetails[i].minLevel > level) {
                return rarityDetails[i - 1];
            }
        }
        
        return rarityDetails[rarityDetails.length - 1];
    }
}
