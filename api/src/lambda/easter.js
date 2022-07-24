import { generateHeaders } from "../utils/generateHeaders";

// this uses the callback syntax, however, we encourage you to try the async/await syntax shown in async-dadjoke.js
export function handler(event, context, callback) {
  let data = event.queryStringParameters;

  var id = data.id;
  var type = data.type;
  var output = {};
  var a = {};

  switch(type) {
    case "1":
      a.type = "Gold";
      a.name = "Gold Easter Egg";
      a.image = "egg-gold.png";
      a.eggsToCombine = "5";
      a.combineReward = "Free Mint";
      a.collectAndCombineInto = "collect 5 and combine into a Free Mint";
      break;
    case "4":
      a.type = "Violet";
      a.name = "Violet Easter Egg";
      a.image = "egg-violet.png";
      a.eggsToCombine = "10";
      a.combineReward = "Free Mint";
      a.collectAndCombineInto = "collect 10 and combine into a Free Mint";
      break;
      case "2":
      a.type = "Pink";
      a.name = "Pink Easter Egg";
      a.image = "egg-pink.png";
      a.eggsToCombine = "15";
      a.combineReward = "Free Mint";
      a.collectAndCombineInto = "collect 15 and combine into a Free Mint";
      break;
      case "3":
      a.type = "Blue";
      a.name = "Blue Easter Egg";
      a.image = "egg-blue.png";
      a.eggsToCombine = "20";
      a.combineReward = "Free Mint";
      a.collectAndCombineInto = "collect 20 and combine into a Free Mint";
      break;
    case "5":
      a.type = "Stardust";
      a.name = "Stardust Easter Egg";
      a.image = "egg-stardust.png";
      a.eggsToCombine = "3";
      a.combineReward = "50 STARDUST";
      a.collectAndCombineInto = "collect 3 and combine into 50 STARDUST";
      break;
    default:
  }

  output = {
    "tokenId":id,
    "type":a.type,
    "name":a.name,
    "description":"Moon Robots Easter egg",
    "image":"https://moonrobots.one/easter-egg/" + a.image,
    "attributes":[
      {"trait_type":"Note",
      "value":"later can be burned for STARDUST at https://moonrobots.one/my-tickets"},
      {"trait_type":"STARDUST amount",
      "value":"TBA at https://discord.gg/moonrobots"},
    ]};

  callback(null, {
    statusCode: 200,
    headers: generateHeaders(),
    body: JSON.stringify(output),
  })
}
