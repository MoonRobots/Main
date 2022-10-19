// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./Eggs.sol";
import "./Robots.sol";
import "./EggProfit.sol";
import "./Random.sol";

// Must be minter of Robots
// Must be stats admin in Robots
// Must be health admin in Robots
// Must be breeding admin in Robots
// Eggs.hatcheryAddress must be set
contract RobotsHatchery is Ownable {
    using ECDSA for bytes32;

    Eggs public eggs;
    Robots public robots;
    EggProfit public eggProfit;
    Random public random;
    address public validatorAddress;

    struct HatchData {
        uint256 eggId;
        // Details
        uint element;
        uint rarity;
        uint race;
        uint skillFlags;
        uint generation;
        string fileName;
        // Stats
        uint level;
        uint str;
        uint agi;
        uint intl;
        uint hp;
        uint sta;
        uint brd;
    }

    constructor (Eggs eggs_, Robots robots_, EggProfit eggProfit_, Random random_, address validatorAddress_) {
        setEggs(eggs_);
        setRobots(robots_);
        setEggProfit(eggProfit_);
        setRandom(random_);
        setValidator(validatorAddress_);
    }

    function setEggs(Eggs eggs_) public onlyOwner {
        require(address(eggs_) != address(0), "Eggs is zero");
        eggs = eggs_;
    }

    function setRobots(Robots robots_) public onlyOwner {
        require(address(robots_) != address(0), "Robots is zero");
        robots = robots_;
    }

    function setEggProfit(EggProfit eggProfit_) public onlyOwner {
        //require(address(eggProfit_) != address(0), "EggProfit is zero");
        eggProfit = eggProfit_;
    }

    function setRandom(Random random_) public onlyOwner {
        require(address(random_) != address(0), "Random is zero");
        random = random_;
    }

    function setValidator(address validatorAddress_) public onlyOwner {
        require(validatorAddress_ != address(0), "Validator is zero");
        validatorAddress = validatorAddress_;
    }

    function hatch(bytes calldata data, bytes calldata signature) public returns (uint256 robotId) {
        address signer = keccak256(data).toEthSignedMessageHash().recover(signature);
        require(signer == validatorAddress, "Signer not valid");

        HatchData memory hatchData = abi.decode(data, (HatchData));
        uint256 eggId = hatchData.eggId;


        require(eggs.ownerOf(eggId) == msg.sender, "Not egg owner");

        if (address(eggProfit) != address(0) && eggProfit.calculateEggReward(eggId, block.timestamp) > 0) {
            eggProfit.claimFromHatchery(eggId);
        }
        
        robotId = robots.mint(msg.sender, 
            hatchData.element, 
            hatchData.rarity, 
            hatchData.race,
            hatchData.generation,
            hatchData.fileName,
            hatchData.skillFlags);
        
        RobotStats memory stats = RobotStats({
            level: hatchData.level,
            str: hatchData.str,
            agi: hatchData.agi,
            intl: hatchData.intl,
            hp: hatchData.hp,
            sta: hatchData.sta,
            brd: hatchData.brd
        });
        robots.setStats(robotId, stats);

        robots.addHealth(robotId, int256(hatchData.hp));
        robots.addBreeding(robotId, int256(hatchData.brd));

        eggs.setHatched(eggId);
    }
}