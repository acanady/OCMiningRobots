local robot = require("robot")
local inv_controller = require("component").inventory_controller
local sides = require("sides")

-- attemps to keep track of whether the robot has an item equipped
-- there doesn't exist in the robot api a way to track this so this
-- internal tracker could be out of sync if the robot is manually given an equipped tool

local item_equipped = false

inventory = {}

---@param internal_item_slot number the slot in the robot inventory to pull the item into
---@param amount number the amount of the item to pull from the chest
---@param side number the side of the robot the chest is located, robots cannot read from left and right sides or behind
---@param inventory_size number the number of slots in the inventory of the chest
function inventory.pull_item_from_chest(internal_item_slot,amount,side,inventory_size)
    if side == sides.left or side == sides.right then
        print("Error, left and right are invalid sides for the robot")
        return 0, false
    end
    robot.select(internal_item_slot)
    local remaining_amount = amount
    for i=1,inventory_size do
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

function inventory.store_items_in_chest(internal_item_slot,amount,side,inventory_size)
    if side == sides.left or side == sides.right then
        print("Error, left and right are invalid sides for the robot")
        return 0, false
    end

    -- variable initialization
    local remaining_amount = 0
    local starting_amount = 0

    local item_data = inv_controller.getStackInInternalSlot(internal_item_slot)
    if item_data ~= nil then
        remaining_amount = math.min(item_data.size,amount)
        starting_amount = item_data.size
    else
        print("Error, no item found in slot " .. internal_item_slot)
        return false
    end

    robot.select(internal_item_slot)
    for i=1,inventory_size do
        inv_controller.dropIntoSlot(side,i,remaining_amount)
        item_data = inv_controller.getStackInInternalSlot(internal_item_slot)
        if item_data == nil then
                return true
        else
            remaining_amount = remaining_amount - (starting_amount - item_data.size)
            starting_amount = item_data.size
        end
        if remaining_amount == 0 then
            return true
        end
    end
end

function inventory.get_item_count(internal_item_slot)
    local item_data = inv_controller.getStackInInternalSlot(internal_item_slot)
    if item_data ~= nil then
        return item_data.size
    else
        return 0
    end
end

return inventory