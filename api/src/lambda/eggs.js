import { generateHeaders } from "../utils/generateHeaders";
import EggsUtils from "./contract/EggsUtils.json";
import Web3 from "web3";

const colors = {
  0: "Blue",
  1: "Purple",
  2: "Yellow"
};

const rarities = {
  0: "Common",
  1: "Rare",
  2: "Epic",
  3: "Legendary"
};

const types = {
  0: "A",
  1: "B",
  2: "C"
};

const abbreviateNumber = (numberToAbbreviate, digits) => {
  let newValue = numberToAbbreviate;
  const suffixes = ["", "K", "M", "B","T"];
  let suffixNum = 0;
  while (newValue >= 1000) {
    newValue /= 1000;
    suffixNum++;
  }
  newValue = parseFloat(newValue.toPrecision(digits));
  newValue += suffixes[suffixNum];
  return newValue;
}


const getEggDetails = async (eggId) => {
  const providerString = 'https://harmony-0-rpc.gateway.pokt.network';
  const eggsUtilsAddress = EggsUtils.address;

  let provider = new Web3(
      new Web3.providers.HttpProvider(providerString)
  );

  const eggsUtilsContract = new provider.eth.Contract(EggsUtils.abi, eggsUtilsAddress);
  let currentTimestamp = Math.floor(Date.now() / 1000);

  let {rarity, color, level, reward, colorReward} =
      await eggsUtilsContract.methods.eggDetailsWithRewards(eggId, currentTimestamp).call();

  let colorValue = colors[color];
  let rarityValue = rarities[rarity];
  let type = types[eggId % 3];

  let rewardNumber = Number(Web3.utils .fromWei(reward));
  let colorRewardNumber = Number(Web3.utils .fromWei(colorReward));
  let levelNumber = Number(level) + 1;
  return {
    "tokenId": eggId,
    "type": type,
    "name": "Egg #" + eggId,
    "description": "Moon Robots Egg",
    "image":`https://api.moonrobots.one/images/eggs/egg-${rarityValue}-${colorValue}-${['a', 'b', 'c'][eggId % 3]}.png`.toLowerCase(),
    "attributes": [
      {"trait_type": "Rarity",
        "value": rarityValue},
      {"trait_type": "Color",
        "value": colorValue},
      {"trait_type": "Level",
        "value": levelNumber},
      {"trait_type": "Main Reward",
        "value": `${abbreviateNumber(rewardNumber, 3)} OIL`},
      {"trait_type": "Color Reward",
        "value": `${abbreviateNumber(colorRewardNumber, 3)} OIL`},
    ]};
}

// this uses the callback syntax, however, we encourage you to try the async/await syntax shown in async-dadjoke.js
export function handler(event, context, callback) {
  let data = event.queryStringParameters;

    let type = types[parseInt(data.id) % 3];

    if (data.level) {
      let name = rarities[data.rarity] + "-" +
          colors[data.color] + "-" +
          type + ".png";

      let output = {
        "tokenId": data.id,
        "type": type,
        "name": "Egg #" + data.id,
        "description": "Moon Robots Egg",
        "image":"https://api.moonrobots.one/images/eggs/egg-" + name.toLowerCase(),
        "attributes": [
          {"trait_type": "Rarity",
            "value": rarities[data.rarity]},
          {"trait_type": "Color",
            "value": colors[data.color]},
          {"trait_type": "Level",
            "value": parseInt(data.level) + 1},
        ]};

      callback(null, {
        statusCode: 200,
        headers: generateHeaders(),
        body: JSON.stringify(output),
      })
    } else {
      getEggDetails(data.id).then((details) => {
                                    callback(null, {
                                      statusCode: 200,
                                      headers: generateHeaders(),
                                      body: JSON.stringify(details),
                                    })
                                  }
      );
    }
}
