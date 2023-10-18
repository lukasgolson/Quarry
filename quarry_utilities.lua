-- Direction settings (relative to the controller)
local redstoneDirs = {
    xAxis = "back",
    zAxis = "top",
    reverse = "right",
    headClutch = "left",
    headHome = "front",
    waypoint = "bottom",
}

-- Initial state
local state = {
    reverse = false,
    xAxis = false,
    zAxis = false,
    headClutch = false,
    hasPassedWaypoint = false,
    isHome = function()
        return rs.getInput(redstoneDirs.headHome)
    end
}

-- Utility function to update system state and outputs
local function updateState(newState)
    for k, v in pairs(newState) do
        state[k] = v
    end
    for k, v in pairs(redstoneDirs) do
        rs.setOutput(v, state[k] or false)
    end
end



-- Function to lock the drill head
local function lockHead()
    updateState({ headClutch = true })
end

-- Function to unlock the drill head
local function unlockHead()
    updateState({ xAxis = true, zAxis = true, reverse = false, headClutch = false })
end

-- Function to retract the drill
local function retractDrill()
    if state.isHome() then
        print("Drill is already home; cannot retract it")
        return
    end
    updateState({ xAxis = true, zAxis = true, reverse = false })
end

-- Function to extend the drill
local function extendDrill()
    updateState({ xAxis = true, zAxis = true, reverse = true })
end

-- Function to move the drill head
local function moveHead(x, z, rev)
    if not state.headClutch then
        print("Cannot move; drill head is not locked")
        return
    end
    updateState({ xAxis = x, zAxis = z, reverse = rev })
end

local function StopMovement()
    print("Stopping movement")
    updateState({ xAxis = true, zAxis = true, reverse = false, headClutch = true })
end 


-- Helper method for moving left
local function moveLeft()
    moveHead(false, false, false)
end

-- Helper method for moving right
local function moveRight()
    moveHead(false, false, true)
end

-- Helper method for moving backward
local function moveBack()
    moveHead(true, false, false)
end

-- Helper method for moving forward
local function moveForward()
    moveHead(true, false, true)
end

local function isAtWaypoint()
    local currentWaypointState = rs.getInput(redstoneDirs.waypoint)
    if currentWaypointState and not state.hasPassedWaypoint then
        state.hasPassedWaypoint = true
        return true
    elseif not currentWaypointState then
        state.hasPassedWaypoint = false
    end
    return false
end

local quarryAPI = {}


function quarryAPI.setHeadClutch(action)
    if action == "lock" then
        lockHead()
    elseif action == "unlock" then
        unlockHead()
    else
        print("Invalid action. Use 'lock' or 'unlock'")
    end
end

function quarryAPI.moveDrill(action)
    if action == "retract" then
        retractDrill()
    elseif action == "extend" then
        extendDrill()
    else
        print("Invalid action. Use 'retract' or 'extend'")
    end
end

function quarryAPI.moveHeadInDirection(direction)
    if direction == "left" then
        moveLeft()
    elseif direction == "right" then
        moveRight()
    elseif direction == "forward" then
        moveForward()
    elseif direction == "backward" then
        moveBack()
    else
        print("Invalid direction. Use 'left', 'right', 'forward' or 'backward'")
    end
end

function quarryAPI.stopAllMovement()
    StopMovement()
end

function quarryAPI.atWaypoint()
    return isAtWaypoint()
end

function quarryAPI.clearWaypoint()
    state.hasPassedWaypoint = false
end

function quarryAPI.ignoreWaypoint()
    state.hasPassedWaypoint = true    
end


return quarryAPI