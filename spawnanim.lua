local randomEmotes = Config.RandomEmotes
local randomIndex = math.random(1, #randomEmotes)
local selectedEmote = randomEmotes[randomIndex]

local function initialLoadingIn(coordsWhereYouSpawn)
  exports.scully_emotemenu:cancelEmote()
  SetEntityVisible(PlayerPedId(), false)
  DoScreenFadeOut(1)
  local startingCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
  SetCamCoord(startingCam, coordsWhereYouSpawn.x + 1, coordsWhereYouSpawn.y + 1, coordsWhereYouSpawn.z + 500) -- Make this get ground coords and do maths
  SetCamFov(startingCam, 150.0)
  RenderScriptCams(true, true, 3500, true, true)
  Wait(1000)
  PointCamAtCoord(startingCam, coordsWhereYouSpawn.x, coordsWhereYouSpawn.y, coordsWhereYouSpawn.z-0.1)
  Wait(1000)
  DoScreenFadeIn(2000)
end

local function destroyAllCameras(durationToRender)
  SetNuiFocus(false, false)
  RenderScriptCams(false, true, durationToRender, true, true)
  DestroyAllCams()
end

local function startSpawnCamera(coordsWhereYouSpawn)
  initialLoadingIn(coordsWhereYouSpawn)
  Wait(4500)
  destroyAllCameras(7500)
  SetEntityVisible(PlayerPedId(), true)
  exports.scully_emotemenu:playEmoteByCommand(selectedEmote)
  if Config.Debug then
    print("Played emote: ",selectedEmote)
  end
  Wait(7000)
  local startingCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
  if selectedEmote == "prone" then
    SetCamCoord(startingCam, coordsWhereYouSpawn.x + 1, coordsWhereYouSpawn.y - 2, coordsWhereYouSpawn.z - 0.5) -- Make this get ground coords and do maths
  else
    SetCamCoord(startingCam, coordsWhereYouSpawn.x + 1, coordsWhereYouSpawn.y + 2, coordsWhereYouSpawn.z + 0.5) -- Make this get ground coords and do maths
  end
    SetCamFov(startingCam, 80.0)
    RenderScriptCams(true, true, 5500, true, true)
    PointCamAtCoord(startingCam, coordsWhereYouSpawn.x, coordsWhereYouSpawn.y, coordsWhereYouSpawn.z-0.4)
    Wait(6000)
    destroyAllCameras(5000)
    Wait(2000)
    exports.scully_emotemenu:cancelEmote()
end

-- local function startToStandUpPlease()  -- adding later on
-- end

RegisterNetEvent("jays-spawn-anim:doSpawnAnimationAndSpawnIn", function(selectedSpawnCoords)
  startSpawnCamera(selectedSpawnCoords)
end)

CreateThread(function()
  if Config.Debug then
    RegisterCommand("startstartanim", function()
      local selectedSpawnCoords = GetEntityCoords(PlayerPedId()) -- Eventually callback from server the required coords
      TriggerEvent("jays-spawn-anim:doSpawnAnimationAndSpawnIn", selectedSpawnCoords)
    end)

    RegisterCommand("stopstartanim", function()
      destroyAllCameras()
    end)
  end
end)
