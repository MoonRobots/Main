// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../contracts_disabled/Easter/EasterPieces.sol";
import "./Enums.sol";

contract EasterEggsBurner is Ownable {
    EasterPieces public easterEggs;
    IERC20 public starDust;

    address public profitStardustAddress;
    bool public isContractActive = true;

    mapping (uint256 => uint256) public starDustRewardByEasterEggType;

    event ContractActivityChanged(bool indexed newActiveStatus, address indexed caller);
    event ProfitStardustAddressChanged(address indexed oldProfitAddress, address indexed newProfitAddress, address indexed caller);
    event EasterEggBurned(uint256 indexed easterEggType, uint256 indexed easterEggId);
    
    constructor(EasterPieces easterEggs_, IERC20 starDust_, address profitStardustAddress_) {
        require(address(starDust_) != address(0), "SD is zero");

        setEasterEggs(easterEggs_);
        starDust = starDust_;

        setProfitStardustAddress(profitStardustAddress_);

        starDustRewardByEasterEggType[PIECE_TYPE_GOLD] = 150 ether;
        starDustRewardByEasterEggType[PIECE_TYPE_PINK] = 70 ether;
        starDustRewardByEasterEggType[PIECE_TYPE_BLUE] = 50 ether;
        starDustRewardByEasterEggType[PIECE_TYPE_VIOLET] = 100 ether;
        starDustRewardByEasterEggType[PIECE_TYPE_STAR] = 10 ether;
    }

    function setContractActive(bool isContractActive_) public onlyOwner {
        emit ContractActivityChanged(isContractActive_, msg.sender);
        isContractActive = isContractActive_;
    }

    function setEasterEggs(EasterPieces easterEggs_) public onlyOwner {
        require(address(easterEggs_) != address(0), "Easter eggs is zero");
        easterEggs = easterEggs_;
    }

    function setProfitStardustAddress(address newProfitStardustAddress) public onlyOwner {
        require(newProfitStardustAddress != address(0), "ProfitStardust is zero");
        emit ProfitStardustAddressChanged(profitStardustAddress, newProfitStardustAddress, msg.sender);
        profitStardustAddress = newProfitStardustAddress;
    }

    function setStardustReward(
        uint256 easterEggType,
        uint256 rewardStardustAmount) public onlyOwner {

        starDustRewardByEasterEggType[easterEggType] = rewardStardustAmount;
    }

    function burnEasterEgg(uint256 eggId) public {
        require(isContractActive, "Not active");
        require(msg.sender == easterEggs.ownerOf(eggId), "Not an owner of easter egg");
        uint256 eggType = easterEggs.types(eggId);
        uint256 stardustReward = starDustRewardByEasterEggType[eggType];
        require(stardustReward > 0, "Looks like reward is not set or incorrect");
        starDust.transferFrom(profitStardustAddress, msg.sender, stardustReward);

        easterEggs.burn(eggId);
    }
}
