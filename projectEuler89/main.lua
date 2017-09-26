-- i - Total Number of modifications in file
i = 0

-- Every not optimal sequence of 4 repeated symbols 
-- allows to optimize number and delete 2 characters
-- IIII - IV, XXXX - XL, CCCC - CD
-- or 3 if 4 repeated symbols was after special digit 
-- VIIII - IX, LXXXX - XC, DCCCC - CM
for line in io.lines("roman.txt")
do 

  if string.find(line, "VIIII") then
    i = i + 3
  elseif string.find(line , "IIII") then
    i = i + 2
  end
  
  
  if string.find(line, "LXXXX") then
    i = i + 3
  elseif string.find(line, "XXXX") then
    i = i + 2
  end
  
  if string.find(line, "DCCCC") then
    i = i + 3
  elseif string.find(line, "CCCC") then
    i = i + 2
  end

end

print(i)