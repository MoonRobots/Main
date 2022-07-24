# Moon Robot Contracts

## Setup 
`npm install -g ganache`  
`npm install -g truffle`  
`npm install -g solhint`  
`npm install`  

Install the ganache and start it. Ensure the port is the same as in `truffle-config.js`

`truffle test`  

In case of using `ganache-cli`, start it in a separate terminal and provide correct port number, for example:  
`ganache -p 7546 -l 8500000 -e 1000000`  

Note that `-l 8500000` is required as some tests use quite a lot of gas

To estimate contracts sizes, compile and run `contract-size` plugin like this:  
`truffle compile`  
`truffle run contract-size`  

## Contracts ABI
For calling contracts using `web3` or other library you need contract ABIs.  
The ABIs are stored in artifact `json` files in the `build/contracts`. Note that you do not need whole artifact file
but only `abi` field from it.  

## Testnet deployment
Logs of Testnet deployment can be found in `test_deployment_X.txt` files.  
Testnet account:  
- Account (ETH-format) `0xf95D9D661917e58Cc7a7284f599854c00080537B`  
- Account (ONE-format) `one1l9we6esezljce3a89p84nxz5cqqgq5mm5fvfyq`  
- Private key `b375f6ba3e3ec45f985fd619b8684527e95522fdf5d574d7373570ca0999414b`
 
 Use the Harmony faucet to add more $ONE for testing [https://faucet.pops.one/](https://faucet.pops.one/)

## Already deployed contracts on Mainnet

- `Whitelist` `0xe03bff4e54f0ad8d6855385d139004f291eed59c`
- `WhitelistExchanger` `0xDA9767cF9738734CcB1c9E71E7c2d567fe2521d8`
    - `owner` `0x1455a010e8231eafa6fa77363bc1e54e648a07ae`
    - `profitAddress` `0xe648579F3ccaB87Fa27E311219dd4Ab91B8e0207`
- `WhitelistExchanger V2` `0xA9D93f36cD916488c71f9643926cEe4A18cD0674`
    - `owner` `0x1455a010e8231eafa6fa77363bc1e54e648a07ae`
    - `profitAddress` `0xe648579F3ccaB87Fa27E311219dd4Ab91B8e0207`
- `StarDust` `0x0C2868befB66144a82eB7a48383082E28f8E34fb`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `minter` `0x32b717a1353520c0F93d3B152BDDC75492034D92` (EggLevelUpgrader)
    - `minter` `0x57cD12ca54A07d58954d53Cae7Ae24da8652880F` (AirDropMinter)
    - `minter` `0x144654786631034CA441E57245f82250cf7A62ad` (EasterPiecesExchanger)
    - `minter` `0xd1E3051F9e39c8ab7281A6a3f51b43a8eCbD46C2` (EggSeller)  
- `Oil`
    - `team` `0xB06ae3ce78376BcC1918FFA189d95109C77C4C8f`
    - **Real**
    - `Oil3` `0x1449Ab6C24Dcf3DbC1971021f465af1B81F48F07`
        - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - **Fake**
    - `Oil1` `0x55C3C55ab580BE0f7c918Df69807C6c6762683b9`
        - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `Oil2` `0x6388E22BDe91455BD0FfD72A9A1BD2337E9d092A`
        - `owner` `0x1455a010e8231eafa6fa77363bc1e54e648a07ae`
    - `Oil4` `0xf46A3bf55e49094694b9C03FA7A6d41059f57Ba5`
        - `owner` `0x1455a010e8231eafa6fa77363bc1e54e648a07ae`
    - `Oil5` `0x1f23975a2B07fd8e4BBF855e75643b22bE8fC213`
        - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `Oil6` `0x1c77180A2417720070404d7CbD2251a20bDE1fD4`
        - `owner` `0x1455a010e8231eafa6fa77363bc1e54e648a07ae`
- `EasterPieces` - `0x8B03e1F545919B3a162bDEbeEcD1f33cb1aee340`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
- `Random` `0x71aceC5ba2576141DB1163B818cBA4235c8C01EE`
- `EasterPieceParameters` `0xE5dbe9A563b83815dEdF1C4a14291B9381aDba94`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
- `EasterPieceMinter` - `0x789092b975351145aB87C2A21A4Cc33d451a9BE9`
    - `owner` `0x1455a010e8231eafa6fa77363bc1e54e648a07ae`
- `EasterPiecesExchanger` `0x144654786631034CA441E57245f82250cf7A62ad`
    - `owner` `0x1455a010e8231eafa6fa77363bc1e54e648a07ae`
- `AirDropMinter` `0xFDd5b8E55f418C397f3701B54C7dE8AdFf0Cc3D2`
    - `owner` `0x1455a010e8231eafa6fa77363bc1e54e648a07ae`
    - `mintable` `0x8B03e1F545919B3a162bDEbeEcD1f33cb1aee340` (EasterPieces)
- `AirDropMinter` `0x57cD12ca54A07d58954d53Cae7Ae24da8652880F`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `mintable` `0x0C2868befB66144a82eB7a48383082E28f8E34fb` (StarDust)
- `Eggs` - `0x14cAd6b4ceC1f1187712273662D9A574Ec630A0A`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`  
    - `minter` - `0xd1E3051F9e39c8ab7281A6a3f51b43a8eCbD46C2` (EggSeller)  
- `Items` - `0xB8fec7Dd50FE1Ca76c0e31F48E0ebBcfA803dE2e`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `minter` `0xd1E3051F9e39c8ab7281A6a3f51b43a8eCbD46C2` (EggSeller)  
    - `minter` `0x4AF69bC1b4695ce7bB382F91373EBB2C067E658f` (ItemSeller)  
- `EggParameters` - `0x8db0Fb5AB2D6CB8cD1d0c990D18c8ffF682B6913`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `generator` - `0xd1E3051F9e39c8ab7281A6a3f51b43a8eCbD46C2` (EggSeller)
- `EggProfit` - `0x40943E47A651f87dc67C7f8de396E6731645b9A9`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `oilRewardAddress` - `0x7217426580E0038Ee4CF6f86F6A0B66653685C17` (50M OIL)  
- `EggColorProfit` - `0x9e1AdF586DcEC8C891A0d7544bf91FEeD27B406E`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `oilRewardAddress` - `0x7217426580E0038Ee4CF6f86F6A0B66653685C17` (50M OIL)  </br>
- `EggLevelUpgrader` - `0x32b717a1353520c0F93d3B152BDDC75492034D92`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `profitAddress` - `0xB06ae3ce78376BcC1918FFA189d95109C77C4C8f` (Treasury)  
- `EggsUtils` - `0x30FB880B8bdEc9056c6216e7B7B3AB623bA09887`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
- `EggSeller` - `0xd1E3051F9e39c8ab7281A6a3f51b43a8eCbD46C2`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `profitAddress` - `0xe648579F3ccaB87Fa27E311219dd4Ab91B8e0207`
    - `parameters` - `0x8db0Fb5AB2D6CB8cD1d0c990D18c8ffF682B6913` (EggParameters)  
- `ItemSeller` - `0x4AF69bC1b4695ce7bB382F91373EBB2C067E658f`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
- `ItemsUtils` - `0x42edF8F6FD87EB005a02E788FF538CE467CEFF35`
    - `owner` `0x1455a010e8231eafa6fa77363bc1e54e648a07ae`
  

## Eggs Migration

- `Eggs2` - `0xeE7fA9bad1aEba2C04Ed39ec52b1f05E42cf93a4`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `burner` `0x8c48F988bB11fc4896dA83Be42d494602c4f4694` (EggMerger)
    - `minter` `0x8c48F988bB11fc4896dA83Be42d494602c4f4694` (EggMerger)
    - `minter` `0x1a2b3d8F4c6aef28B18cdBa4056Af5C502FA0A41` (EggMerger2)
    - `burner` `0x1a2b3d8F4c6aef28B18cdBa4056Af5C502FA0A41` (EggMerger2)
    - `totalSupplyLimit` `20_000`
- `EggParameters2` - `0xEc572d5D1c7b5e72d5EeB038865F3D915cf87CB1`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
- `EggsMigration` - `0x1eF1ed4c75396887FbFeCcc12777c9E42c6790bD`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
- `EggLevelUpgrader2` - `0x9b1459c78B47e026b3ad23989cbfe8dD28E1e03C`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `profitAddress` - `0xB06ae3ce78376BcC1918FFA189d95109C77C4C8f` (Treasury)  
- `EggsUtils2` `0x7D83f32C5c540805b66bC88508D10575f308F540`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
- `EggsUtils3` `0xBC6aD24914F347346091E9DF238B6EC1b847557c`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
- `EggsUtils4` `0x5609e55f0eb5cf6c69ce3758d7274BE2aa48d1eb`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
- `EggProfit2` `0xD5783390271D543b91BD72470e087FaFF6626eAB`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `oilRewardAddress` - `0x7217426580E0038Ee4CF6f86F6A0B66653685C17` (50M OIL)  
- `EggColorProfit2` `0x6476d00767a97341a9EE954D7b603647e9D0cdd8`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `oilRewardAddress` - `0x7217426580E0038Ee4CF6f86F6A0B66653685C17` (50M OIL)  </br>
- `EggColorProfit3` `0x43bBb4948E8c28A3F6aFc0280864b0996270ADbc`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `oilRewardAddress` - `0x7217426580E0038Ee4CF6f86F6A0B66653685C17` (50M OIL)  </br>
- `EggSeller2` - `0xb3F82B7813C805d47eDfd53e3F45636107d1B3b6`
    - `owner` - `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `profitAddress` - `0xe648579F3ccaB87Fa27E311219dd4Ab91B8e0207`
    - `parameters` - `0xEc572d5D1c7b5e72d5EeB038865F3D915cf87CB1` (EggParameters2)  

## Items Migration
- `ItemsUtils2` - `0x59528Ea2fB21B3721eb9d54cda6198256886CeF0`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `Items` `0x46f5A2Dc4F372397Bb2C5877E1988c4D911106A3` (Items2)
- `Items2` - `0x46f5A2Dc4F372397Bb2C5877E1988c4D911106A3`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `minter` `0xE6be3FBf6cDbF9463Bf9047c267B04405Eb76CD4` (ItemSeller2)
    - `minter` `0xA6E235e2cE4A0DE6d06Bf32A0B6A3913b15E302F` (ItemSeller3)
    - `burner` `0xA6E235e2cE4A0DE6d06Bf32A0B6A3913b15E302F` (ItemSeller3)
    - `minter` `0xC41543427E78E5720Da4927E3749bd7F013f03EE` (IvanKraft)
    - `minter` `0x1455a010e8231eafa6fa77363bc1e54e648a07ae` (Sergey)
    - `minter` `0x02cFef5EdC4353d1F44983DCA01d078c9Bae5940` (ExpeditionItemSeller)
    - `minter` `0x74ceAda669134fA6Aa222893ae81aaB9d135280c` (ExpeditionItemMerger)
    - `burner` `0x74ceAda669134fA6Aa222893ae81aaB9d135280c` (ExpeditionItemMerger)
    - `minter` `0x0fc1c0A5f3F0346edbc8509bA907C52D331247dc` (ExpeditionRewards)
    - `minter` `0x5B7a5081555672CF2B1EC225A346D20bF1732529` (ItemsUtils3)
- `ItemSeller2` - `0xE6be3FBf6cDbF9463Bf9047c267B04405Eb76CD4`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `Items` `0x46f5A2Dc4F372397Bb2C5877E1988c4D911106A3` (Items2)
    - `profitAddress` `0xe648579F3ccaB87Fa27E311219dd4Ab91B8e0207`
- `ItemsMigration` - `0xA50de1FA4a2a6449Fa54482F4cc5f556565AddcB`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `oldItems` `0xB8fec7Dd50FE1Ca76c0e31F48E0ebBcfA803dE2e` (Items)
    - `newItems` `0x46f5A2Dc4F372397Bb2C5877E1988c4D911106A3` (Items2)

## LandDeeds Sale
- `ItemSeller3` - `0xA6E235e2cE4A0DE6d06Bf32A0B6A3913b15E302F`  
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `Items` `0x46f5A2Dc4F372397Bb2C5877E1988c4D911106A3` (Items2)
    - `profitAddress` `0xe648579F3ccaB87Fa27E311219dd4Ab91B8e0207`
    - `profitOilAddress` `0xB06ae3ce78376BcC1918FFA189d95109C77C4C8f`
    - `profitStardustAddress` `0xB06ae3ce78376BcC1918FFA189d95109C77C4C8f`
    - `landDeedParameters` `0x0dE174462FD12dd0b1391AECD1E1a39Ec13Ae9cF` (LandDeedParameters)  
- `LandDeedParameters` - `0x0dE174462FD12dd0b1391AECD1E1a39Ec13Ae9cF`
    - `generator` `0xA6E235e2cE4A0DE6d06Bf32A0B6A3913b15E302F` (ItemSeller3)  
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
- `LandDeedBuyCountLimiter` `0x04182AB34BDCdA654E8C5E45B0F48FAEC86abB4c`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `updater` `0xA6E235e2cE4A0DE6d06Bf32A0B6A3913b15E302F` (ItemSeller3)  
- `LandDeedVouchersConsumer` `0x681D37fCC1d8347996e9139CF819e48C99535D94`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `Items` `0x46f5A2Dc4F372397Bb2C5877E1988c4D911106A3` (Items2)
    - `landDeedParameters` `0x0dE174462FD12dd0b1391AECD1E1a39Ec13Ae9cF` (LandDeedParameters)
- `LandDeedBuyCountLimiter2` `0x3a98f4eA23c447Cfb2Bcb1fAdA5911aa465DA0a2`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `updater` `0xA6E235e2cE4A0DE6d06Bf32A0B6A3913b15E302F` (ItemSeller3)  
- `DynamicLandDeedBuyCountLimiter` `0x86c2915a58448189dF066CBB7CCF78089bD4f557`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `updater` `0xA6E235e2cE4A0DE6d06Bf32A0B6A3913b15E302F` (ItemSeller3)  

## Eggs Merging
- `EggMerger` - `0x8c48F988bB11fc4896dA83Be42d494602c4f4694`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
- `EggMerger2` - `0x1a2b3d8F4c6aef28B18cdBa4056Af5C502FA0A41`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `profitOilAddress` `0xB06ae3ce78376BcC1918FFA189d95109C77C4C8f`

## Expeditions
- `ExpeditionItemSeller` - `0x02cFef5EdC4353d1F44983DCA01d078c9Bae5940`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `profitOilAddress` `0xB06ae3ce78376BcC1918FFA189d95109C77C4C8f`
    - `profitStardustAddress` `0xB06ae3ce78376BcC1918FFA189d95109C77C4C8f`
- `ExpeditionItemMerger` - `0x74ceAda669134fA6Aa222893ae81aaB9d135280c`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
- `ExpeditionRewards` - `0x0fc1c0A5f3F0346edbc8509bA907C52D331247dc`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `usersValidatorAddress` `0x4d06C75B2c72368dCDA946CD5f11AcfA7cceF2A2`
- `ItemsUtils3` - `0x5B7a5081555672CF2B1EC225A346D20bF1732529`
    - `owner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d`
    - `minter` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d` (Andrii)
    - `minter` `0x9461535ABA847AA2F78D7752c6E144cBf2a2E43E` (Alex)
    - `minter` `0xC41543427E78E5720Da4927E3749bd7F013f03EE` (IvanKraft)
    - `burner` `0x74C5d8FD5F5f82307676e60Faa316703aAC95C0d` (Andrii)
    - `burner` `0x9461535ABA847AA2F78D7752c6E144cBf2a2E43E` (Alex)
    - `burner` `0xC41543427E78E5720Da4927E3749bd7F013f03EE` (IvanKraft)
