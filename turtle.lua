local robot = require("robot")
turtle = {}
turtle.__index = turtle
 
function turtle.right(...)
  local t = {...}
  local a = t[1]
  local i = 0
  --print('a is: ', a)
  if type(a) == 'number' then
    while(i < a) do
      robot.turnRight()
      i = i + 1
    end  
  else
    --print(type(a))
    robot.turnRight()
  end
end
 
function turtle.left(...)
  local t = {...}
  local a = t[1]
  local i = 0
  
  if(type(a) == 'number') then
    while(i < a) do
      robot.turnLeft()
      i = i + 1
    end
  else
    robot.turnLeft()
  end
end

-- moves the turtle x amount forward, once if 0.
-- returns the amount the turtle moved [number], false if it ever fails [bool], and the failure reason [string]
function turtle.forward(...)
  local t = {...}
  local a = t[1]
  local i = 0
  
  if (type(a) == 'number') then  
    while (i  < a) do
      local forward_success, fail_reason = robot.forward()
      if not forward_success then 
        return i, false, fail_reason
      end
      i = i + 1
    end
    return a, true
  else
    local forward_success, fail_reason = robot.forward()
    if not forward_success then
      return 0, false, fail_reason
    else
      return 1, true
    end
  end
end
 
function turtle.back(...)
  local t = {...}
  local a = t[1]
  local i = 0
  
  if (type(a) == 'number') then
    while(i < a) do
      local backward_success, fail_reason = robot.back()
      if not backward_success then
        return i, false, fail_reason
      end
      i = i + 1
    end
    return a, true
  else
    local backward_success, fail_reason = robot.back()
    if not backward_success then
      return i, false, fail_reason
    else
      return 1, true
    end
  end
end
 
function turtle.up(...)
  local t = {...}
  local a = t[1]
  local i = 0
 
  if (type(a) == 'number') then
    while(i < a) do
      local up_success, fail_reason = robot.up()
      if not up_success then
        return i, false, fail_reason
      end
      i = i + 1
    end
    return a, true
  else
    local up_success, fail_reason = robot.up()
    if not up_success then
      return 0, false, fail_reason
    else
      return 1, true
    end
  end
end
 
function turtle.down(...)
  local t = {...}
  local a = t[1]
  local i = 0
 
  if(type(a) == 'number') then
    while(i < a) do
      local down_success, fail_reason = robot.down()
      if not down_success then
        return i, false, fail_reason
      end
      i = i + 1
    end
    return a, true
  else
    local down_success, fail_reason = robot.down()
    if not down_success then
      return 0, false, fail_reason
    else
      return 1, true
    end
  end
end
 
return turtle