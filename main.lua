--find block position

local _POSITION_ = { commands.getBlockPosition() }

local tArgs = { ... }
if #tArgs ~= 1 and #tArgs ~= 2 then
  print( "Usage: platform <username> [radius]" )
  error()
end

local rad = tonumber( tArgs[ 2 ] ) or 2

local platform = {}

local function fillP()
  for x = -rad, rad do
    for z = -rad, rad do
      platform[ #platform + 1 ] = vector.new( x, 0, z )
    end
  end
end

local function getPlayerPosition( p )
  local success, t = commands.exec( "/tp " .. p .. " ~ ~ ~" )
  if not success then
    return false
  end
  local x, y, z = t[1]:match( "to (%-?%d+%.?%d*),(%-?%d+%.?%d*),(%-?%d+%.?%d*)" )
  return math.floor( x ), math.floor( y ), math.floor( z )
end

local id = os.startTimer( 0.3 )

local last = {}
local current = {}
local pos
local toExecute = {}

local function checkPlatform()
  while #platform > 0 do
    local  v = table.remove( platform, #platform )
    local b = pos + v
    local bstr = b:tostring()
    local name = (last[bstr] and "glass") or commands.getBlockInfo( b.x, b.y, b.z ).name
    if name == "minecraft:air" then
      current[ bstr ] = b
      if not last[ bstr ] then
        toExecute[ #toExecute + 1 ] = "setblock " .. b.x .. " " .. b.y .. " " .. b.z .. " minecraft:glass"
      end
    elseif name == "glass" then
      current[ bstr ] = b
    end
    last[ bstr ] = nil
  end
end

while true do
  local x, y, z = getPlayerPosition( tArgs[ 1 ] )
  pos = vector.new( x, y - 1, z )
  local time = os.clock()
  fillP()

  parallel.waitForAll( checkPlatform, checkPlatform, checkPlatform, checkPlatform, checkPlatform )
  
  for k, v in pairs( last ) do
      toExecute[ #toExecute + 1 ] = "setblock " .. v.x .. " " .. v.y .. " " .. v.z .. " minecraft:air"
  end

  for k, v in pairs( toExecute ) do
    commands.execAsync( v )
  end

  last = current
  current = {}
  toExecute = {}
  print( os.clock() - time )
  while true do
    local event, tid = os.pullEvent( "timer" )
    if id == tid then
      break
    end
  end
  id = os.startTimer( 0.3 )
end
