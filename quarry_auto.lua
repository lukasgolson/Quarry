local quarryAPI = require("quarry_utilities")

-- Define the sequence of movements
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

local function initializeQuarry()
    print("Initializing quarry...")

    -- Retract the drill

    print("Retracting drill... eta 30 seconds")
    quarryAPI.setHeadClutch("unlock")
    quarryAPI.moveDrill("retract")
    os.sleep(30)
    quarryAPI.setHeadClutch("lock")

    -- Move to the first waypoint
    print("Moving to first waypoint... eta 40 seconds")
    quarryAPI.moveHeadInDirection("backward")
    os.sleep(20)
    quarryAPI.moveHeadInDirection("right")
    os.sleep(20)

    quarryAPI.ignoreWaypoint() -- Ignore the first waypoint if we are already there

    print("Quarry initialized. Starting sequence.")
end

-- Special function to call after all movements
local function finalFunction()
    print("All instructions completed. Restarting sequence.")

    -- Reset the drill
    quarryAPI.moveHeadInDirection("backward")
    os.sleep(20)
    quarryAPI.setHeadClutch("unlock")
    quarryAPI.moveDrill("extend")
    os.sleep(2)
    quarryAPI.setHeadClutch("lock")

    os.sleep(1)
end

-- Main function for quarry operations
local function operateQuarry()
    initializeQuarry()
    while true do
        -- Loop through each instruction in the list
        for i, instruction in ipairs(movementInstructions) do

            print("Executing instruction: " .. instruction)

            -- Execute the appropriate movement based on the instruction
            if instruction == "forward" or instruction == "backward" or instruction == "left" or instruction == "right" then
                quarryAPI.moveHeadInDirection(instruction)
            elseif instruction == "drill down" then
                quarryAPI.moveDrill("extend")
            elseif instruction == "drill up" then
                quarryAPI.moveDrill("retract")
            else
                print("Unknown instruction: " .. instruction)
            end
            
            -- Check if we are at a waypoint
            while not quarryAPI.atWaypoint() do
                print("Waiting for waypoint...")
                -- Wait a bit before checking again
                os.sleep(0.1)
            end

            print("Waypoint reached. Continuing sequence.")

            
            
            -- If this is the last instruction, call the final function and break the loop to start over
            if i == #movementInstructions then
                finalFunction()
                break
            end
        end
    end
end

-- Start the quarry operation
operateQuarry()
