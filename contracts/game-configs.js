const EggPrice = 990;

const WhitelistIds = {
    Gold: 1,
    Silver: 2,
    Epic: 3,
    Bronze: 4,
    Platinum: 5,
};

const FreeMintIds = {
    X1: 100,
    X3: 101,
    X5: 102,
    X20: 103
}

const WhitelistStarDustReward = {
    Bronze: 100,
    Silver: 300,
    Gold: 500,
    Epic: 600,
    Platinum: 0
}

const Rarity = {
    Common: 0,
    Rare: 1,
    Epic: 2,
    Legendary: 3
}

module.exports = {
    development: {
        teamOilAmount: 100_000_000,
        oilLimit: 1000_000_000,
        whitelistAddress: null,
        landsLimit: 21000,
        landDeedPrice: 1000, // OIL
        eggs: {
            price: EggPrice,
            totalSupplyLimit: 10000,
            // Eggs count need to be bought in a single call to get a single LandDeedVoucher reward
            landDeedRewardMinEggs: 20,
            // LandDeedVouchers given if user buys at least landDeedRewardMinEggs eggs
            landDeedRewardCount: 2,            
            bundles: [
                { id: 100, eggsCount: 1,  price: 990 },
                { id: 101, eggsCount: 3,  price: 2850 },
                { id: 102, eggsCount: 5,  price: 4700 },
                { id: 103, eggsCount: 20, price: 18000 },
            ],
            getBundleByEggsCount: function (count) {
                return this.bundles.find(b => b.eggsCount === count);
            },
            whitelists: [
                {id: WhitelistIds.Gold,     name: "Gold",     allowedCount: 5,  discount: 5, starDustCount: WhitelistStarDustReward.Gold},
                {id: WhitelistIds.Silver,   name: "Silver",   allowedCount: 3,  discount: 5, starDustCount: WhitelistStarDustReward.Silver},
                {id: WhitelistIds.Epic,     name: "Epic",     allowedCount: 3,  discount: 10, starDustCount: WhitelistStarDustReward.Epic},
                {id: WhitelistIds.Bronze,   name: "Bronze",   allowedCount: 1,  discount: 5, starDustCount: WhitelistStarDustReward.Bronze},
                //{id: WhitelistIds.Platinum, name: "Platinum", allowedCount: 20, discount: 60, starDustCount: WhitelistStarDustReward.Platinum},
            ],
            getWhitelistByName: function(name) {
                return this.whitelists.find(w => w.name === name);
            },
            getWhitelistById: function(id) {
                return this.whitelists.find(w => w.id === id);
            },
            freeMints: [
                {id: FreeMintIds.X1, mintCount: 1},
                {id: FreeMintIds.X3, mintCount: 3},
                {id: FreeMintIds.X5, mintCount: 5},
                {id: FreeMintIds.X20, mintCount: 20},
            ],
            getFreeMintByCount: function (count) {
                return this.freeMints.find(m => m.mintCount === count);
            },
            getFreeMintById: function (id) {
                return this.freeMints.find(m => m.id === id);
            },
            whiteListExchange: [
                {inputId: WhitelistIds.Bronze, outputId: FreeMintIds.X1, price: 840, starDustCount: WhitelistStarDustReward.Bronze},
                {inputId: WhitelistIds.Silver, outputId: FreeMintIds.X3, price: 2500, starDustCount: WhitelistStarDustReward.Silver},
                {inputId: WhitelistIds.Gold,   outputId: FreeMintIds.X5, price: 4200, starDustCount: WhitelistStarDustReward.Gold},
                {inputId: WhitelistIds.Epic,   outputId: FreeMintIds.X3, price: 2300, starDustCount: WhitelistStarDustReward.Epic},
            ],
            getWhiteListExchangeByInputName: function (inputName) {
                let wl = this.getWhitelistByName(inputName);
                return this.whiteListExchange.find(w => w.inputId === wl.id);
            },

            // Upgrade OIL price for every rarity
            upgradeLevelPrices: [
                [0, 0, 0, 0],
                [75, 160, 300, 600],
                [90, 180, 360, 720],
                [105, 210, 420, 840], 
                [120, 240, 480, 960],
                [135, 270, 540, 1080],
                [150, 300, 600, 1200],
                [165, 330, 660, 1320],
                [180, 360, 720, 1440],
                [195, 390, 780, 1560],
                [225, 450, 900, 1800],
                [255, 510, 1020, 2040],
                [300, 600, 1200, 2400],
                [750, 1500, 3000, 6000],
                [1500, 3000, 6000, 12000],
                [1600, 3200, 6400, 12800],
                [1700, 3400, 6800, 13600],
                [1800, 3600, 7200, 14400],
                [1900, 3800, 7600, 15200],
                [2000, 4000, 8000, 16000],
                [2500, 5000, 10000, 20000],
                [3000, 6000, 12000, 24000],
                [3500, 7000, 14000, 28000],
                [4000, 8000, 16000, 32000],
                [4500, 9000, 18000, 36000],
                [5000, 10000, 20000, 40000],
                [6000, 12000, 24000, 48000],
                [7000, 14000, 28000, 56000],
                [8000, 16000, 32000, 64000],
                [9000, 18000, 36000, 72000]        
            ],

            // Percentage multiplier oil -> start dust which will be given during egg upgrade (or add oil)
            upgradeLevelOilToStarDust: [
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50,
                50
            ],

            // Oil per day given by EggProfit contract (for every rarity)
            rewardSpeeds: [
                [54.00, 108.00, 216.00, 432.00],
                [53.55, 107.10, 214.20, 428.40],
                [52.80, 105.60, 211.20, 422.40],
                [51.75, 103.50, 207.00, 414.00],
                [50.40, 100.80, 201.60, 403.20],
                [48.75, 97.50, 195.00, 390.00],
                [49.20, 99.00, 198.00, 396.00],
                [49.50, 99.00, 198.00, 396.00],
                [49.00, 97.50, 195.00, 390.00],
                [47.25, 94.50, 189.00, 378.00],
                [44.80, 90.00, 180.00, 360.00],
                [42.00, 84.00, 168.00, 336.00],
                [38.10, 76.20, 152.40, 304.80],
                [36.25, 72.50, 145.00, 290.00],
                [36.00, 72.00, 144.00, 288.00],
                [38.00, 76.00, 152.00, 304.00],
                [40.00, 80.00, 160.00, 320.00],
                [42.00, 84.00, 168.00, 336.00],
                [44.00, 88.00, 176.00, 352.00],
                [46.00, 92.00, 184.00, 368.00],
                [48.00, 96.00, 192.00, 384.00],
                [50.00, 100.00, 200.00, 400.00],
                [52.00, 104.00, 208.00, 416.00],
                [54.00, 108.00, 216.00, 432.00],
                [56.00, 112.00, 224.00, 448.00],
                [58.00, 116.00, 232.00, 464.00],
                [60.00, 120.00, 240.00, 480.00],
                [62.00, 124.00, 248.00, 496.00],
                [64.00, 128.00, 256.00, 512.00],
                [66.00, 132.00, 264.00, 528.00]
            ],

            // Oil per day given by EggColorProfit contract (for every rarity)
            colorRewardSpeeds: [
                [6.00, 12.00, 24.00, 48.00],
                [9.45, 18.90, 37.80, 75.60],
                [13.20, 26.40, 52.80, 105.60],
                [17.25, 34.50, 69.00, 138.00],
                [21.60, 43.20, 86.40, 172.80],
                [26.25, 52.50, 105.00, 210.00],
                [32.80, 66.00, 132.00, 264.00],
                [40.50, 81.00, 162.00, 324.00],
                [49.00, 97.50, 195.00, 390.00],
                [57.75, 115.50, 231.00, 462.00],
                [67.20, 135.00, 270.00, 540.00],
                [78.00, 156.00, 312.00, 624.00],
                [88.90, 177.80, 355.60, 711.20],
                [108.75, 217.50, 435.00, 870.00],
                [144.00, 288.00, 576.00, 1152.00],
                [152.00, 304.00, 608.00, 1216.00],
                [160.00, 320.00, 640.00, 1280.00],
                [168.00, 336.00, 672.00, 1344.00],
                [176.00, 352.00, 704.00, 1408.00],
                [184.00, 368.00, 736.00, 1472.00],
                [192.00, 384.00, 768.00, 1536.00],
                [200.00, 400.00, 800.00, 1600.00],
                [208.00, 416.00, 832.00, 1664.00],
                [216.00, 432.00, 864.00, 1728.00],
                [224.00, 448.00, 896.00, 1792.00],
                [232.00, 464.00, 928.00, 1856.00],
                [240.00, 480.00, 960.00, 1920.00],
                [248.00, 496.00, 992.00, 1984.00],
                [256.00, 512.00, 1024.00, 2048.00],
                [264.00, 528.00, 1056.00, 2112.00]        
            ]
        }
    }
};