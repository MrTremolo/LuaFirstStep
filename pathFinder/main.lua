-- Priority Queue structure with functions of
-- pop element
-- push element
-- check if queue contains definite element
PriorityQueue = require("PriorityQueue")

-- Function for finding manhattan distance from one point to another
function manhattanDistance(onePoint, secondPoint)
  local dy = math.abs(onePoint[1] - secondPoint[1])
  local dx = math.abs(onePoint[2] - secondPoint[2])
  return dx + dy
end

-- Function for passing the shortest way 
-- with numerated shortest paths
-- and fill it with special characters
-- @ Works after pathFindingAStar function @
function findBackWay(labyrinth, theend)
      
  -- elem - the point from which we are looking for a way
  local elem = theend
  
  -- Memorize number of end value
  local num = labyrinth[theend[1]][theend[2]]
  
  -- And fill it with special characters
  labyrinth[theend[1]][theend[2]] = "||||"
  
  while true do
    
    -- 4 paths to go
    local dxy = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}}
    for _, v in pairs(dxy) do
      
      -- Points of new node
      local ny = elem[1] + v[1]
      local nx = elem[2] + v[2]
      
      -- If new node is beginning
      if labyrinth[ny][nx] == 1 then
        labyrinth[ny][nx] = 'I'
        return
      end
      
      -- Check new node on type and if its value 
      -- less on 1 from the previous point -
      -- it will be our correct direction
      if type(labyrinth[ny][nx]) == 'number' and num - labyrinth[ny][nx] == 1 then
        
        -- Memorize number of new node value
        num = labyrinth[ny][nx]
        
        -- And fill it with special characters
        labyrinth[ny][nx] = "||||"
        elem = {ny, nx}
        break
        
      end
    end
  end
end

-- Print Labyrinth vertices
function printMinos(labyrinth, exist)
  
  for i = 0, table.getn(labyrinth[1]) do
      io.write(string.format("%5s ", i))
  end
  io.write('\n')
  
  for i = 0, table.getn(labyrinth[1]) do
      io.write(string.format("%5s ", "-----"))
  end
  
  io.write('\n')
  
  for i = 1, table.getn(labyrinth) do
    io.write(string.format("%4s ", i))
    io.write(string.format("%1s ", '|'))
    for j = 1, table.getn(labyrinth[i]) do
      io.write(string.format("%5s ", labyrinth[i][j]))
    end
    io.write('\n')
  end
  
    
  -- If there is no way from start to end point
  if not exist then
    print "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    print "No Way From Start To End"
    print "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
  end
    
end

-- Output labyrinth into the file
function outputMinos(labyrinth, fileString, exist)
  
  local file = io.open(fileString, 'w+')
  
  -- If there is no way to reach final point from start
  if not exist then
    file:write("No Possible way")
    file:close()
    return
  end
    
  for i = 1, table.getn(labyrinth) do
    for j = 1, table.getn(labyrinth[i]) do
      
      -- We will write into the file only special symbols from labyrinth - ('0', 'E', 'I', ' ') and '||||' for correct path
      if labyrinth[i] and (labyrinth[i][j] == '||||' or labyrinth[i][j] == ' ' or 
        labyrinth[i][j] == 'I' or labyrinth[i][j] == 'E' or labyrinth[i][j] == '0') then
        file:write(string.format("%4s ", labyrinth[i][j]))
        
      -- Instead of possible paths, spaces will be written
      elseif labyrinth[i] and type(labyrinth[i][j]) == 'number' then
        file:write(string.format("%4s ", ' '))
      end
    end
    file:write('\n')
  end
  
  file:close()
end

-- pathFinding function with A* algorithm
-- labyrinth - array of vertices of labyrinth
-- Labyrinth will filling with values of shortest path from beginning
-- start - {start y point of labyrinth, start x point of labyrinth}
-- theend - {final y point of labyrinth, final x point of labyrinth}
-- fileNameOutput - output file with finded or not and shown way
function pathFindingAStar(labyrinth, start, theend, fileNameOutput)
  
  -- We will start pathFinding from 1
  labyrinth[start[1]][start[2]] = 1
  
  -- h - heuristic approximation of the cost of the path 
  --     to the target from node 
  -- It will be manhattan distance
  local h = manhattanDistance(start, theend)
  
  -- g - the lowest cost of arriving at node 
  --     from the start point
  -- In the beginning there will be 0
  -- f - The valuation value assigned to node
  local f = 0 + h
    
  -- List with passed vertices
  local closed = {}
  
    -- Priority Queue with unchecked neighbours
  -- Priority queue's key is f
  local open = PriorityQueue:new()

  -- Beginning loop from start point
  open:push(start, f)
  
  -- Possible paths of movement
  local dxy = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}}
  
  -- sizeOfArray(open) will be 0 if 
  -- there is not a way to pass to the end point from start
  while open:size() > 0 do
    
    -- Pop node with max f 
    elem = open:pop()
    
    -- insert node to closed array as passed 
    -- key will be y point
    -- value will be {x point = true}
    -- to easy check if there is definite node
    if closed[elem[1]] == nil then 
      closed[elem[1]] = {}
      closed[elem[1]][elem[2]] = true
    else
      closed[elem[1]][elem[2]] = true
    end
    
    -- 4 paths to go
    for _, v in pairs(dxy) do
      
      -- New y point
      local ny = elem[1] + v[1]
      
      -- New x point
      local nx = elem[2] + v[2]
      
      -- If new node is final point
      if (labyrinth[ny] and labyrinth[ny][nx] == 'E') then 
        findBackWay(labyrinth, {elem[1], elem[2]})
        printMinos(labyrinth, true)
        outputMinos(labyrinth, fileNameOutput, true)
        return
      end
      
      -- If new node in the bounds of labyrinth, not a wall
      -- and there is not in closed array
      if nx > 0 and ny > 0 and nx < table.getn(labyrinth[ny]) and 
      ny < table.getn(labyrinth) and labyrinth[ny][nx] ~= '0' and 
      (closed[ny] == nil or closed[ny][nx] == nil) then 
        
        local h = manhattanDistance({ny, nx}, theend)
        
        -- g will be g of past node plus 1 
        local f = labyrinth[elem[1]][elem[2]] + 1 + h
        
        -- Check if new node was the neighboor node of overpast node
        -- pastF is possible f value that was given by another node
        local pastF = open:contains(ny, nx)
        
        if not pastF or pastF >= f then
          
          -- It's actually g value of point 
          -- with minus 1, because we have started from g = 1
          labyrinth[ny][nx] = labyrinth[elem[1]][elem[2]] + 1
          
          -- Push node if it's not already pushed
          if not open:contains(ny, nx) then 
            open:push({ny, nx}, f)
          end
          
        end
        
      end
    end
  end
  printMinos(labyrinth, false)
  outputMinos(labyrinth, fileNameOutput, false)
end

-- Function for input labyrinth vertices into array from file
function inputLabyrinthFromFile(fileName)
  
  -- ArrayWith - array of vertices of labyrinth
  local ArrayWithVerticesOfLabyrinth = {}

  -- i - current y point
  local i = 1;
  
  -- point of start node
  local start = {}
  
  -- point of final node
  local theend = {}

  for line in io.lines(fileName) do
    ArrayWithVerticesOfLabyrinth[i] = {}
    for j = 1, #line do
      local c = string.sub(line, j, j)
      ArrayWithVerticesOfLabyrinth[i][j] = c
      if c == 'I' then 
        start[1] = i
        start[2] = j
      elseif c == 'E' then
        theend[1] = i
        theend[2] = j
      end
    end
    i = i + 1
  end

  return ArrayWithVerticesOfLabyrinth, start, theend
end

-- Files - TestCases
filesNames = {"firstTest.txt", "secondTest.txt", "thirdTest.txt", "fourthTest.txt", "workTestLabyrinth.txt"}

-- Files - correct results of TestCases
correctResults = {"firstTestCorrect.txt", "secondTestCorrect.txt", "thirdTestCorrect.txt", "fourthTestCorrect.txt", "workTestLabyrinthCorrect.txt"}

for i = 1, #filesNames do
  -- Input labyrinth vertices into array from file
  -- Start - start point node
  -- Theend - final point node
  local ArrayWithVerticesOfLabyrinth, start, theend = inputLabyrinthFromFile(filesNames[i])
  pathFindingAStar(ArrayWithVerticesOfLabyrinth, start, theend, "result.txt")
  
  -- Check result path of function pathFindingAStar in file result.txt
  -- with correct testCases in correctResults[i] files
  local resultedPathTextFile = io.open("result.txt")
  local content = resultedPathTextFile:read("*all")
  resultedPathTextFile:close()
  
  local correctPathTextFile = io.open(correctResults[i])
  local correct = correctPathTextFile:read("*all")
  correctPathTextFile:close()
  
  if correct == content then
    print "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    print(i .. " - CORRECT")
    print "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
  else
    print "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
    print(i .. " - WRONG")
    print "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
  end
end


  