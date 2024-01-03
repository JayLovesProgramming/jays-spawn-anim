local randomEmotes = Config.RandomEmotes
local randomIndex = math.random(1, #randomEmotes)
local selectedEmote = randomEmotes[randomIndex]
local inProcessOfMovingCam = false
local freeze = false
local startingCam = nil
local playerHeadBone

local function checkIfCanContinue()
  if exports.qbx_medical:getLaststand()  then 
    inProcessOfMovingCam = false
    exports.qbx_core:Notify("You are currently unconscious", "error", 10000)
    return 
  else if exports.qbx_medical:isDead() then
    inProcessOfMovingCam = false
    exports.qbx_core:Notify("You are currently dead", "error", 10000)
    return 
    end
  end  
end

local function initialLoadingIn(coordsWhereYouSpawn)
  exports.scully_emotemenu:setLimitation(true) -- false to disable it
  startDisablingControlsPlz()
  exports.scully_emotemenu:cancelEmote()
  SetEntityVisible(PlayerPedId(), false)
  DoScreenFadeOut(100)
  Wait(500)
  local startingCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
  SetCamCoord(startingCam, coordsWhereYouSpawn.x + 1, coordsWhereYouSpawn.y + 1, coordsWhereYouSpawn.z + Config.HowHighInTheSky*100) -- Make this get ground coords and do maths
  PointCamAtEntity(startingCam, PlayerPedId(),0,0,0,1)
  SetCamFov(startingCam, Config.CamFov + 10.0)
  RenderScriptCams(true, true, 1, true, true)
  Wait(500)
  DoScreenFadeIn(2000)
end

local function destroyAllCameras(durationToRender)
  SetNuiFocus(false, false)
  RenderScriptCams(false, true, durationToRender, true, true)
  Wait(5)
  DestroyAllCams()
end

local function startSpawnCamera(coordsWhereYouSpawn)
  initialLoadingIn(coordsWhereYouSpawn)
    Wait(2000)
    if Config.Debug then
      print("Destroyed Cam 1")
    end
    destroyAllCameras(Config.HowLongItTakesToZoomInToPlayer)
    SetEntityVisible(PlayerPedId(), true)
    checkIfCanContinue()
    exports.scully_emotemenu:playEmoteByCommand(selectedEmote)
    if Config.Debug then
      print("Played emote: ",selectedEmote)
    end
    Wait(Config.HowLongItTakesToZoomInToPlayer + 50)
    if Config.Debug then
      print("Made new cam")
    end
    checkIfCanContinue()
    playerHeadBone = GetPedBoneIndex(PlayerPedId(), "SKEL_HEAD")
    startingCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    ShakeCam(startingCam, "FAMILY5_DRUG_TRIP_SHAKE", 0.35)
    freeze = true
    if selectedEmote == "prone" then
      SetCamCoord(startingCam, GetEntityCoords(PlayerPedId()).x + 3.5, GetEntityCoords(PlayerPedId()).y - 2, GetEntityCoords(PlayerPedId()).z - 0.9 ) -- Make this get ground coords and do maths
      PointCamAtPedBone(startingCam, PlayerPedId(), playerHeadBone, 1, 1, -0.5, true)
      SetCamFov(startingCam, Config.CamFovProne)
      RenderScriptCams(true, true, 3500, true, true)
    else
      SetCamCoord(startingCam, coordsWhereYouSpawn.x + 4, coordsWhereYouSpawn.y - 3.8, coordsWhereYouSpawn.z + 1.3) -- Make this get ground coords and do maths
      PointCamAtPedBone(startingCam, PlayerPedId(), playerHeadBone, 1, 1, 0, true)
      SetCamFov(startingCam, Config.CamFov)
      RenderScriptCams(true, true, Config.WaitTimeToRenderCamera, true, true)
    end
    Wait(Config.WaitTimeToRenderCamera) -- Wait before ending final camera (Usually while doing anim)
    destroyAllCameras(2000)
    if Config.Debug then
      print("Destroyed Cam 2")
    end
    Wait(1300)
    freeze = false
    inProcessOfMovingCam = false
    StopCamShaking(startingCam, true)
    exports.scully_emotemenu:setLimitation(false) -- false to disable it
    exports.scully_emotemenu:cancelEmote()
    FreezeEntityPosition(PlayerPedId(), false)
end

function startDisablingControlsPlz()
CreateThread(function()
  inProcessOfMovingCam = true
  while inProcessOfMovingCam do
      Wait(0)
      if Config.DebugAdvanced then
        print("Started disabling controls")
      end
      if freeze then
        FreezeEntityPosition(PlayerPedId(), true)
      end
      DisableControlAction(0, 1, true)
      DisableControlAction(0, 2, true)
      DisableControlAction(0, 21, true)
      DisableControlAction(0, 30, true)
      DisableControlAction(0, 31, true)
      DisableControlAction(0, 36, true)
      DisableControlAction(0, 72, true)
      DisableControlAction(0, 75, true)
      DisableControlAction(0, 106, true)
      DisableControlAction(0, 64, true)
      DisableControlAction(0, 63, true)
      DisableControlAction(0, 25, true)
      DisableControlAction(0, 245, true) -- Chat
      DisableControlAction(0, 309, true) -- Chat
      DisableControlAction(0, 246, true) -- Chat
      DisableControlAction(0, 24, true) -- disable attack
      DisableControlAction(0, 47, true) -- disable weapon
      DisableControlAction(0, 58, true) -- disable weapon
      DisableControlAction(0, 263, true) -- disable melee
      DisableControlAction(0, 264, true) -- disable melee
      DisableControlAction(0, 257, true) -- disable melee
      DisableControlAction(0, 140, true) -- disable melee
      DisableControlAction(0, 141, true) -- disable melee
      DisableControlAction(0, 142, true) -- disable melee
      DisableControlAction(0, 143, true) -- disable melee
      DisableControlAction(27, 75, true) -- disable exit vehicle
      DisableControlAction(0, 32, true) -- move (w)
      DisableControlAction(0, 34, true) -- move (a)
      DisableControlAction(0, 33, true) -- move (s)
      DisableControlAction(0, 35, true) -- move (d)
      DisablePlayerFiring(PlayerId(), true)
      end
      Wait(1000)
      inProcessOfMovingCam = false
      if Config.Debug then
        print("Stopped disabling controls")
      end
      FreezeEntityPosition(PlayerPedId(), false)
    end)
end

RegisterNetEvent("jays-spawn-anim:doSpawnAnimationAndSpawnIn", function(selectedSpawnCoords)
  startSpawnCamera(selectedSpawnCoords)
end)

-- THESE ARE ONLY DEBUG COMMANDS ///// MAKE SURE TO DISABLE IN NORMAL ENVIROMENT!!!! -- 
CreateThread(function()

      if Config.Debug then

    -- COMMAND 1
    RegisterCommand("startstartanim", function()
      local selectedSpawnCoords = GetEntityCoords(PlayerPedId()) -- Eventually callback from server the required coords
      TriggerEvent("jays-spawn-anim:doSpawnAnimationAndSpawnIn", selectedSpawnCoords)
    end)

    -- COMMAND 2
    RegisterCommand("testmainanim", function()
      local playerHeadBone = GetPedBoneIndex(PlayerPedId(), "SKEL_HEAD")
      local startingCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
      SetCamCoord(startingCam, GetEntityCoords(PlayerPedId()).x + 6, GetEntityCoords(PlayerPedId()).y - 5, GetEntityCoords(PlayerPedId()).z + 1) -- Make this get ground coords and do maths
        SetCamFov(startingCam, Config.CamFov)
        RenderScriptCams(true, true, Config.WaitTimeToRenderCamera, true, true)
        PointCamAtPedBone(startingCam, PlayerPedId(), playerHeadBone, 0, 0, 0, true)
        Wait(3000)
      destroyAllCameras()
    exports.scully_emotemenu:cancelEmote()
  end)

    RegisterCommand("testproneanim", function()
      ExecuteCommand("e prone")
      local playerHeadBone = GetPedBoneIndex(PlayerPedId(), "SKEL_HEAD")
      local startingCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
      SetCamCoord(startingCam, GetEntityCoords(PlayerPedId()).x - 3.5, GetEntityCoords(PlayerPedId()).y + 2, GetEntityCoords(PlayerPedId()).z - 0.9 ) -- Make this get ground coords and do maths
        PointCamAtPedBone(startingCam, PlayerPedId(), playerHeadBone, 1, 1, -0.5, true)
        SetCamFov(startingCam, Config.CamFovProne)
        RenderScriptCams(true, true, Config.WaitTimeToRenderProneCamera, true, true)
        Wait(5000)
        destroyAllCameras()
        exports.scully_emotemenu:cancelEmote()
    end)

    -- COMMAND 3
    RegisterCommand("destroycameras", function()
      destroyAllCameras()
    end)

  end
end)

--==TO DO==-- 

-- local function startToStandUpPlease()  -- adding later on
