local randomEmotes = {"stretch3","stretch4","prone"}
local randomIndex = math.random(1, #randomEmotes)
local selectedEmote = randomEmotes[randomIndex]

local function initialLoadingIn()
  exports.scully_emotemenu:cancelEmote()
  SetEntityVisible(cache.ped, false)
  DoScreenFadeOut(1)
  local startingCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
  local currentCoords = GetEntityCoords(PlayerPedId()) -- Eventually callback from server the required coords
  SetCamCoord(startingCam, currentCoords.x + 1, currentCoords.y + 1, currentCoords.z + 500) -- Make this get ground coords and do maths
  SetCamFov(startingCam, 150.0)
  RenderScriptCams(true, true, 3500, true, true)
  Wait(1000)
  PointCamAtCoord(startingCam, currentCoords.x, currentCoords.y, currentCoords.z-0.1)
  Wait(1000)
  DoScreenFadeIn(2000)
end

local function stoppingCam1stStage(durationToRender)
  SetNuiFocus(false, false)
  RenderScriptCams(false, true, durationToRender, true, true)
  DestroyAllCams()
end

local function startSpawnCamera()
  initialLoadingIn()

  Wait(4500)

  stoppingCam1stStage(7500)

  SetEntityVisible(cache.ped, true)
  exports.scully_emotemenu:playEmoteByCommand(selectedEmote)
  print("Played emote: ",selectedEmote)

  Wait(7000)
  
  local startingCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
  local currentCoords = GetEntityCoords(PlayerPedId()) -- Eventually callback from server the required coords
  if selectedEmote == "prone" then
    SetCamCoord(startingCam, currentCoords.x + 1, currentCoords.y - 2, currentCoords.z - 0.5) -- Make this get ground coords and do maths
  else
    SetCamCoord(startingCam, currentCoords.x + 1, currentCoords.y + 2, currentCoords.z + 0.5) -- Make this get ground coords and do maths
  end
    SetCamFov(startingCam, 80.0)
    RenderScriptCams(true, true, 5500, true, true)
    PointCamAtCoord(startingCam, currentCoords.x, currentCoords.y, currentCoords.z-0.4)
  
  Wait(6000)

  stoppingCam1stStage(5000)
  Wait(2000)

  exports.scully_emotemenu:cancelEmote()
end

local function startToStandUpPlease()

end

RegisterCommand("startstartanim", function()
  startSpawnCamera()
end)

RegisterCommand("stopstartanim", function()
  stoppingCam1stStage()
end)
