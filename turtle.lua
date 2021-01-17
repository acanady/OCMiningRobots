--turtle API for use in moving the robot, I prefer the turtle keyword and I also added
--functionality for moving multiple times (turtle.forward(3)) would move the robot 3 blocks forward
--also turtle.right intead of turnRight for convenience. Functions have no return value.
--to use in your own projects make sure you have the file in your robot and they you are requiring it in your program

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

function turtle.forward(...)
  local t = {...}
  local a = t[1]
  local i = 0
  
  if (type(a) == 'number') then  
    while (i  < a) do
      robot.forward()
      i = i + 1
    end
  else
    robot.forward()  
  end
end

function turtle.back(...)
  local t = {...}
  local a = t[1]
  local i = 0
  
  if (type(a) == 'number') then
    while(i < a) do
      robot.back()
      i = i + 1
    end
  else
    robot.back()
  end
end

function turtle.up(...)
  local t = {...}
  local a = t[1]
  local i = 0

  if (type(a) == 'number') then
    while(i < a) do
      robot.up()
      i = i + 1
    end
  else
    robot.up()
  end
end

function turtle.down(...)
  local t = {...}
  local a = t[1]
  local i = 0

  if(type(a) == 'number') then
    while(i < a) do
      robot.down()
      i = i + 1
    end
  else
    robot.down()
  end
end

return turtle 
