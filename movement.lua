-- BetterMovement library that stores location of the opencomputer robot during movement
-- with co-ords relvant to the home set in the set_home function, be sure the robot is facing North
-- Locations can be easily added with the save and load location functions, and 
-- a specific location can be moved to with goto loc.
-- pathing is simple with shortest x,y,z distance, anything blocking the turtle will pause operation
-- until the blockage is moved and the turtle function is run again

-- saves the provided location to disc
-- "home.txt" and "location.txt" are special locations used by the movement api to store the home
-- and current location of the robot, these names are reserved. 


local function save_location(loc, file_name)
    local file = io.open(file_name, "w")
    if not file then 
        return false 
    end

    file:write(loc.x,"\n")
    file:write(loc.y,"\n")
    file:write(loc.z,"\n")
    file:write(loc.dir,"\n")
    file:close()
    return true
end

-- loads the provided saved location from disk
local function load_location(file_name)
    local file = io.open(file_name, "r")
    if not file then
        return nil, false
    end

    local x = tonumber(file:read("*l"))
    local y = tonumber(file:read("*l"))
    local z = tonumber(file:read("*l"))
    local dir = tonumber(file:read("*l"))

    file:close()
    return {x=x,y=y,z=z,dir=dir}, true
end

local location = load_location("location.txt")

local computer = require("computer")
local turtle = require("turtle")
movement = {}

-- returns the current location of the robot relative to home
function movement.get_location()
    if not location then
        return nil
    end
    return {x = location.x, y = location.y, z = location.z, dir = location.dir}
end

-- returns the location of home, if home DNE then returns nil
function movement.get_home()
    local home = load_location("home.txt")
    if not home then
        print("Error when attempting to load home location, home.txt DNE")
        return nil
    end
    return {x=home.x, y=home.y, z=home.z, dir=home.dir}
end

-- Saves the given location as long as the location isn't of the reserved file names
function movement.save_location(loc, file_name)
    if file_name == "home.txt"  or file_name == "location.txt" then
        print("File name used is reserved, please save location to a different file name")
    else
        local success = save_location(loc, file_name)
        if not success then
            print("Error occured when attempting to save location data")
        else
            return true
        end
    end
end

-- loads a given location given the file_name if it exists
function movement.load_location(file_name)
    local location, success = load_location(file_name)
    if not success then
        print("Error occured when attempting to load location data from " .. file_name .. " : file not found")
    else
        return location, true
    end
end

--function that takes in the direction you
--wish the turtle to face and then turns it
--that way efficiently as possible
function movement.face(facing,direction)
  if facing == direction then
    return
  end

  local dist = (direction - facing) % 4

  if (dist == 3) then
    turtle.left()
  elseif (dist == 1) then
    turtle.right()
  else
    turtle.right(2)
  end

  -- update facing position in file
  location.dir = direction
  save_location(location,"location.txt")
end

function movement.left(amount)
    local direction = (location.dir - amount) % 4
    turtle.left(amount)
    location.dir = direction
    save_location(location,"location.txt")
end

function movement.right(amount)
    local direction = (location.dir + amount) % 4
    turtle.right(amount)
    location.dir = direction
    save_location(location,"location.txt")
end

-- function that takes the provided distance and moves the robot forward
-- updates the location of the robot, even if the robot fails to fully complete a move
-- the location will still be accurate
-- returns: total_dist [number], success [boolean], fail_reason [string]
function movement.forward(dist)
    local distance_traveled, success, fail_reason = turtle.forward(dist)

    if distance_traveled == 0 then
        return 0, success, fail_reason
    end
    -- if facing north we remove from z
    if location.dir == 0 then
        location.z = location.z - distance_traveled
    -- if facing east we add to x
    elseif location.dir == 1 then
        location.x = location.x + distance_traveled
    -- if facing south we add to z
    elseif location.dir == 2 then
        location.z = location.z + distance_traveled
    -- if facing west we remove from x
    else
        location.x = location.x - distance_traveled
    end
    save_location(location,"location.txt")
    return distance_traveled, success, fail_reason
end

-- function that takes the provided distance and moves the robot backward
-- updates the location of the robot as well, even if a robot fails to complete a move
-- the location will still be accurate
-- returns: total_dist [number], success [boolean], fail_reason [string]
function movement.back(dist)
    local distance_traveled, success, fail_reason = turtle.back(dist)

    if distance_traveled == 0 then
        return 0, success, fail_reason
    end
    --If facing north we add to Z
    if location.dir == 0 then
        location.z = location.z + distance_traveled
    -- if facing east we remove from X
    elseif location.dir == 1 then
        location.x = location.x - distance_traveled
    -- if facing south we remove from Z
    elseif location.dir == 2 then
        location.z = location.z - distance_traveled
    -- if facing west we add to X
    else
        location.x = location.x + distance_traveled
    end
    save_location(location,"location.txt")
    return distance_traveled, success, fail_reason
end

-- moves the robot to the given x-coordinate relative to home
-- only moves in the x direction, y and z remain constant

function movement.moveX(xcoord)
    if location == nil then
        print("Error, current location not found when attempting to moveX")
        return
    end
    local success = movement.go_to({x=xcoord,y=location.y,z=location.z})
    if not success then
        print("Failure attempting to move to x:" .. xcoord .. " please remove obstacles and try again")
    end
end

function movement.moveZ(zcoord)
    if location == nil then
        print("Error, current location not found when attempting to moveZ")
        return
    end
    local success = movement.go_to({x=location.x,y=location.y,z=zcoord})
    if not success then
        print("Failure attempting to move to z:" .. zcoord .. " please remove obstacles and try again")
    end
end

-- moves the robot up the specified distance
-- returns distance_traveled[number], success[boolean], and fail_reason[string] if failed
-- updates the location of the robot as well, even if a robot fails to complete a move
-- the location will still be accurate
function movement.up(dist)
    local distance_traveled, success, fail_reason = turtle.up(dist)

    if distance_traveled == 0 then
        return 0, success, fail_reason
    end

    location.y = location.y + distance_traveled
    save_location(location,"location.txt")
    return distance_traveled, success, fail_reason
end

-- moves the robot down the specified distance
-- returns distance_traveled[number], success[boolean], and fail_reason[string] if failed
-- updates the location of the robot as well, even if a robot fails to complete a move
-- the location will still be accurate
function movement.down(dist)
    local distance_traveled, success, fail_reason = turtle.down(dist)

    if distance_traveled == 0 then
        return 0, success, fail_reason
    end

    location.y = location.y - distance_traveled
    save_location(location,"location.txt")
    return distance_traveled, success, fail_reason
end

-- sets the home location of the robot, used as a reference point for all movement
-- for example if home is set to 0,0,0 and the robot is at home when, move.forward(2) is called its internal location will read
-- 0,0,2. As it is 2 blocks away from home. Positioning of other locations will be relative to home.
-- That means if you set home relative to the worlds origin (so the x,y,z position in game of the block), other locations will also be relative to the worlds origin
-- This will let you use normal in world co-ordinates for other locations if you so desire
function movement.set_home(x_coord,z_coord,y_coord,dir)
    if x_coord == nil or z_coord==nil or y_coord==nil then
        print("Error when attempting to set home, x,y, and z co-ordinates are required")
        return
    end
    save_location({x=x_coord,y=y_coord,z=z_coord,dir=dir or 0}, "home.txt")
    if location ~= nil then
        location.x=x_coord
        location.y=y_coord
        location.z=z_coord
        location.dir=dir or 0
    else
        print("Error when attempting to set home, direction could not be pulled from existing location, location DNE")
    end
end

-- used to force reset the location of the robot, useful if the robot is pickedup and moved
-- or if the home location is reset and the robot needs to update its current location relative to the new home
function movement.set_current_location(x_coord,z_coord,y_coord,dir)
    if x_coord == nil or z_coord==nil or y_coord==nil then
        print("Error when attempting to set location, x,y, and z co-ordinates are required")
        return
    end
    save_location({x=x_coord,y=y_coord,z=z_coord,dir=dir or 0}, "location.txt")
    if location ~= nil then
        location.x=x_coord
        location.y=y_coord
        location.z=z_coord
        location.dir=dir or 0
    else
        print("Error when attempting to set location, direction could not be pulled from existing location, location DNE")
    end
end
-- sets location for robot to drop off materials relative to the home location
function movement.set_drop_off_location(x_coord,z_coord,y_coord, direction)
    save_location({x=x_coord,y=y_coord,z=z_coord,dir=direction}, "drop_off_location.txt")
end

-- goes to the specified x,y,z location based on home location. Failure to reach location because of
-- obstacles will still result in attempt to get close in the other co-ordinates. The obstacle will
-- need to be removed and go_to run again. location should be accurate despite blockage as long as the
-- robot is not picked up, if so then resetting the home after replacing it is necessary
-- loc should be an object with x,y,z values, dir is optional and will face the robot in the provided direction
function movement.go_to(loc)
    if not loc then
        print("unable to reach destination: provided location is nil")
        return false
    end

    if not location then
        print("Error, current location not found when attempting go_to")
        return false
    end

    local move_success = true
    local x_dist = location.x - loc.x
    local y_dist = location.y - loc.y
    local z_dist = location.z - loc.z

    if x_dist ~= 0 then
        if x_dist > 0 then
            movement.face(location.dir,3)
        else
            movement.face(location.dir,1)
        end
        local amount, success, reason = movement.forward(math.abs(x_dist))
        if not success then
            print("Failure attempting to move to location, please remove obstacles and try again")
            print("Robot only moved " .. amount .. " spaces in the x direction: " .. reason)
            move_success = false
        end
    end
    if z_dist ~= 0 then
        if z_dist > 0 then
            movement.face(location.dir,0)
        else
            movement.face(location.dir,2)
        end
        local amount, success, reason = movement.forward(math.abs(z_dist))
        if not success then
            print("Failure attempting to move to location, please remove obstacles and try again")
            print("robot only moved " .. amount .. " spaces in the z direction: " .. reason)
            move_success = false
        end
    end
    if y_dist ~= 0 then
        if y_dist > 0 then
            local amount, success, reason = movement.down(y_dist)
            if not success then
                print("Failure attempting to move to location, please remove obstacles and try again")
                print("Robot only moved " .. amount .. " spaces down : " .. reason)
                move_success = false
            end
        else
            local amount, success, reason = movement.up(math.abs(y_dist))
            if not success then
                print("Failure attempting to move to location, please remove obstacles and try again")
                print("Robot only moved " .. amount .. " spaces up: " .. reason)
                move_success = false
            end
        end
    end
    -- face the correct direction if it was provided
    if loc.dir ~= nil then
        movement.face(location.dir, loc.dir)
    end
    return move_success
end

function movement.go_home()
    local home = movement.get_home()
    if not home then
        print("Error when attempting to load home location, home.txt DNE")
        return
    end
    if not location then
        print("Error, current location not found when attempting to go home")
        return
    else
        print("going home")
        movement.go_to(home)
    end
end

function movement.set_charge_location(x_coord,z_coord,y_coord, direction)
    save_location({x=x_coord,y=y_coord,z=z_coord,dir=direction}, "charge_location.txt")
end

-- will read from charge_location and go charge, if return_dest is set
-- will immeidately return to the return_dest after sufficiently charge
function movement.go_charge(return_dest)
    local charge_loc = load_location("charge_location.txt")
    if not charge_loc then
        print("Error when attempting to load charge location, charge_location.txt DNE")
        print("try setting charge location with set_charge_location()")
        return
    end
    if not location then
        print("Error, current location not found when attempting to go charge")
        return
    else
        print("going to charge")
        movement.go_to(charge_loc)
        if return_dest then
            while computer.energy() < 20300 do
                os.sleep(1)
            end
            print("returning to previous location")
            movement.go_to(return_dest)
        end
    end
end

return movement
