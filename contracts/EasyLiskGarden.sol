// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract EasyLiskGarden {
    enum GrowthStage { SEED, SPROUT, GROWING, BLOOMING }

    struct Plant {
        uint256 id;
        address owner;
        GrowthStage growthStage;
        uint256 plantedDate;
        uint256 lastWatered;
        uint8 waterLevel;
        bool exists;
        bool isDead;
    }

    Plant public myPlant;

    mapping(uint256 => Plant) public plants;
    mapping(address => uint256[]) public userPlants;

    uint256 public plantCounter;
    address public owner;

    uint256 public constant PLANT_PRICE = 0.001 ether;
    uint256 public constant HARVEST_REWARD = 0.003 ether;

    uint256 public constant STAGE_DURATION = 1 minutes;
    uint256 public constant WATER_DEPlESION = 30 seconds;

    uint8 public constant WATER_DEPLETION_RATE = 2;

    event PlantSeeded(address indexed owner, uint256 indexed plantId);
    event PlantWatered(uint256 indexed plantId, uint8 newWaterLevel);
    event PlantHarvested(uint256 indexed plantId, address indexed owner, uint256 reward);
    event StageAdvanced(uint256 indexed plantId, GrowthStage newStage);
    event PlantDied(uint256 indexed plantId);

    constructor() {
        owner = msg.sender;
    }

    modifier checkBalance() {
        require(msg.value == PLANT_PRICE, "Isufficient Balance");
        _;
    } 

    modifier ownerChecking() {
         require(msg.sender == owner, "Not your plant buddy!");
        _;
    }

    modifier checkPlantExist(uint256 plantId) {
        Plant memory plant = plants[plantId];
        require(plant.exists, "Plant doesn't exist!");
        _;
    }

    modifier checkPlantAliveStatus(uint256 plantId) {
        Plant memory plant = plants[plantId];
        require(!plant.isDead, "Plant already dead");
        _;
    }

    function plantSeed() external payable checkBalance returns(uint256) {
        plantCounter++;

        uint256 plantId = plantCounter;

        myPlant = Plant({
            id: plantId,
            owner: msg.sender,
            waterLevel: 100,
            growthStage: GrowthStage.SEED,
            plantedDate: block.timestamp,
            lastWatered: block.timestamp,
            exists: true,
            isDead: true
        });

        plants[plantCounter] = myPlant;
        userPlants[msg.sender].push(plantId);

        emit PlantSeeded(msg.sender, plantId);

        return plantId;
    }

    function calculateWaterLevel(uint256 plantId) public view returns (uint8) {
        Plant memory plant = plants[plantId];

        if(!plant.exists || plant.isDead) {
            return 0;
        }

        uint256 timeSinceWatered = block.timestamp - plant.lastWatered;
        uint256 depletionIntervals = timeSinceWatered / WATER_DEPlESION;
        uint256 waterLost = depletionIntervals * WATER_DEPLETION_RATE;
        
        if(waterLost >= plant.waterLevel) {
            return 0;
        }

        uint256 result = plant.waterLevel - waterLost;

        return uint8(result);
    }

    function updateWaterLevel(uint256 plantId) internal {
        Plant memory plant = plants[plantId];
        
        uint8 currentWater = calculateWaterLevel(plantId);

        plant.waterLevel = currentWater;

        if (currentWater == 0 && !plant.isDead){
            plant.isDead = true;
            emit PlantDied(plantId);
        }
    }

    function waterPlant(uint256 plantId) external ownerChecking {
        Plant storage plant = plants[plantId];
        
        updateWaterLevel(plantId);
        plant.waterLevel = 100;
        plant.lastWatered = block.timestamp;

        emit PlantWatered(plantId, 100);

        updatePlantStage(plantId);
    }

    function updatePlantStage(uint256 plantId) public ownerChecking checkPlantExist(plantId) {
        Plant storage plant = plants[plantId];

        // require(plant.exists, "Plant doesn't exist!");

        updateWaterLevel(plantId);
        
        if(plant.isDead){
            return;
        }

        uint256 timeSincePlanted = block.timestamp - plant.plantedDate;
        GrowthStage oldStage = plant.growthStage;

        if(timeSincePlanted >= STAGE_DURATION * 3){
            plant.growthStage = GrowthStage.BLOOMING;
        } else if(timeSincePlanted >= STAGE_DURATION * 2){
            plant.growthStage = GrowthStage.GROWING;
        } else if(timeSincePlanted >= STAGE_DURATION) {
            plant.growthStage = GrowthStage.SPROUT;
        } 
        
        if(plant.growthStage != oldStage) {
            emit StageAdvanced(plantId, plant.growthStage);
        }
    }

    function harvestPlant(uint256 plantId) external checkPlantExist(plantId) ownerChecking checkPlantAliveStatus(plantId) {
        Plant memory plant = plants[plantId];

        updatePlantStage(plantId);
        require(plant.growthStage == GrowthStage.BLOOMING);

        plant.exists = false;
        emit PlantHarvested(plantId, owner, HARVEST_REWARD);

        (bool success, ) = msg.sender.call{value: HARVEST_REWARD}("");
        require(success, "transfer failed");
    }

    function getPlant(uint256 plantId) external view returns (Plant memory) {
        Plant memory plant = plants[plantId];
        plant.waterLevel = calculateWaterLevel(plantId);
        return plant;
    }

    function getUserPlants(address user) external view returns (uint256[] memory) {
        return userPlants[user];
    }

    function withdraw() external {
        require(msg.sender == owner, "Bukan owner");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Transfer gagal");
    }

    receive() external payable {}
}