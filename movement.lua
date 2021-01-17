--Movement code is a library for the movement
--functions that have the robot moving
--to a specific location

turtle = require("turtle")
movement = {}

--takes in a location table with x,y,z values
--and moves the robot to that position

--function movement.goto(loc) 
--end

--function that takes in the direction you
--wish the turtle to face and then turns it
--that way efficiently as possible

function movement.face(facing,direction)
  local dist = 0
  while(facing % 4 ~= direction) do
    dist = dist + 1  
    facing = facing + 1
  end

  if (dist == 3) then
    turtle.left()
  elseif (dist == 1) then
    turtle.right()
  else
    turtle.right(2)  
  end

end

return movement