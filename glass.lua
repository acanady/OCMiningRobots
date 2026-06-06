local move = require("movement")
local robot = require("robot")
local sides = require("sides")
local inv = require("inventory")
local computer = require("computer")
local sand_slot = 1
local glass_slot = 2

local function place_sand()
    move.go_to({x=-10,y=69,z=0,dir=1})
    inv.pull_item_from_chest(sand_slot,8,sides.bottom,27)
    if inv.get_item_count(sand_slot) == 0 then
        print("Failed to pull sand from chest")
        return false
    end
    move.go_to({x=-9,y=69,z=1,dir=1})
    robot.select(sand_slot)
    for i = 1, 4 do
        for j=1,2 do
            robot.placeDown()
            move.forward(1)
        end
            move.left(1)
    end
end
local function break_glass()
    move.go_to({x=-9,y=69,z=1,dir=1})
    robot.select(glass_slot)
    for i = 1, 4 do
        for j=1,2 do
            robot.swingDown()
            move.forward(1)
        end
            move.left(1)
    end
end

local function deposit_glass()
    move.go_to({x=-10,y=69,z=1,dir=1})
    robot.select(glass_slot)
    inv.store_items_in_chest(glass_slot,64,sides.bottom,1)
end

local function create_glass()
    place_sand()
    os.sleep(45)
    break_glass()
    deposit_glass()
end

while true do
    local ok,err = pcall(create_glass)
    if not ok then
        print("Error creating glass: " .. err)
    end
    if computer.energy() < 5000 then
        print("Energy low")
        move.go_charge(move.get_location())
    end
end
