import {generateHeaders} from "../utils/generateHeaders";
import Eggs from "./contract/Eggs.json";
import EggsProfitContract from "./contract/EggProfit.json";
import EggColorProfitContract from "./contract/EggColorProfit.json";
import Web3 from "web3";


const getEggDetails = async (eggId) => {
  let colors = {
    0: "Blue",
    1: "Purple",
    2: "Yellow"
  };

  let rarities = {
    0: "Common",
    1: "Rare",
    2: "Epic",
    3: "Legendary"
  };

  let types = {
    0: "A",
    1: "B",
    2: "C"
  };

  let priorities = {
    blue: 0,
    purple: 1,
    yellow: 2
  };


  const providerString = 'https://harmony-0-rpc.gateway.pokt.network';
  const eggsAddress = Eggs.address;
  const eggsProfitAddress = EggsProfitContract.address;
  const eggsColorProfitAddress = EggColorProfitContract.address;

  let provider = new Web3(
      new Web3.providers.HttpProvider(providerString)
  );

  const eggsContract = new provider.eth.Contract(Eggs.abi, eggsAddress);
  const eggProfitContract = new provider.eth.Contract(EggsProfitContract.abi, eggsProfitAddress);
  const eggColorProfitContract = new provider.eth.Contract(EggColorProfitContract.abi, eggsColorProfitAddress);

  let currentTimestamp = Math.floor(Date.now() / 1000);
  let color = await eggsContract.methods.getEggColor(eggId).call();
  let rarity =  await eggsContract.methods.getEggRarity(eggId).call();
  let level = await eggsContract.methods.getEggLevel(eggId).call();
  let oilLevel = await eggsContract.methods.getEggOilLevel(eggId).call();
  let eggProfit = await eggProfitContract.methods.calculateEggReward(eggId, currentTimestamp).call();
  let eggColorProfit = await eggColorProfitContract.methods.calculateEggReward(eggId, currentTimestamp).call();
  let type = types[eggId % 3];
  let priority = priorities[color];
  let colorValue = colors[parseInt(color)];
  let rarityValue = rarities[rarity];

  return {
    id: eggId,
    name: 'Egg#' + eggId,
    color: colorValue,
    rarity: rarityValue,
    type: type,
    priority: priority,
    image: `https://api.moonrobots.one/images/eggs/egg-${rarityValue}-${colorValue}-${['a', 'b', 'c'][eggId % 3]}.png`,
    level: level,
    oilSpent: Number(Web3.utils .fromWei(oilLevel)),
    mainRewardToClaim: Number(Web3.utils .fromWei(eggProfit)),
    colorRewardToClaim: Number(Web3.utils .fromWei(eggColorProfit))
  };
};

// this uses the callback syntax, however, we encourage you to try the async/await syntax shown in async-dadjoke.js
export function handler(event, context, callback) {
  let data = event.queryStringParameters;
  getEggDetails(data.id).then((details) => {
                                callback(null, {
                                  statusCode: 200,
                                  headers: generateHeaders(),
                                  body: JSON.stringify(details),
                                })
                              }
  );

}
