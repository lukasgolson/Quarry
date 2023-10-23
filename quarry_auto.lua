local quarryAPI = require("quarry_utilities")

local movementInstructions = {
    "left",
    "forward",
    "right",
    "forward",
    "left",
    "forward",
    "right",
    "forward",
    "left",
}
local level = 0

local function saveLevel(level)
    local file = io.open("level.txt", "w+")
    if not file then
        print("Couldn't open file to save level.")
        return
    end
    file:write(level)
    file:flush()
    file:close()
end

local function loadLevel()
    local file = io.open("level.txt", "r")
    if not file then
        print("Couldn't open file to load level.")
        return 0
    end
    level = tonumber(file:read())
    file:close()
    return level or 0
end



local function initializeQuarry()
    print("Initializing quarry...")
    quarryAPI.stopAllMovement()

    -- Retract the drill
    print("Retracting drill... eta approx. 30 seconds")
    quarryAPI.setHeadClutch("unlock")
    quarryAPI.moveDrill("retract")
    
    while not quarryAPI.isHeadHome() do
        os.sleep(1)
    end

    os.sleep(1)

    quarryAPI.setHeadClutch("lock")

    os.sleep(1)

    -- Move to the first waypoint
    print("Moving to first waypoint... eta 40 seconds")
    quarryAPI.moveHeadInDirection("backward")
    os.sleep(20)
    quarryAPI.moveHeadInDirection("right")
    os.sleep(20)
    quarryAPI.ignoreWaypoint()
    level = loadLevel()
    print("Moving to level " .. level .. "... eta " .. level * 1.5 .. " seconds")
    quarryAPI.setHeadClutch("unlock")
    quarryAPI.moveDrill("extend")
    os.sleep(1.5 * level)
    quarryAPI.setHeadClutch("lock")
    print("Quarry initialized. Starting sequence.")

    saveLevel(level - 1)
end



local function finalFunction()
    print("All instructions completed. Restarting sequence.")
   
    quarryAPI.stopAllMovement()
    os.sleep(2)
   
    quarryAPI.moveHeadInDirection("backward")
    os.sleep(30)
    quarryAPI.moveHeadInDirection("right")
    os.sleep(30)
    quarryAPI.setHeadClutch("unlock")
    quarryAPI.moveDrill("extend")
    os.sleep(2)
    quarryAPI.setHeadClutch("lock")
    os.sleep(2)
    level = level + 1
    saveLevel(level)
end

local function operateQuarry()
    initializeQuarry()
    while true do
        for i, instruction in ipairs(movementInstructions) do
            print("Executing instruction: " .. instruction)
            if instruction == "forward" or instruction == "backward" or instruction == "left" or instruction == "right" then
                quarryAPI.moveHeadInDirection(instruction)
            else
                print("Unknown instruction: " .. instruction)
            end
            while not quarryAPI.atWaypoint() do
                os.sleep(0.25)
            end
            print("Waypoint reached. Continuing sequence.")

            quarryAPI.stopAllMovement()

            os.sleep(1)
            if i == #movementInstructions then
                finalFunction()
                break
            end

            
        end
    end
end

operateQuarry()
