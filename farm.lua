-- script using the movement library to automatically farm a 9x9 area and
-- create butter, cheese, and dough from pam's harvest craft
-- in the ftb interactions remastered modpack.

--example call farm 1 all 5 would farm all 3 farms for 5 iterations

local args = {...}
local move = require("movement")
local robot = require("robot")
local computer = require("computer")
local inv_controller = require("component").inventory_controller
local sides = require("sides")

local farming_type = tonumber(args[1]) or 1 -- 1 for general_farming, 2 for cheese, 3 for butter, 4 for dough
local which_farm = args[2] or "food" -- "food", "xp", or "material" "all" for all farms, only used if farming_type is set to farming
local farming_iterations = tonumber(args[3]) or 10 -- how many iterations to farm the specified farm, only used if farming_type is set to farming

-- set the current postion as the home position for the robot, should be facing North
-- in the center of a 9x9 farming grid with no obstructions
local food_farm_loc = {x = 11, y = 69, z = 21, dir = 1}
local xp_farm_loc = {x=-10, y=69, z=21, dir=1}
local mat_farm_loc = {x=0,y=69,z=21,dir=2}

local function handle_error(err)
    print("Caught error:",err)
    local err_file = io.open("error.log", "a")
    if err_file then
        err_file:write(err, "\n")
        err_file:close()
    else
        print("Failed to open error.log for writing")
    end
end

-- we will farm in a ring around the apiary block
-- once the robot is full of resources we will save our current_location and go to the
-- drop off to drop off out contents. After that we will return to out current_location,
-- facing does matter here, but go_to(loc) perseves this position and facing

--goes to the start position of given ring
local function go_to_farming_position(count, farm_loc)
    if count < 1 or count > 4 then
        print("Farm of size min 3x3 and max 9x9 required, and must be square")
        return false
    end
    local x_pos = farm_loc.x + count
    local z_pos = farm_loc.z + count
    local success = movement.go_to({x=x_pos,y=farm_loc.y,z=z_pos,dir=2})
    return success
end

local function farm_ring(count, farm_loc)
    if count < 1 or count > 4 then
        print("Farm of size min 3x3 and max 9x9 required, and must be square")
        return false
    end
    go_to_farming_position(count, farm_loc)
    for i = 1, 4 do
        move.right(1)
        for j=1,count*2 do
            robot.useDown()
            robot.useUp()
            move.forward(1)
        end
    end
end

local function drop_off_materials(loc, return_loc)
    if not loc then
       local err = debug.traceback("Error the provided drop_off_location is nil")
       handle_error(err)
    end
    if not return_loc then
        local err = debug.traceback("Error the provided return location from drop_off_location is nil")
        handle_error(err)
    end
    -- save location and drop off materials and return, but we'll do it after every 2 rings or so. 
    print("going to material dropoff location x:".. tostring(loc.x) .." z:".. tostring(loc.z) .." dir:".. tostring(loc.dir))
    move.go_to(loc)
    for i = 1, 16 do
        robot.select(i)
        robot.dropDown()
    end
    print("returning to the last stored posistion x:".. tostring(return_loc.x) .." z:".. tostring(return_loc.z) .." dir:".. tostring(return_loc.dir))
    local ok,err = xpcall(move.go_to,debug.traceback, return_loc)
    if not ok then
        handle_error(err)
    end
end

local function farm(count, farm_loc)
    local drop_off_loc = move.load_location("drop_off.txt")
    if count < 1 or count > 4 then
        print("Farm of size min 3x3 and max 9x9 required, and must be square")
        return false
    end
    for i = 2,count,2 do
        farm_ring(i, farm_loc)
        print("attemping to go back to farm location from farm function")
        local ok, err = xpcall(move.go_to, debug.traceback, farm_loc)
            if not ok then
                handle_error(err)
            end
        drop_off_materials(drop_off_loc, move.get_location())
    end
end

local lemon_slot = 1
local salt_slot = 2
local flour_slot = 3

-- grabs specified amount of item from the cabinet from the specified side
-- stores it in the salt slot, returns true if salt is found and the amount of salt grabbed

local function get_item_from_cabinet(internal_item_slot,amount,side)
    if side == sides.left or side == sides.right then
        print("Error, left and right are invalid sides for the robot")
        return 0, false
    end
    robot.select(internal_item_slot)
    local remaining_amount = amount
    for i=1,27 do
        inv_controller.suckFromSlot(side,i,remaining_amount)
        local item_data = inv_controller.getStackInInternalSlot(internal_item_slot)
        if item_data ~= nil then
            if item_data.size >= amount then
                return item_data.size, true
            else
                remaining_amount = amount - item_data.size
            end
        end
    end
    local item_data = inv_controller.getStackInInternalSlot(internal_item_slot)
    if item_data ~= nil then
        return item_data.size, true
    else
        return 0, false
    end
end

-- grabs salt from the cabinet in front of the robot
-- if the specified amount is not already stored in the robot
-- stores it in the salt slot
local function get_salt(amount)
    local remaining_amount = amount
    local item_data = inv_controller.getStackInInternalSlot(salt_slot)
    if item_data ~= nil then
        if item_data.size >= amount then
            return item_data.size, true
        else
            remaining_amount = amount - item_data.size
        end
    end
    move.face(move.get_location().dir,1)
    return get_item_from_cabinet(salt_slot, remaining_amount, sides.front)
end

-- grabs lemons from the cabinet above the robot
-- stores it in the lemon slot
local function get_lemons(amount)
    local remaining_amount = amount
    local item_data = inv_controller.getStackInInternalSlot(lemon_slot)
    if item_data ~= nil then
        if item_data.size >= amount then
            return item_data.size, true
        else
            remaining_amount = amount - item_data.size
        end
    end
    return get_item_from_cabinet(lemon_slot, remaining_amount, sides.up)
end

-- grabs flour from the cabinet above the robot
-- stores it in the flour slot
local function get_flour(amount)
    local remaining_amount = amount
    local item_data = inv_controller.getStackInInternalSlot(flour_slot)
    if item_data ~= nil then
        if item_data.size >= amount then
            return item_data.size, true
        else
            remaining_amount = amount - item_data.size
        end
    end
    return get_item_from_cabinet(flour_slot, remaining_amount, sides.up)
end

-- Uses the wood basin to create cheese 
local function create_cheese(requested_amount)
    move.go_to(xp_farm_loc)
    move.go_to({x=-6,y=69,z=18})
    get_salt(requested_amount)
    get_lemons(requested_amount)
    local salt_data = inv_controller.getStackInInternalSlot(salt_slot)
    local lemon_data = inv_controller.getStackInInternalSlot(lemon_slot)
    local total_crafts = math.min(salt_data.size, lemon_data.size)
    if total_crafts == 0 then
        print("Unable to craft cheese, not enough materials")
        return 
    end
    for i=1,total_crafts do
        robot.select(salt_slot)
        -- eqip the salt
        inv_controller.equip()
        robot.useDown()
        -- unequip the salt
        inv_controller.equip()
        robot.select(lemon_slot)
        -- equip the lemon
        inv_controller.equip()
        robot.useDown()
        -- unequip the lemon
        inv_controller.equip()
        robot.useDown()
        os.sleep(2)
        robot.useDown()
        os.sleep(2)
   end
   move.go_to(xp_farm_loc)
end

local function create_butter(requested_amount)
    move.go_to(xp_farm_loc)
    move.go_to({x=-6,y=69,z=18})
    get_salt(requested_amount)
    local salt_data = inv_controller.getStackInInternalSlot(salt_slot)
    local total_crafts = salt_data.size
    if total_crafts == 0 then
        print("Unable to craft butter, not enough materials")
        return 
    end
    for i=1,total_crafts do
        robot.select(salt_slot)
        -- equip the salt
        inv_controller.equip()
        robot.useDown()
        -- unequip the salt
        inv_controller.equip()
        robot.useDown()
        os.sleep(2)
        robot.useDown()
        os.sleep(2)
   end
   move.go_to(xp_farm_loc)
end

-- Uses the wood basin to create dough
local function create_dough(requested_amount)
    move.go_to(xp_farm_loc)
    move.go_to({x=-6,y=69,z=25})
    get_salt(requested_amount)
    get_flour(requested_amount)
    local salt_data = inv_controller.getStackInInternalSlot(salt_slot)
    local flour_data = inv_controller.getStackInInternalSlot(flour_slot)
    local total_crafts = math.min(salt_data.size, flour_data.size)
    if total_crafts == 0 then
        print("Unable to craft dough, not enough materials")
        return 
    end
    for i=1,total_crafts do
        robot.select(flour_slot)
        -- equip the flour
        inv_controller.equip()
        robot.useDown()
        -- unequip the flour
        inv_controller.equip()
        robot.select(salt_slot)
        -- equip the salt
        inv_controller.equip()
        robot.useDown()
        -- unequip the salt
        inv_controller.equip()
        robot.useDown()
        os.sleep(2)
        robot.useDown()
        os.sleep(2)
   end
   move.go_to(xp_farm_loc)
end

-- farms from multiple farms in a row
---@param which_farm string 
---@param size number the size of the farm, must be 1,2,3, or 4 corresponding to a farm size of 3x3, 5x5, 7x7, or 9x9
local function multi_farm(size, which_farm)
    if which_farm == "food" then
        farm(size, food_farm_loc)
    end
    if which_farm == "xp" then
        farm(size, xp_farm_loc)
    end
    if which_farm == "material" then
        farm(size, mat_farm_loc)
    end
    if which_farm == "all" then
        farm(size, food_farm_loc)
        farm(size, xp_farm_loc)
        farm(size, mat_farm_loc)
    end
end

function main()
    if farming_type == 1 then
        for i=1, farming_iterations do
            local ok, err = xpcall(multi_farm, debug.traceback, 4, which_farm)
            if not ok then
                handle_error(err)
            end
            if computer.energy() < 5000 then
                print("Energy low")
                move.go_charge(move.get_location())
            else
                os.sleep(10)
            end
        end
    elseif farming_type == 2 then
        create_cheese(10)
    elseif farming_type == 3 then
        create_butter(10)
    elseif farming_type == 4 then
        create_dough(64)
    end
end

main()