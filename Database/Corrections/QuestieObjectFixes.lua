QuestieObjectFixes = {...}
-------------------------
--Import modules.
-------------------------
---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB");

-- Further information on how to use this can be found at the wiki
-- https://github.com/AeroScripts/QuestieDev/wiki/Corrections

function QuestieObjectFixes:Load()
    table.insert(QuestieDB.objectData, 400000, {}) -- Adding fake IDs to show additional locations (e.g. Fishing for "Nat Pagle, Angler Extreme")
    table.insert(QuestieDB.objectData, 400001, {})
    table.insert(QuestieDB.objectData, 400002, {})
    table.insert(QuestieDB.objectData, 400003, {})

    return {
        [167] = {
            [QuestieDB.objectKeys.spawns] = {[10]={{33.42,76.35}}},
            [QuestieDB.objectKeys.zoneID] = 10,
        },
        [2712] = {
            [QuestieDB.objectKeys.spawns] = {[45]={{17.6,88.8},{19.4,90.2},{19.6,84.8},{20.6,87.2},{21.1,90.2},{21.1,92.2},{22.4,83.8},{22.4,90},{22.5,83.7},{22.5,90},{22.7,88.4},{22.7,88.6},{22.9,92.1},{23.6,87.4},{23.9,88.4},{23.9,88.5},{24.3,84.6},{24.4,86.4},{24.5,86.4},{24.6,86.5},{24.9,89.3},{24.9,89.5},{25.2,90.6},},},
        },
        [2744] = {
            [QuestieDB.objectKeys.spawns] = {[33]={{23.6,23.4},{23.6,23.5},{23.7,27.2},{23.7,29.8},{23.8,29.1},{24,25.4},{24,25.5},{24.4,28},{24.8,29.5},{24.9,29.1},{25.2,26.9},{25.3,25},{25.3,26.4},{25.3,27.5},{25.4,22.7},{25.4,24.1},{25.7,22.9},{25.7,25.3},{25.8,24.4},{25.8,28.3},{25.9,29.4},{25.9,30.4},{26.1,30.6},{26.3,26.1},{26.4,27.1},{26.5,29.4},{26.5,29.5},{26.6,24.5},{26.8,30.8},{27.1,23.1},{27.1,26.5},{27.2,26.3},{27.3,24},{27.3,27.9},{27.5,24.2},{27.6,25.6},{27.6,29.2},{27.8,23},{27.8,25.3},{27.8,27.7},{28,26.7},},},
        },
        [2867] = {
            [QuestieDB.objectKeys.spawns] = {[3]={{66.6,22}}},
        },
        [10076] = {
            [QuestieDB.objectKeys.spawns] = {[148]={{38.6,86.2}}},
            [QuestieDB.objectKeys.zoneID] = 148,
        },
        [19021] = {
            [QuestieDB.objectKeys.spawns] = {[331]={{69.04,84.77},{77.03,73.8},{79.08,74.48},{70.53,73.58},{70.68,85.06},{69.29,82.67},{71.29,83.83},{77.97,65.82},{77.38,69.77},{77.06,68.3},{69.87,74.11},{78.3,73.6},{76.22,67.48},{76.62,70.67},{76.77,72.19},{78.31,69.73},{68.24,77.68},{77.68,72.63},{74.77,69.6},{78.26,64.58},{70.72,75.24},{74.23,69.47},{74.36,70.21},{75.88,73.52},{75.87,69.99},{69.89,85.32},{74.34,77.92},{70.1,76.08},{74.58,77.19},{74.67,75.39},{76.67,68.46},{68.94,84.86},{74.41,73.38},{74.46,75.56},{73.09,73.23},{71.04,73.8},{71.45,76.97},{73.68,76.95},{72.63,76.86},{70.77,75.99},{72.51,75.12}}},
            [QuestieDB.objectKeys.zoneID] = 331,
        },
        [19869] = {
            [QuestieDB.objectKeys.spawns] = {[400]={{88.42,81.04},{87.27,73.47},{86.89,70.01},{87.86,76.59},{88.0,79.88},{83.75,86.66},{88.22,65.57},{78.4,89.97},{76.31,89.51},{75.39,56.37},{71.01,56.34},{69.6,61.3},{69.9,59},{70,78.4},{70,78.5},{70.1,60.2},{70.1,61.8},{70.1,63.1},{70.1,64.2},{70.2,57.2},{70.2,58},{70.3,66.2},{70.5,59.1},{70.6,77.1},{70.9,79.1},{71,56.4},{71,74.4},{71,74.5},{71.1,72},{71.4,57},{71.4,64.4},{71.4,64.5},{71.6,64.4},{71.6,64.5},{71.6,66.7},{71.6,78},{71.7,68.4},{71.7,68.7},{71.7,80.1},{72.3,56.5},{72.3,62.8},{72.3,70.3},{72.3,76.9},{72.4,56.4},{72.4,72.3},{72.4,74.4},{72.4,74.6},{72.4,80.7},{72.5,72.2},{72.5,72.5},{72.5,80.7},{73.1,55.6},{73.1,59.8},{73.2,55.4},{73.2,68.5},{73.4,57.9},{73.5,57.9},{74,61.1},{74.2,63.7},{74.4,55.4},{74.5,55.4},{74.6,59.6},{75.3,54},{75.4,56.2},{75.4,56.5},{75.5,54},{75.5,56.4},{75.9,55.3},{76.2,86.9},{76.3,89.4},{76.3,89.6},{76.8,84.3},{76.8,85.1},{77,53.2},{77.3,86.4},{77.3,86.5},{77.4,90.4},{77.4,90.5},{77.5,90.6},{77.6,54.1},{77.7,51.8},{77.9,84.2},{77.9,85.3},{78,85.5},{78.3,53},{78.4,55.1},{78.4,89.8},{78.5,90},{79,54.1},{79.2,56.2},{79.4,85.3},{79.4,85.5},{79.4,86.7},{79.5,59},{79.5,85.3},{79.8,55.1},{80,87.9},{80.7,54.3},{80.7,56.3},{80.7,89},{81.4,86.3},{81.5,86.3},{81.9,87.2},{81.9,87.5},{82.2,56.2},{82.2,90},{82.8,85.4},{82.8,85.5},{82.8,87.9},{82.9,55.3},{82.9,64.7},{83.6,56.3},{83.7,86.6},{85.3,58.4},{85.3,58.5},{85.6,61.6},{85.7,61.4},{85.8,62.5},{85.9,57.4},{86,59.7},{86.2,68.6},{86.2,74.4},{86.2,74.6},{86.6,63.5},{86.6,64.7},{86.7,58.3},{86.7,58.5},{86.7,63.4},{86.8,60.9},{86.8,67.9},{86.9,70.1},{86.9,72.3},{87,75.4},{87.1,75.5},{87.2,73.5},{87.3,66.9},{87.3,73.4},{87.6,62.9},{87.6,71.3},{87.7,78},{87.8,76.5},{87.9,60.9},{88,80},{88.1,67.8},{88.2,65.4},{88.2,65.7},{88.2,74.9},{88.4,80.9},{88.6,76.8},{88.8,66.4},{88.8,66.6},},},
        },
        [19870] = {
            [QuestieDB.objectKeys.spawns] = {[400]={{87.75,78.07},{88.18,67.74},{85.64,61.5},{79.38,85.41},{77.96,85.39},{78.35,55.15},{73.44,57.79},{73.97,61.17},{70.6,59.13},{72.34,62.76},{69.7,61.1},{69.9,59},{70,63.1},{70,78.4},{70,78.5},{70.1,64.4},{70.1,64.5},{70.2,60.1},{70.2,62},{70.3,57.1},{70.3,58},{70.3,66.3},{70.5,59.2},{70.7,76.9},{70.8,79.2},{71,56.4},{71,71.9},{71,74.4},{71,74.6},{71.4,57},{71.4,64.4},{71.4,64.5},{71.5,64.4},{71.5,64.5},{71.6,66.5},{71.6,78.2},{71.6,80},{71.7,68.5},{72.3,56.6},{72.3,70.2},{72.3,74.4},{72.3,76.7},{72.4,56.4},{72.4,62.7},{72.4,74.6},{72.5,72.4},{72.5,80.7},{73.1,55.4},{73.1,59.6},{73.2,55.6},{73.2,68.7},{73.4,57.8},{73.5,57.7},{74,61.1},{74.2,63.7},{74.4,55.3},{74.5,55.4},{74.7,59.7},{75.4,54},{75.4,56.3},{75.5,53.9},{76,55.3},{76.1,87},{76.2,89.5},{76.3,89.4},{76.8,84.3},{76.8,85.1},{77,53.2},{77.3,86.5},{77.4,86.4},{77.4,90.4},{77.4,90.6},{77.5,54},{77.5,90.4},{77.5,90.5},{77.6,51.8},{77.8,84.3},{77.9,85.5},{78,85.3},{78.3,53},{78.4,55.2},{79.1,54.1},{79.3,56.2},{79.3,86.5},{79.4,85.3},{79.4,85.5},{79.5,59.1},{79.8,55.3},{79.9,88},{80.7,54.2},{80.7,56.3},{80.8,89.2},{81.4,86.2},{81.5,86.3},{81.9,87.3},{81.9,87.5},{82.2,56.2},{82.3,90},{82.8,55.3},{82.8,85.4},{82.8,85.5},{82.8,87.9},{82.9,64.6},{83.6,56.2},{83.7,86.6},{85.3,58.4},{85.3,58.5},{85.6,61.4},{85.7,61.5},{85.7,62.5},{85.9,57.4},{86,59.7},{86.1,68.7},{86.1,74.4},{86.2,74.5},{86.6,63.3},{86.6,63.5},{86.6,64.7},{86.7,58.4},{86.7,58.5},{86.7,60.9},{86.8,67.9},{86.9,70.1},{86.9,72.3},{87,75.4},{87.1,75.5},{87.2,73.5},{87.3,66.9},{87.3,73.4},{87.5,71.3},{87.6,62.9},{87.8,78},{87.9,60.9},{87.9,76.5},{88,79.8},{88.1,67.8},{88.3,65.6},{88.3,75.1},{88.4,81},{88.6,76.8},{88.8,66.4},{88.8,66.5},},},
        },
        [92423] = {
            [QuestieDB.objectKeys.spawns] = {[400]={{43.4, 32.7}},[17]={{49.02,96.77}}},
            [QuestieDB.objectKeys.zoneID] = 400,
        },
        [144052] = {
            [QuestieDB.objectKeys.spawns] = {[440]={{39,29}}},
            [QuestieDB.objectKeys.zoneID] = 440,
        },
        [144064] = {
            [QuestieDB.objectKeys.spawns] = {[357]={{74.3,29},{74.6,30.2},{75.1,32.4},{75.1,32.5},{75.3,28.2},{75.3,33.7},{75.5,30.4},{75.5,30.5},{76,29},{76.3,34.4},{76.4,33.1},{76.4,34.5},{76.5,33.1},{76.7,33.8},{76.9,29.7},{77.5,35.1},{78.4,34},{78.5,34},{79.2,34.9},{80.4,34.3},{80.4,36},{80.5,34.2},{81,35.4},{81,35.5},{81.6,35},},}, -- #1160
            [QuestieDB.objectKeys.zoneID] = 357,
        },
        [148513] = {
            [QuestieDB.objectKeys.spawns] = {[16]={{34,59.9},{35.5,49.5},{36.3,60.6},{36.44,54.05},{36.26,62.2},{37.43,60.66},{38.32,53.41},{38.4,53.5},{38.7,63.3},{42.24,64.63},},},
        },
        [148514] = {
            [QuestieDB.objectKeys.spawns] = {[16]={{34.2,57.8},{34.65,55.61},{35.7,56.51},{35.9,59},{36.2,52.6},{37.92,47.75},{39.3,57.6},{39.8,48.8},{39.84,45.88},{39.99,64.19},{40.2,45},},},
        },
        [148515] = {
            [QuestieDB.objectKeys.spawns] = {[16]={{35.6,55.9},{35.9,53.5},{36.1,59.9},{36.9,49.6},{37,54.5},{37.14,60.51},{37.29,48.08},{38.58,54.62},{38.6,47.5},{39.3,59.9},{41.51,65.04},},},
        },
        [148516] = {
            [QuestieDB.objectKeys.spawns] = {[16]={{34.1,50.5},{34.3,55.2},{35.19,58.02},{36,57.6},{36.8,60.5},{37.07,51.86},{38.4,60.3},{38.91,53.46},{39.54,64.32},{39.6,48.14},},},
        },
        [153123] = {
            [QuestieDB.objectKeys.spawns] = {[16]={{56.1,30.1},{56.3,28.8},{56.4,28.4},{56.5,28.8},{57.0,28.4},{57.0,29.9},{57.9,29.1},{58.2,27.7},{58.4,25.0},{58.5,25.0},{58.6,26.0},{58.6,29.1},{58.9,28.4},{59.2,23.0},{59.6,30.9},},}, --#1413
        },
        [154357] = {
            [QuestieDB.objectKeys.spawns] = {[44]={{21.9,53.2},{24.1,54.6},{25.9,54.1},{26.4,51.3},{28,56},{30.8,54.3},{33.6,55.2},{36.8,54.3},{37.9,54.5},{19.16,51.74},{34.13,53.37},{29.52,53.72},},}, -- #1176
        },
        -- Un'Goro Crystals
        [164658] = {
            [QuestieDB.objectKeys.spawns] = {[490]={{19.7,38.9},{20.7,50},{23,59.1},{23.1,40.3},{23.7,59},{24,42.8},{25.1,67.0},{25.5,39.9},{25.8,53.9},{25.8,63.3},{26.0,59.9},{27.5,70.1},{27.7,46.3},{27.7,46.5},{30.1,21.3},{30.4,70.5},{30.7,63.3},{32.6,73.5},{33,29.7},{33.8,44.4},{33.9,76.7},{35.8,54.5},{37.7,20.4},{37.7,20.5},{37.8,66.4},{37.8,66.5},{38,41.8},{38.2,81.9},{39.3,14.5},{39.7,26.8},{40.5,49.9},{40.5,75.3},{40.8,79.9},{42.6,34.1},{42.8,86.1},{42.9,52.9},{42.9,66},{43,45.4},{43,45.5},{43.8,16.7},{43.9,21.3},{43.9,21.5},{44.2,88.8},{45.4,38.6},{45.4,66},{45.5,66},{45.7,92.5},{46.3,19.7},{46.8,14.9},{47,61.1},{47.3,13},{49.9,15.7},{50,92.3},{51.3,61.4},{51.6,13.6},{51.8,34.9},{51.9,87.5},{53.7,38.9},{54.1,18.1},{55.8,7.9},{56,18.5},{56.1,18.4},{56.2,60.6},{56.3,73.6},{56.4,12.3},{56.6,12.3},{56.8,76.2},{57.3,10.1},{57.4,82.5},{58.1,8.8},{58.1,49.8},{58.3,10.7},{58.3,65.9},{58.6,78.4},{59.2,20.3},{59.6,60.2},{59.8,49.4},{60.4,77.4},{60.9,68.4},{60.9,68.5},{61,15.1},{62,85.2},{62.1,40.4},{62.1,40.5},{62.3,68.4},{62.4,68.5},{62.4,70.3},{62.4,70.5},{62.6,16.7},{62.6,26.9},{63.2,75.2},{63.4,23},{64.2,53.9},{65.2,79.7},{66.1,21.1},{66.7,46.9},{66.8,73.3},{67.7,40.4},{67.7,40.5},{67.9,51.4},{68.3,25.3},{68.4,25.5},{68.4,59.7},{69.1,28.9},{69.4,79.9},{69.5,79.9},{69.6,35.1},{69.6,69.4},{69.6,69.5},{69.9,18.9},{70.1,77.1},{70.3,64.2},{71.1,42.9},{71.6,73.6},{71.7,63.5},{71.8,63.4},{71.9,23},{72.1,33.1},{72.2,21.1},{72.4,35.4},{72.4,35.6},{73,46.8},{73,65.4},{73,65.5},{73.8,53.4},{73.8,53.5},{74.4,56.9},{74.4,63.8},{74.5,57},{74.5,63.8},{74.8,29.6},{74.8,58.9},{74.9,70.5},{75.1,37.7},{75.2,61.6},{75.3,61.4},{75.9,40.1},{76.6,43.8},{76.8,57.7},{78.2,40.1},{79.3,57.9},{79.9,61.9},{80.4,49.7},{80.5,49.7},{80.7,43},{81.4,39.1},{81.5,39.1},{81.6,60.6},},}, -- #1156
        },
        [164659] = {
            [QuestieDB.objectKeys.spawns] = {[490]={{19.7,38.9},{20.7,50},{23,59.1},{23.1,40.3},{23.7,59},{24,42.8},{25.1,67.0},{25.5,39.9},{25.8,53.9},{25.8,63.3},{26.0,59.9},{27.5,70.1},{27.7,46.3},{27.7,46.5},{30.1,21.3},{30.4,70.5},{30.7,63.3},{32.6,73.5},{33,29.7},{33.8,44.4},{33.9,76.7},{35.8,54.5},{37.7,20.4},{37.7,20.5},{37.8,66.4},{37.8,66.5},{38,41.8},{38.2,81.9},{39.3,14.5},{39.7,26.8},{40.5,49.9},{40.5,75.3},{40.8,79.9},{42.6,34.1},{42.8,86.1},{42.9,52.9},{42.9,66},{43,45.4},{43,45.5},{43.8,16.7},{43.9,21.3},{43.9,21.5},{44.2,88.8},{45.4,38.6},{45.4,66},{45.5,66},{45.7,92.5},{46.3,19.7},{46.8,14.9},{47,61.1},{47.3,13},{49.9,15.7},{50,92.3},{51.3,61.4},{51.6,13.6},{51.8,34.9},{51.9,87.5},{53.7,38.9},{54.1,18.1},{55.8,7.9},{56,18.5},{56.1,18.4},{56.2,60.6},{56.3,73.6},{56.4,12.3},{56.6,12.3},{56.8,76.2},{57.3,10.1},{57.4,82.5},{58.1,8.8},{58.1,49.8},{58.3,10.7},{58.3,65.9},{58.6,78.4},{59.2,20.3},{59.6,60.2},{59.8,49.4},{60.4,77.4},{60.9,68.4},{60.9,68.5},{61,15.1},{62,85.2},{62.1,40.4},{62.1,40.5},{62.3,68.4},{62.4,68.5},{62.4,70.3},{62.4,70.5},{62.6,16.7},{62.6,26.9},{63.2,75.2},{63.4,23},{64.2,53.9},{65.2,79.7},{66.1,21.1},{66.7,46.9},{66.8,73.3},{67.7,40.4},{67.7,40.5},{67.9,51.4},{68.3,25.3},{68.4,25.5},{68.4,59.7},{69.1,28.9},{69.4,79.9},{69.5,79.9},{69.6,35.1},{69.6,69.4},{69.6,69.5},{69.9,18.9},{70.1,77.1},{70.3,64.2},{71.1,42.9},{71.6,73.6},{71.7,63.5},{71.8,63.4},{71.9,23},{72.1,33.1},{72.2,21.1},{72.4,35.4},{72.4,35.6},{73,46.8},{73,65.4},{73,65.5},{73.8,53.4},{73.8,53.5},{74.4,56.9},{74.4,63.8},{74.5,57},{74.5,63.8},{74.8,29.6},{74.8,58.9},{74.9,70.5},{75.1,37.7},{75.2,61.6},{75.3,61.4},{75.9,40.1},{76.6,43.8},{76.8,57.7},{78.2,40.1},{79.3,57.9},{79.9,61.9},{80.4,49.7},{80.5,49.7},{80.7,43},{81.4,39.1},{81.5,39.1},{81.6,60.6},},}, -- #1156
        },
        [164660] = {
            [QuestieDB.objectKeys.spawns] = {[490]={{19.7,38.9},{20.7,50},{23,59.1},{23.1,40.3},{23.7,59},{24,42.8},{25.1,67.0},{25.5,39.9},{25.8,53.9},{25.8,63.3},{26.0,59.9},{27.5,70.1},{27.7,46.3},{27.7,46.5},{30.1,21.3},{30.4,70.5},{30.7,63.3},{32.6,73.5},{33,29.7},{33.8,44.4},{33.9,76.7},{35.8,54.5},{37.7,20.4},{37.7,20.5},{37.8,66.4},{37.8,66.5},{38,41.8},{38.2,81.9},{39.3,14.5},{39.7,26.8},{40.5,49.9},{40.5,75.3},{40.8,79.9},{42.6,34.1},{42.8,86.1},{42.9,52.9},{42.9,66},{43,45.4},{43,45.5},{43.8,16.7},{43.9,21.3},{43.9,21.5},{44.2,88.8},{45.4,38.6},{45.4,66},{45.5,66},{45.7,92.5},{46.3,19.7},{46.8,14.9},{47,61.1},{47.3,13},{49.9,15.7},{50,92.3},{51.3,61.4},{51.6,13.6},{51.8,34.9},{51.9,87.5},{53.7,38.9},{54.1,18.1},{55.8,7.9},{56,18.5},{56.1,18.4},{56.2,60.6},{56.3,73.6},{56.4,12.3},{56.6,12.3},{56.8,76.2},{57.3,10.1},{57.4,82.5},{58.1,8.8},{58.1,49.8},{58.3,10.7},{58.3,65.9},{58.6,78.4},{59.2,20.3},{59.6,60.2},{59.8,49.4},{60.4,77.4},{60.9,68.4},{60.9,68.5},{61,15.1},{62,85.2},{62.1,40.4},{62.1,40.5},{62.3,68.4},{62.4,68.5},{62.4,70.3},{62.4,70.5},{62.6,16.7},{62.6,26.9},{63.2,75.2},{63.4,23},{64.2,53.9},{65.2,79.7},{66.1,21.1},{66.7,46.9},{66.8,73.3},{67.7,40.4},{67.7,40.5},{67.9,51.4},{68.3,25.3},{68.4,25.5},{68.4,59.7},{69.1,28.9},{69.4,79.9},{69.5,79.9},{69.6,35.1},{69.6,69.4},{69.6,69.5},{69.9,18.9},{70.1,77.1},{70.3,64.2},{71.1,42.9},{71.6,73.6},{71.7,63.5},{71.8,63.4},{71.9,23},{72.1,33.1},{72.2,21.1},{72.4,35.4},{72.4,35.6},{73,46.8},{73,65.4},{73,65.5},{73.8,53.4},{73.8,53.5},{74.4,56.9},{74.4,63.8},{74.5,57},{74.5,63.8},{74.8,29.6},{74.8,58.9},{74.9,70.5},{75.1,37.7},{75.2,61.6},{75.3,61.4},{75.9,40.1},{76.6,43.8},{76.8,57.7},{78.2,40.1},{79.3,57.9},{79.9,61.9},{80.4,49.7},{80.5,49.7},{80.7,43},{81.4,39.1},{81.5,39.1},{81.6,60.6},},}, -- #1156
        },
        [164661] = {
            [QuestieDB.objectKeys.spawns] = {[490]={{19.7,38.9},{20.7,50},{23,59.1},{23.1,40.3},{23.7,59},{24,42.8},{25.1,67.0},{25.5,39.9},{25.8,53.9},{25.8,63.3},{26.0,59.9},{27.5,70.1},{27.7,46.3},{27.7,46.5},{30.1,21.3},{30.4,70.5},{30.7,63.3},{32.6,73.5},{33,29.7},{33.8,44.4},{33.9,76.7},{35.8,54.5},{37.7,20.4},{37.7,20.5},{37.8,66.4},{37.8,66.5},{38,41.8},{38.2,81.9},{39.3,14.5},{39.7,26.8},{40.5,49.9},{40.5,75.3},{40.8,79.9},{42.6,34.1},{42.8,86.1},{42.9,52.9},{42.9,66},{43,45.4},{43,45.5},{43.8,16.7},{43.9,21.3},{43.9,21.5},{44.2,88.8},{45.4,38.6},{45.4,66},{45.5,66},{45.7,92.5},{46.3,19.7},{46.8,14.9},{47,61.1},{47.3,13},{49.9,15.7},{50,92.3},{51.3,61.4},{51.6,13.6},{51.8,34.9},{51.9,87.5},{53.7,38.9},{54.1,18.1},{55.8,7.9},{56,18.5},{56.1,18.4},{56.2,60.6},{56.3,73.6},{56.4,12.3},{56.6,12.3},{56.8,76.2},{57.3,10.1},{57.4,82.5},{58.1,8.8},{58.1,49.8},{58.3,10.7},{58.3,65.9},{58.6,78.4},{59.2,20.3},{59.6,60.2},{59.8,49.4},{60.4,77.4},{60.9,68.4},{60.9,68.5},{61,15.1},{62,85.2},{62.1,40.4},{62.1,40.5},{62.3,68.4},{62.4,68.5},{62.4,70.3},{62.4,70.5},{62.6,16.7},{62.6,26.9},{63.2,75.2},{63.4,23},{64.2,53.9},{65.2,79.7},{66.1,21.1},{66.7,46.9},{66.8,73.3},{67.7,40.4},{67.7,40.5},{67.9,51.4},{68.3,25.3},{68.4,25.5},{68.4,59.7},{69.1,28.9},{69.4,79.9},{69.5,79.9},{69.6,35.1},{69.6,69.4},{69.6,69.5},{69.9,18.9},{70.1,77.1},{70.3,64.2},{71.1,42.9},{71.6,73.6},{71.7,63.5},{71.8,63.4},{71.9,23},{72.1,33.1},{72.2,21.1},{72.4,35.4},{72.4,35.6},{73,46.8},{73,65.4},{73,65.5},{73.8,53.4},{73.8,53.5},{74.4,56.9},{74.4,63.8},{74.5,57},{74.5,63.8},{74.8,29.6},{74.8,58.9},{74.9,70.5},{75.1,37.7},{75.2,61.6},{75.3,61.4},{75.9,40.1},{76.6,43.8},{76.8,57.7},{78.2,40.1},{79.3,57.9},{79.9,61.9},{80.4,49.7},{80.5,49.7},{80.7,43},{81.4,39.1},{81.5,39.1},{81.6,60.6},},}, -- #1156
        },
        [164778] = {
            [QuestieDB.objectKeys.spawns] = {[490]={{19.7,38.9},{20.7,50},{23,59.1},{23.1,40.3},{23.7,59},{24,42.8},{25.1,67.0},{25.5,39.9},{25.8,53.9},{25.8,63.3},{26.0,59.9},{27.5,70.1},{27.7,46.3},{27.7,46.5},{30.1,21.3},{30.4,70.5},{30.7,63.3},{32.6,73.5},{33,29.7},{33.8,44.4},{33.9,76.7},{35.8,54.5},{37.7,20.4},{37.7,20.5},{37.8,66.4},{37.8,66.5},{38,41.8},{38.2,81.9},{39.3,14.5},{39.7,26.8},{40.5,49.9},{40.5,75.3},{40.8,79.9},{42.6,34.1},{42.8,86.1},{42.9,52.9},{42.9,66},{43,45.4},{43,45.5},{43.8,16.7},{43.9,21.3},{43.9,21.5},{44.2,88.8},{45.4,38.6},{45.4,66},{45.5,66},{45.7,92.5},{46.3,19.7},{46.8,14.9},{47,61.1},{47.3,13},{49.9,15.7},{50,92.3},{51.3,61.4},{51.6,13.6},{51.8,34.9},{51.9,87.5},{53.7,38.9},{54.1,18.1},{55.8,7.9},{56,18.5},{56.1,18.4},{56.2,60.6},{56.3,73.6},{56.4,12.3},{56.6,12.3},{56.8,76.2},{57.3,10.1},{57.4,82.5},{58.1,8.8},{58.1,49.8},{58.3,10.7},{58.3,65.9},{58.6,78.4},{59.2,20.3},{59.6,60.2},{59.8,49.4},{60.4,77.4},{60.9,68.4},{60.9,68.5},{61,15.1},{62,85.2},{62.1,40.4},{62.1,40.5},{62.3,68.4},{62.4,68.5},{62.4,70.3},{62.4,70.5},{62.6,16.7},{62.6,26.9},{63.2,75.2},{63.4,23},{64.2,53.9},{65.2,79.7},{66.1,21.1},{66.7,46.9},{66.8,73.3},{67.7,40.4},{67.7,40.5},{67.9,51.4},{68.3,25.3},{68.4,25.5},{68.4,59.7},{69.1,28.9},{69.4,79.9},{69.5,79.9},{69.6,35.1},{69.6,69.4},{69.6,69.5},{69.9,18.9},{70.1,77.1},{70.3,64.2},{71.1,42.9},{71.6,73.6},{71.7,63.5},{71.8,63.4},{71.9,23},{72.1,33.1},{72.2,21.1},{72.4,35.4},{72.4,35.6},{73,46.8},{73,65.4},{73,65.5},{73.8,53.4},{73.8,53.5},{74.4,56.9},{74.4,63.8},{74.5,57},{74.5,63.8},{74.8,29.6},{74.8,58.9},{74.9,70.5},{75.1,37.7},{75.2,61.6},{75.3,61.4},{75.9,40.1},{76.6,43.8},{76.8,57.7},{78.2,40.1},{79.3,57.9},{79.9,61.9},{80.4,49.7},{80.5,49.7},{80.7,43},{81.4,39.1},{81.5,39.1},{81.6,60.6},},}, -- #1156
        },
        [164779] = {
            [QuestieDB.objectKeys.spawns] = {[490]={{19.7,38.9},{20.7,50},{23,59.1},{23.1,40.3},{23.7,59},{24,42.8},{25.1,67.0},{25.5,39.9},{25.8,53.9},{25.8,63.3},{26.0,59.9},{27.5,70.1},{27.7,46.3},{27.7,46.5},{30.1,21.3},{30.4,70.5},{30.7,63.3},{32.6,73.5},{33,29.7},{33.8,44.4},{33.9,76.7},{35.8,54.5},{37.7,20.4},{37.7,20.5},{37.8,66.4},{37.8,66.5},{38,41.8},{38.2,81.9},{39.3,14.5},{39.7,26.8},{40.5,49.9},{40.5,75.3},{40.8,79.9},{42.6,34.1},{42.8,86.1},{42.9,52.9},{42.9,66},{43,45.4},{43,45.5},{43.8,16.7},{43.9,21.3},{43.9,21.5},{44.2,88.8},{45.4,38.6},{45.4,66},{45.5,66},{45.7,92.5},{46.3,19.7},{46.8,14.9},{47,61.1},{47.3,13},{49.9,15.7},{50,92.3},{51.3,61.4},{51.6,13.6},{51.8,34.9},{51.9,87.5},{53.7,38.9},{54.1,18.1},{55.8,7.9},{56,18.5},{56.1,18.4},{56.2,60.6},{56.3,73.6},{56.4,12.3},{56.6,12.3},{56.8,76.2},{57.3,10.1},{57.4,82.5},{58.1,8.8},{58.1,49.8},{58.3,10.7},{58.3,65.9},{58.6,78.4},{59.2,20.3},{59.6,60.2},{59.8,49.4},{60.4,77.4},{60.9,68.4},{60.9,68.5},{61,15.1},{62,85.2},{62.1,40.4},{62.1,40.5},{62.3,68.4},{62.4,68.5},{62.4,70.3},{62.4,70.5},{62.6,16.7},{62.6,26.9},{63.2,75.2},{63.4,23},{64.2,53.9},{65.2,79.7},{66.1,21.1},{66.7,46.9},{66.8,73.3},{67.7,40.4},{67.7,40.5},{67.9,51.4},{68.3,25.3},{68.4,25.5},{68.4,59.7},{69.1,28.9},{69.4,79.9},{69.5,79.9},{69.6,35.1},{69.6,69.4},{69.6,69.5},{69.9,18.9},{70.1,77.1},{70.3,64.2},{71.1,42.9},{71.6,73.6},{71.7,63.5},{71.8,63.4},{71.9,23},{72.1,33.1},{72.2,21.1},{72.4,35.4},{72.4,35.6},{73,46.8},{73,65.4},{73,65.5},{73.8,53.4},{73.8,53.5},{74.4,56.9},{74.4,63.8},{74.5,57},{74.5,63.8},{74.8,29.6},{74.8,58.9},{74.9,70.5},{75.1,37.7},{75.2,61.6},{75.3,61.4},{75.9,40.1},{76.6,43.8},{76.8,57.7},{78.2,40.1},{79.3,57.9},{79.9,61.9},{80.4,49.7},{80.5,49.7},{80.7,43},{81.4,39.1},{81.5,39.1},{81.6,60.6},},}, -- #1156
        },
        [164780] = {
            [QuestieDB.objectKeys.spawns] = {[490]={{19.7,38.9},{20.7,50},{23,59.1},{23.1,40.3},{23.7,59},{24,42.8},{25.1,67.0},{25.5,39.9},{25.8,53.9},{25.8,63.3},{26.0,59.9},{27.5,70.1},{27.7,46.3},{27.7,46.5},{30.1,21.3},{30.4,70.5},{30.7,63.3},{32.6,73.5},{33,29.7},{33.8,44.4},{33.9,76.7},{35.8,54.5},{37.7,20.4},{37.7,20.5},{37.8,66.4},{37.8,66.5},{38,41.8},{38.2,81.9},{39.3,14.5},{39.7,26.8},{40.5,49.9},{40.5,75.3},{40.8,79.9},{42.6,34.1},{42.8,86.1},{42.9,52.9},{42.9,66},{43,45.4},{43,45.5},{43.8,16.7},{43.9,21.3},{43.9,21.5},{44.2,88.8},{45.4,38.6},{45.4,66},{45.5,66},{45.7,92.5},{46.3,19.7},{46.8,14.9},{47,61.1},{47.3,13},{49.9,15.7},{50,92.3},{51.3,61.4},{51.6,13.6},{51.8,34.9},{51.9,87.5},{53.7,38.9},{54.1,18.1},{55.8,7.9},{56,18.5},{56.1,18.4},{56.2,60.6},{56.3,73.6},{56.4,12.3},{56.6,12.3},{56.8,76.2},{57.3,10.1},{57.4,82.5},{58.1,8.8},{58.1,49.8},{58.3,10.7},{58.3,65.9},{58.6,78.4},{59.2,20.3},{59.6,60.2},{59.8,49.4},{60.4,77.4},{60.9,68.4},{60.9,68.5},{61,15.1},{62,85.2},{62.1,40.4},{62.1,40.5},{62.3,68.4},{62.4,68.5},{62.4,70.3},{62.4,70.5},{62.6,16.7},{62.6,26.9},{63.2,75.2},{63.4,23},{64.2,53.9},{65.2,79.7},{66.1,21.1},{66.7,46.9},{66.8,73.3},{67.7,40.4},{67.7,40.5},{67.9,51.4},{68.3,25.3},{68.4,25.5},{68.4,59.7},{69.1,28.9},{69.4,79.9},{69.5,79.9},{69.6,35.1},{69.6,69.4},{69.6,69.5},{69.9,18.9},{70.1,77.1},{70.3,64.2},{71.1,42.9},{71.6,73.6},{71.7,63.5},{71.8,63.4},{71.9,23},{72.1,33.1},{72.2,21.1},{72.4,35.4},{72.4,35.6},{73,46.8},{73,65.4},{73,65.5},{73.8,53.4},{73.8,53.5},{74.4,56.9},{74.4,63.8},{74.5,57},{74.5,63.8},{74.8,29.6},{74.8,58.9},{74.9,70.5},{75.1,37.7},{75.2,61.6},{75.3,61.4},{75.9,40.1},{76.6,43.8},{76.8,57.7},{78.2,40.1},{79.3,57.9},{79.9,61.9},{80.4,49.7},{80.5,49.7},{80.7,43},{81.4,39.1},{81.5,39.1},{81.6,60.6},},}, -- #1156
        },
        [164781] = {
            [QuestieDB.objectKeys.spawns] = {[490]={{19.7,38.9},{20.7,50},{23,59.1},{23.1,40.3},{23.7,59},{24,42.8},{25.1,67.0},{25.5,39.9},{25.8,53.9},{25.8,63.3},{26.0,59.9},{27.5,70.1},{27.7,46.3},{27.7,46.5},{30.1,21.3},{30.4,70.5},{30.7,63.3},{32.6,73.5},{33,29.7},{33.8,44.4},{33.9,76.7},{35.8,54.5},{37.7,20.4},{37.7,20.5},{37.8,66.4},{37.8,66.5},{38,41.8},{38.2,81.9},{39.3,14.5},{39.7,26.8},{40.5,49.9},{40.5,75.3},{40.8,79.9},{42.6,34.1},{42.8,86.1},{42.9,52.9},{42.9,66},{43,45.4},{43,45.5},{43.8,16.7},{43.9,21.3},{43.9,21.5},{44.2,88.8},{45.4,38.6},{45.4,66},{45.5,66},{45.7,92.5},{46.3,19.7},{46.8,14.9},{47,61.1},{47.3,13},{49.9,15.7},{50,92.3},{51.3,61.4},{51.6,13.6},{51.8,34.9},{51.9,87.5},{53.7,38.9},{54.1,18.1},{55.8,7.9},{56,18.5},{56.1,18.4},{56.2,60.6},{56.3,73.6},{56.4,12.3},{56.6,12.3},{56.8,76.2},{57.3,10.1},{57.4,82.5},{58.1,8.8},{58.1,49.8},{58.3,10.7},{58.3,65.9},{58.6,78.4},{59.2,20.3},{59.6,60.2},{59.8,49.4},{60.4,77.4},{60.9,68.4},{60.9,68.5},{61,15.1},{62,85.2},{62.1,40.4},{62.1,40.5},{62.3,68.4},{62.4,68.5},{62.4,70.3},{62.4,70.5},{62.6,16.7},{62.6,26.9},{63.2,75.2},{63.4,23},{64.2,53.9},{65.2,79.7},{66.1,21.1},{66.7,46.9},{66.8,73.3},{67.7,40.4},{67.7,40.5},{67.9,51.4},{68.3,25.3},{68.4,25.5},{68.4,59.7},{69.1,28.9},{69.4,79.9},{69.5,79.9},{69.6,35.1},{69.6,69.4},{69.6,69.5},{69.9,18.9},{70.1,77.1},{70.3,64.2},{71.1,42.9},{71.6,73.6},{71.7,63.5},{71.8,63.4},{71.9,23},{72.1,33.1},{72.2,21.1},{72.4,35.4},{72.4,35.6},{73,46.8},{73,65.4},{73,65.5},{73.8,53.4},{73.8,53.5},{74.4,56.9},{74.4,63.8},{74.5,57},{74.5,63.8},{74.8,29.6},{74.8,58.9},{74.9,70.5},{75.1,37.7},{75.2,61.6},{75.3,61.4},{75.9,40.1},{76.6,43.8},{76.8,57.7},{78.2,40.1},{79.3,57.9},{79.9,61.9},{80.4,49.7},{80.5,49.7},{80.7,43},{81.4,39.1},{81.5,39.1},{81.6,60.6},},}, -- #1156
        },
        -------------------
        [174848] = {
            [QuestieDB.objectKeys.spawns] = {[1497]={{47.85,73.48},},}, -- #1520
        },
        [175265] = {
            [QuestieDB.objectKeys.spawns] = {[1497]={{47.74,73.57},},}, -- #1520
        },
        [176630] = {
            [QuestieDB.objectKeys.spawns] = {[45]={{17.91,69.41},{18.5,66.2},{19.4,64.5},{20.8,65.8},{27.6,66.0},{29.3,64.9},{29.3,62.8},},},
        },
        [177241] = {
            [QuestieDB.objectKeys.spawns] = {[28]={{45.27,69.21},},},
            [QuestieDB.objectKeys.zoneID] = 28,
        },
        [177784] = {
            [QuestieDB.objectKeys.spawns] = {[405]={{24.6,44.1},{25.4,47.8},{25.7,38.9},{26.2,36.7},{28.2,34.1},{29.7,36.7},{30,26.1},{30.1,29.1},{30.6,31.9},{30.6,34.3},{30.8,24.4},{32,30.5},{32.7,25.4},{32.8,35.2},{33,28.6},{33.9,33.2},{34.1,27.5},{34.1,30.6},{34.2,27.4},{34.3,23.2},{35.2,34.7},{35.4,25},{35.5,25},{34.11,30.7},{35.26,34.72},{32.8,35.3},{30.54,34.21},{34.15,27.46},{31.93,30.58},{32.94,28.58},{35.37,25.02},{32.69,25.26},{30.84,24.33},{34.32,23.12},{33.88,33.29},},},
        },
        [178227] = {
            [QuestieDB.objectKeys.spawns] = {[331]={{56,63}}},
            [QuestieDB.objectKeys.zoneID] = 331,
        },
        [179908] = {
            [QuestieDB.objectKeys.spawns] = {[47]={{53.3,38.8},{57.4,42.6},{57.5,42.6},{66.4,44.8},{71,48.6},{72.6,52.9},},},
            [QuestieDB.objectKeys.zoneID] = 47,
        },
        [178224] = {
            [QuestieDB.objectKeys.spawns] = {[2557]={{42.71,68.62},},}, -- #1156
            [QuestieDB.objectKeys.zoneID] = 2557,
        },

        -- Fake IDs
        [400000] = {
            [QuestieDB.objectKeys.name] = "Feralas Ahi Fishing Location",
            [QuestieDB.objectKeys.questStarts] = {},
            [QuestieDB.objectKeys.questEnds] = {},
            [QuestieDB.objectKeys.spawns] = {[357]={{62.1,51.4},{62.2,49.9},{62.4,52.4},{62.4,52.5},{62.6,49.3},{62.6,50.2},{62.7,50.6},{62.8,51.5},{62.9,52.5},{63.5,53.6},{63.7,52.4},{64,53.2},},},
            [QuestieDB.objectKeys.zoneID] = 357
        },
        [400001] = {
            [QuestieDB.objectKeys.name] = "Misty Reed Mahi Mahi Fishing Location",
            [QuestieDB.objectKeys.questStarts] = {},
            [QuestieDB.objectKeys.questEnds] = {},
            [QuestieDB.objectKeys.spawns] = {[8]={{74.4,3.7},{74.5,3.3},{74.5,3.8},{75.1,95.9},{76,95.4},{76.3,4.3},{77.4,4.3},{77.4,95.5},{78.7,5.3},{78.9,95.7},{79.1,94.7},{79.8,94.7},{80.2,94.2},{81.2,93.6},{82.1,94.2},{84.4,91.6},{84.5,92.9},{84.9,92.1},{85.6,89.2},{86.2,88},{86.4,86.4},{86.6,16.8},{86.6,85.6},{87.3,80.7},{87.4,82.1},{87.7,79.7},{87.7,81.9},{88.5,76.6},{89.1,20},{89.8,23},{89.9,74.5},{90.2,22.4},{90.3,73.4},{90.4,71.9},{90.4,73.6},{90.5,73.5},{90.6,73},{90.7,72.1},{91.1,82.2},{91.4,30.1},{91.5,82.1},{91.7,30.4},{91.8,82.9},{93.6,37.2},{93.8,66.5},{94,38.4},{94.2,40.6},{94.2,65.1},{94.3,39.3},{94.3,64.3},{94.8,41.6},{95,43.8},{95.1,45.2},{95.2,45.9},{95.3,56.2},{95.7,47.5},},},
            [QuestieDB.objectKeys.zoneID] = 8
        },
        [400002] = {
            [QuestieDB.objectKeys.name] = "Sar'theris Striker Fishing Location",
            [QuestieDB.objectKeys.questStarts] = {},
            [QuestieDB.objectKeys.questEnds] = {},
            [QuestieDB.objectKeys.spawns] = {[405]={{22.2,87.6},{22.8,76.8},{24.3,82.5},{24.5,81.9},{24.9,81.3},{25.6,81},{25.8,77.4},{25.8,77.5},{25.9,78.7},{26,80.1},{26.2,75.4},{26.2,76.2},{27.2,42.9},{33,36.8},{35.3,31.7},{36.1,32.8},{36.1,34.8},{38.8,23.2},{40.1,22.1},},},
            [QuestieDB.objectKeys.zoneID] = 405
        },
        [400003] = {
            [QuestieDB.objectKeys.name] = "Savage Coast Blue Sailfin Fishing Location",
            [QuestieDB.objectKeys.questStarts] = {},
            [QuestieDB.objectKeys.questEnds] = {},
            [QuestieDB.objectKeys.spawns] = {[33]={{13.5,15.7},{19.5,20.9},{22.2,19.8},{24.4,18.8},{24.5,65.7},{24.6,18.9},{25,58.3},{25.3,45.2},{25.4,49.3},{25.5,19.9},{25.7,66.9},{26.2,48.5},{26.3,67.8},{26.9,20.4},{27,39.7},{27.1,40.5},{27.3,68},{27.4,68.9},{27.7,21},{28.7,21.8},{29.2,23.2},{29.4,23.7},{29.4,24.6},{29.4,27.4},{29.4,27.7},{29.5,24.3},{29.5,25.1},{29.5,27.4},{29.5,27.7},{29.6,25.7},{31.9,32.1},{33,31.3},{33,32.1},{33.1,32.5},{34.2,32.4},{34.2,32.5},{34.2,34.7},{34.7,34.5},{34.8,33.7},{34.9,32.4},{35.1,35.6},},},
            [QuestieDB.objectKeys.zoneID] = 3
        },
    }
end

-- some objects are shared across factions but require different sources for each faction (not sure if there is a better way to implement this)
function QuestieObjectFixes:LoadFactionFixes()
    local objectFixesHorde = {
        [105174] = {
            [QuestieDB.objectKeys.spawns] = {[1497]={{52.7,73.5},{52.8,75.9},{53.3,74.5},{53.9,73.2},{54.4,71.1},{54.8,73.0},{55.0,70.2},{55.8,71.2},{57.3,66.1},{58.1,69.5},},}, -- #1328
        },
    }

    local objectFixesAlliance = {
        [105174] = {
            [QuestieDB.objectKeys.spawns] = {[1519]={{39.6,86.5},{39.7,84.2},{40.3,91.8},{40.4,87.5},{40.4,90.3},{40.7,92.7},{41.3,90.4},{41.4,88.0},},}, -- #1328
        },
    }

    if UnitFactionGroup("Player") == "Horde" then
        for index, fix in pairs(objectFixesHorde) do
            QuestieCorrections.objectFixes[index] = fix
        end
    else
        for index, fix in pairs(objectFixesAlliance) do
            QuestieCorrections.objectFixes[index] = fix
        end
    end
end
