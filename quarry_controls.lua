-- main.lua


local quarryAPI = require("quarry_utilities")



-- Function to show available commands
local function showCommands()
    print("Available commands:")
    print("lock - Lock the drill head")
    print("unlock - Unlock the drill head")
    print("retract - Retract the drill")
    print("extend - Extend the drill")
    print("left [seconds] - Move left for [seconds]")
    print("right [seconds] - Move right for [seconds]")
    print("forward [seconds] - Move forward for [seconds]")
    print("backward [seconds] - Move backward for [seconds]")
    print("stop - Stop all movement")
    print("exit - Exit the program")
end

-- Main loop
while true do
    showCommands()

    local input = io.read()
    local command, arg1 = string.match(string.lower(input), "([^%s]+)%s*(.*)")

    if command == "lock" or command == "unlock" then
        quarryAPI.setHeadClutch(command)
    elseif command == "retract" or command == "extend" then
        quarryAPI.moveDrill(command)
    elseif command == "left" or command == "right" or command == "forward" or command == "backward" then
        print("Moving " .. command .. "for " .. arg1 .. " seconds")
        quarryAPI.moveHeadInDirection(command)
        os.sleep(tonumber(arg1))
        quarryAPI.stopAllMovement()
    elseif command == "stop" then
        quarryAPI.stopAllMovement()
    elseif command == "exit" then
        break
    else
        print("Unknown command")
    end

    os.sleep(0.1)
end

