// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./EggProfitBase.sol";
import "./IClaimable.sol";

contract EggColorProfit is EggProfitBase {
    IERC20 public oil;
    bool public isContractActive = true;
    // Account from which we transfer OIL rewards
    address public oilRewardAddress;

    event ContractActivityChanged(bool newActiveStatus, address indexed caller);
    event Claimed(address indexed claimer, uint256 indexed amount);

    constructor(Eggs eggs, IERC20 oil_, address oilRewardAddress_) EggProfitBase(eggs) {
        require(address(oil_) != address(0), "Oil is zero");
        require(oilRewardAddress_ != address(0), "Reward addr is zero");

        oil = oil_;
        oilRewardAddress = oilRewardAddress_;

        setLevelSpeedsAll(0,  [uint256(6.00 ether), 12.00 ether, 24.00 ether, 48.00 ether]);
        setLevelSpeedsAll(1,  [uint256(9.45 ether), 18.90 ether, 37.80 ether, 75.60 ether]);
        setLevelSpeedsAll(2,  [uint256(13.20 ether), 26.40 ether, 52.80 ether, 105.60 ether]);
        setLevelSpeedsAll(3,  [uint256(17.25 ether), 34.50 ether, 69.00 ether, 138.00 ether]);
        setLevelSpeedsAll(4,  [uint256(21.60 ether), 43.20 ether, 86.40 ether, 172.80 ether]);
        setLevelSpeedsAll(5,  [uint256(26.25 ether), 52.50 ether, 105.00 ether, 210.00 ether]);
        setLevelSpeedsAll(6,  [uint256(32.80 ether), 66.00 ether, 132.00 ether, 264.00 ether]);
        setLevelSpeedsAll(7,  [uint256(40.50 ether), 81.00 ether, 162.00 ether, 324.00 ether]);
        setLevelSpeedsAll(8,  [uint256(49.00 ether), 97.50 ether, 195.00 ether, 390.00 ether]);
        setLevelSpeedsAll(9,  [uint256(57.75 ether), 115.50 ether, 231.00 ether, 462.00 ether]);
        setLevelSpeedsAll(10,  [uint256(67.20 ether), 135.00 ether, 270.00 ether, 540.00 ether]);
        setLevelSpeedsAll(11,  [uint256(78.00 ether), 156.00 ether, 312.00 ether, 624.00 ether]);
        setLevelSpeedsAll(12,  [uint256(88.90 ether), 177.80 ether, 355.60 ether, 711.20 ether]);
        setLevelSpeedsAll(13,  [uint256(108.75 ether), 217.50 ether, 435.00 ether, 870.00 ether]);
        setLevelSpeedsAll(14,  [uint256(144.00 ether), 288.00 ether, 576.00 ether, 1152.00 ether]);

        setLevelSpeedsAll(15, [uint256(152.00 ether), 304.00 ether, 608.00 ether, 1216.00 ether]);
        setLevelSpeedsAll(16, [uint256(160.00 ether), 320.00 ether, 640.00 ether, 1280.00 ether]);
        setLevelSpeedsAll(17, [uint256(168.00 ether), 336.00 ether, 672.00 ether, 1344.00 ether]);
        setLevelSpeedsAll(18, [uint256(176.00 ether), 352.00 ether, 704.00 ether, 1408.00 ether]);
        setLevelSpeedsAll(19, [uint256(184.00 ether), 368.00 ether, 736.00 ether, 1472.00 ether]);
        setLevelSpeedsAll(20, [uint256(192.00 ether), 384.00 ether, 768.00 ether, 1536.00 ether]);
        setLevelSpeedsAll(21, [uint256(200.00 ether), 400.00 ether, 800.00 ether, 1600.00 ether]);
        setLevelSpeedsAll(22, [uint256(208.00 ether), 416.00 ether, 832.00 ether, 1664.00 ether]);
        setLevelSpeedsAll(23, [uint256(216.00 ether), 432.00 ether, 864.00 ether, 1728.00 ether]);
        setLevelSpeedsAll(24, [uint256(224.00 ether), 448.00 ether, 896.00 ether, 1792.00 ether]);
        setLevelSpeedsAll(25, [uint256(232.00 ether), 464.00 ether, 928.00 ether, 1856.00 ether]);
        setLevelSpeedsAll(26, [uint256(240.00 ether), 480.00 ether, 960.00 ether, 1920.00 ether]);
        setLevelSpeedsAll(27, [uint256(248.00 ether), 496.00 ether, 992.00 ether, 1984.00 ether]);
        setLevelSpeedsAll(28, [uint256(256.00 ether), 512.00 ether, 1024.00 ether, 2048.00 ether]);
        setLevelSpeedsAll(29, [uint256(264.00 ether), 528.00 ether, 1056.00 ether, 2112.00 ether]);
    }

    function setOilRewardAddress(address oilRewardAddress_) public onlyOwner {
        require(address(oilRewardAddress) != address(0), "Reward addr is zero");
        oilRewardAddress = oilRewardAddress_;
    }

    function setContractActive(bool _isContractActive) public onlyOwner {
        emit ContractActivityChanged(_isContractActive, msg.sender);
        isContractActive = _isContractActive;
    }

    function claim(uint256 eggId1, uint256 eggId2, uint256 eggId3) public {
        require(isContractActive, "Not active");
        require(eggs.isTokenOwner(eggId1, msg.sender), "Not egg owner 1");
        require(eggs.isTokenOwner(eggId2, msg.sender), "Not egg owner 2");
        require(eggs.isTokenOwner(eggId3, msg.sender), "Not egg owner 3");
        require(_isAllColors(eggId1, eggId2, eggId3), "Not all color");

        uint256 reward1 = calculateEggReward(eggId1, block.timestamp);
        uint256 reward2 = calculateEggReward(eggId2, block.timestamp);
        uint256 reward3 = calculateEggReward(eggId3, block.timestamp);
        uint256 rewardMin = _min3(reward1, reward2, reward3);

        eggs.setEggLastColorPayoutDate(eggId1);
        eggs.setEggLastColorPayoutDate(eggId2);
        eggs.setEggLastColorPayoutDate(eggId3);

        eggs.setEggColorReward(eggId1, reward1 - rewardMin);
        eggs.setEggColorReward(eggId2, reward2 - rewardMin);
        eggs.setEggColorReward(eggId3, reward3 - rewardMin);
        
        oil.transferFrom(oilRewardAddress, msg.sender, rewardMin * 3);

        emit Claimed(msg.sender, rewardMin);
    }

    function claimAll(uint256 eggId1, uint256 eggId2, uint256 eggId3) public {
        claim(eggId1, eggId2, eggId3); // Will check egg owner

        IClaimable eggProfit = IClaimable(eggs.eggProfitAddress());

        // Will not check egg owner, trust to EggColorProfit
        eggProfit.claim(eggId1); 
        eggProfit.claim(eggId2);
        eggProfit.claim(eggId3);
    }

    function claimAllBulk(uint256[][] calldata eggIdGroups) public {
        uint groupsCount = eggIdGroups.length;
        require(groupsCount > 0, "Input empty");

        IClaimable eggProfit = IClaimable(eggs.eggProfitAddress());

        for (uint256 i = 0; i < groupsCount; i++) {
            uint256[] calldata group = eggIdGroups[i];
            if (group.length == 3) {
                claimAll(group[0], group[1], group[2]);
            }
            else {
                for (uint256 j = 0; j < group.length; j++) {
                    uint256 eggId = group[j];

                    // Must chek egg owner as EggProfit trusts to EggColorProfit and will not check
                    require(eggs.isTokenOwner(eggId, msg.sender), "Not egg owner");
                    eggProfit.claim(eggId);
                }
            }
        }
    }
    
    // Collects rewards into the egg and reset payout date, but do not mint OIL
    function collectFromUpgrader(uint256 eggId) external {
        require(isContractActive, "Not active");
        require(eggs.upgraderAddress() != address(0), "Upgrader not set");
        require(eggs.upgraderAddress() == msg.sender, "Not Upgarder");
        
        uint256 reward = calculateEggReward(eggId, block.timestamp);
        eggs.setEggLastColorPayoutDate(eggId);
        eggs.setEggColorReward(eggId, reward);
    }

    function calculateEggReward(uint256 eggId, uint256 timestamp) public override view returns (uint256 payout) {
        payout = super.calculateEggReward(eggId, timestamp);
        payout += eggs.getEggColorReward(eggId); // add stored reward
    }

    function _getLastPayoutDate(uint256 eggId) internal override view returns (uint256) {
        return eggs.getEggLastColorPayoutDate(eggId);
    }

    function _isAllColors(uint256 eggId1, uint256 eggId2, uint256 eggId3) private view returns (bool success) {
        uint color1 = eggs.getEggColor(eggId1);
        uint color2 = eggs.getEggColor(eggId2);
        uint color3 = eggs.getEggColor(eggId3);

        success = color1 != color2 && color2 != color3 && color1 != color3;
    }

    function _min3(uint256 a, uint256 b, uint256 c) private pure returns (uint256 min) {
        min = a < b? a: b;
        min = c < min? c: min;
    }
}
