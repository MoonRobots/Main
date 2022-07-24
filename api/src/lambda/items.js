import { generateHeaders } from "../utils/generateHeaders";

// this uses the callback syntax, however, we encourage you to try the async/await syntax shown in async-dadjoke.js
export function handler(event, context, callback) {
  let data = event.queryStringParameters;
    
  
  var types = {

    100: {
      typeName: "Land Deed",
      description: "Will turn into Common Land after Moon Landing",
      image: "https://api.moonrobots.one/images/items/land-deed-common.png",
      attributes: [
        {"trait_type": "Land Rarity",
        "value": "Common"}
      ]},
    101: {
      typeName: "Land Deed",
      description: "Will turn into Rare Land after Moon Landing",
      image: "https://api.moonrobots.one/images/items/land-deed-rare.png",
      attributes: [
        {"trait_type": "Land Rarity",
        "value": "Rare"}
      ]},
    102: {
      typeName: "Land Deed",
      description: "Will turn into Epic Land after Moon Landing",
      image: "https://api.moonrobots.one/images/items/land-deed-epic.png",
      attributes: [
        {"trait_type": "Land Rarity",
        "value": "Epic"}
      ]},
    103: {
      typeName: "Land Deed",
      description: "Will turn into Legendary Land after Moon Landing",
      image: "https://api.moonrobots.one/images/items/land-deed-legendary.png",
      attributes: [
        {"trait_type": "Land Rarity",
        "value": "Legendary"}
      ]},
    500: {
      typeName: "Land Deed Voucher",
      description: "Use to get a Moon Land Deed during Deed Sale",
      image: "https://api.moonrobots.one/images/items/land-deed-voucher.png",
      attributes: [
        {"trait_type": "Free Land Deeds",
        "value": 1}
      ]},
    501: {
      typeName: "Repair Kit Voucher",
      description: "Use to convert into a Repair Kit after Moon Landing",
      image: "https://api.moonrobots.one/images/items/repair-kit-voucher.png",
      attributes: [
        {"trait_type": "Repair Kits",
        "value": 1}
      ]},
    200: {
      typeName: "Tripod",
      description: "Moon Expedition Equipment. Hold in your wallet to find Moon Lands",
      image: "https://api.moonrobots.one/images/items/tripod.png",
      attributes: [
        {"trait_type": "Rarity",
          "value": "Uncommon"},
        {"trait_type": "Search Power",
          "value": "900"}
      ]},
    201: {
      typeName: "Scout",
      description: "Moon Expedition Equipment. Hold in your wallet to find Moon Lands",
      image: "https://api.moonrobots.one/images/items/scout.png",
      attributes: [
        {"trait_type": "Rarity",
          "value": "Rare"},
        {"trait_type": "Search Power",
          "value": "2000"}
      ]},
    202: {
      typeName: "Drone",
      description: "Moon Expedition Equipment. Hold in your wallet to find Moon Lands",
      image: "https://api.moonrobots.one/images/items/drone.png",
      attributes: [
        {"trait_type": "Rarity",
          "value": "Rare"},
        {"trait_type": "Search Power",
          "value": "3500"}
      ]},
    203: {
      typeName: "Lunokhod",
      description: "Moon Expedition Equipment. Hold in your wallet to find Moon Lands",
      image: "https://api.moonrobots.one/images/items/rover.png",
      attributes: [
        {"trait_type": "Rarity",
          "value": "Epic"},
        {"trait_type": "Search Power",
          "value": "7500"}
      ]},
    204: {
      typeName: "Satellite",
      description: "Moon Expedition Equipment. Hold in your wallet to find Moon Lands",
      image: "https://api.moonrobots.one/images/items/satellite.png",
      attributes: [
        {"trait_type": "Rarity",
          "value": "Legendary"},
        {"trait_type": "Search Power",
          "value": "18000"}
      ]},
    250: {
      typeName: "Tripod Part",
      description: "Collect and combine into Tripod",
      image: "https://api.moonrobots.one/images/items/tripod-part.png",
      attributes: [
        {"trait_type": "Rarity",
          "value": "Common"},
        {"trait_type": "Parts to combine",
        "value": "6"}
      ]},
    251: {
      typeName: "Scout Part",
      description: "Collect and combine into Scout",
      image: "https://api.moonrobots.one/images/items/scout-part.png",
      attributes: [
        {"trait_type": "Rarity",
          "value": "Common"},
        {"trait_type": "Parts to combine",
        "value": "6"}
      ]},
    252: {
      typeName: "Drone Part",
      description: "Collect and combine into Drone",
      image: "https://api.moonrobots.one/images/items/drone-part.png",
      attributes: [
        {"trait_type": "Rarity",
          "value": "Uncommon"},
        {"trait_type": "Parts to combine",
        "value": "5"}
      ]},
    253: {
      typeName: "Lunokhod Part",
      description: "Collect and combine into Lunokhod",
      image: "https://api.moonrobots.one/images/items/rover-part.png",
      attributes: [
        {"trait_type": "Rarity",
          "value": "Uncommon"},
        {"trait_type": "Parts to combine",
        "value": "5"}
      ]},
    254: {
      typeName: "Satellite Part",
      description: "Collect and combine into Satellite",
      image: "https://api.moonrobots.one/images/items/satellite-part.png",
      attributes: [
        {"trait_type": "Rarity",
          "value": "Rare"},
        {"trait_type": "Parts to combine",
        "value": "4"}
      ]},
  };

  var output = {};
  
  output = {
    "tokenId": data.id,
    "type": types[data.type].typeName,
    "name": types[data.type].typeName + " #" + data.id,
    "description": types[data.type].description,
    "image": types[data.type].image,
    "attributes": types[data.type].attributes
  };

  callback(null, {
    statusCode: 200,
    headers: generateHeaders(),
    body: JSON.stringify(output),
  })
}
