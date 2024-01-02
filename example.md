This is just an example of how I edited my qb-spawn

Use this to make yours work flawlessy



```local QBCore = exports['qb-core']:GetCoreObject()
local camZPlus1 = 1500
local camZPlus2 = 50
local pointCamCoords = 75
local pointCamCoords2 = 0
local cam1Time = 500
local cam2Time = 3000
local choosingSpawn = false
local Houses = {}
local cam = nil
local cam2 = nil
local config = require '@ps-housing.shared.shared'
local currentApartment = nil

local function SetDisplay(bool)
    choosingSpawn = bool
    DisplayRadar(true) 
    if bool then
        ExecuteCommand("hidehud")
    else
        ExecuteCommand("showhud")

    end
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool
    })
end

-- local function SetCam(campos)
--     cam2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", campos.x, campos.y, campos.z + camZPlus1, 300.00,0.00,0.00, 110.00, false, 0)
--     PointCamAtCoord(cam2, campos.x, campos.y, campos.z + pointCamCoords)
--     SetCamActiveWithInterp(cam2, cam, cam1Time, true, true)
--     if DoesCamExist(cam) then
--         DestroyCam(cam, true)
--     end

--     cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", campos.x, campos.y, campos.z + camZPlus2, 300.00,0.00,0.00, 110.00, false, 0)
--     PointCamAtCoord(cam, campos.x, campos.y, campos.z + pointCamCoords2)
--     SetCamActiveWithInterp(cam, cam2, cam2Time, true, true)
--     SetEntityCoords(PlayerPedId(), campos.x, campos.y, campos.z)
-- end

RegisterNetEvent('qb-spawn:client:openUI', function(value)
    SetEntityVisible(PlayerPedId(), false)
    DoScreenFadeOut(250)
    Wait(1000)
    DoScreenFadeIn(250)
    QBCore.Functions.GetPlayerData(function(PlayerData)
        print("AAAAAA")
        cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", PlayerData.position.x, PlayerData.position.y, PlayerData.position.z + camZPlus1, -85.00, 0.00, 0.00, 100.00, false, 0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 1, true, true)
    end)
    Wait(500)
    SetDisplay(value)
end)

RegisterNetEvent('qb-houses:client:setHouseConfig', function(houseConfig)
    Houses = houseConfig
end)

RegisterNetEvent('qb-spawn:client:setupSpawns', function(cData, new, apps)
    if not new then
        QBCore.Functions.TriggerCallback('qb-spawn:server:getOwnedHouses', function(houses)
            local myHouses = {}
        if houses ~= nil then
                for i = 1, (#houses), 1 do
                    local house = houses[i]

                    myHouses[#myHouses+1] = {
                        house = house,
                        label = (house.apartment or house.street) .. " " .. house.property_id,
                    }
                end
            end

            Wait(500)
            SendNUIMessage({
                action = "setupLocations",
                locations = QB.Spawns,
                houses = myHouses,
                isNew = new
            })
        end, cData.citizenid)
    elseif new then
        SendNUIMessage({
            action = "setupAppartements",
            locations = apps,
            isNew = new
        })
    end
end)

RegisterNUICallback('setCam', function(data, cb)
    local location = tostring(data.posname)
    local type = tostring(data.type)
    local label = tostring(data.label)
    print(label)
    currentApartment = label
    DoScreenFadeOut(200)
    Wait(500)
    DoScreenFadeIn(200)
    -- if DoesCamExist(cam) then DestroyCam(cam, true) end
    -- if DoesCamExist(cam2) then DestroyCam(cam2, true) end
    if type == "current" then
        QBCore.Functions.GetPlayerData(function(PlayerData)
            -- SetCam(PlayerData.position)
        end)
    elseif type == "house" then
        SetCam(Houses[location].coords.enter)
    elseif type == "normal" then
    --     SetCam(QB.Spawns[location].coords)
    -- elseif type == "appartment" then
        -- SetCam(Apartments.Locations[location].coords.enter)
        -- SetCam(config.locations["apartment2"].enter)
    end
    cb('ok')
end)
RegisterNUICallback('chooseAppa', function(data, cb)
    local ped = PlayerPedId()
    local appaYeet = data.label
    print("apartment info ",currentApartment)
    SetDisplay(false)
    DoScreenFadeOut(500)
    Wait(5000)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    FreezeEntityPosition(ped, false)
    RenderScriptCams(false, true, 500, true, true)
    SetCamActive(cam, false)
    DestroyCam(cam, true)
    SetCamActive(cam2, false)
    DestroyCam(cam2, true)
    SetEntityVisible(ped, true)
    print(appaYeet)
    TriggerServerEvent("ps-housing:server:createNewApartment", currentApartment)
    DoScreenFadeIn(500)
    cb('ok')
end)

local function PreSpawnPlayer()
    SetDisplay(false)
    Wait(2000)
end

local function PostSpawnPlayer(ped)
    FreezeEntityPosition(ped, false)
    RenderScriptCams(false, true, 2500, true, true)
    SetCamActive(cam, false)
    DestroyCam(cam, true)
    Wait(1300)
    SetCamActive(cam2, false)
    DestroyCam(cam2, true)
    SetEntityVisible(PlayerPedId(), true)
    Wait(500)
    -- TriggerEvent("backitems:start")
    DoScreenFadeIn(250)
end

RegisterNUICallback('spawnplayerappartment2', function(data, cb)
    print("Spawned Apartment 2")
    PreSpawnPlayer()
    local Data = data.spawnloc
    local Data2 = data.apartName
    print(Data2)
    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    TriggerEvent('qb-apartments:client:LastLocationHouse', Data, Data2)
    PostSpawnPlayer()
    cb('ok')
end)

RegisterNUICallback('spawnplayer', function(data, cb)
    local location = tostring(data.spawnloc)
    local type = tostring(data.typeLoc)
    local ped = PlayerPedId()
    local PlayerData = QBCore.Functions.GetPlayerData()
    local insideMeta = PlayerData.metadata["inside"]
    if type == "current" then
        PreSpawnPlayer()
        QBCore.Functions.GetPlayerData(function(pos)
            ped = PlayerPedId()
            print("Spawned last location")
            SetEntityCoords(ped, pos.position.x, pos.position.y, pos.position.z)
            SetEntityHeading(ped, pos.position.a)
            Wait(1000)
            TriggerEvent("jays-spawn-anim:doSpawnAnimationAndSpawnIn", pos.position)
            FreezeEntityPosition(ped, false)
        end)
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
        if insideMeta.property_id ~= nil then
            local property_id = insideMeta.property_id
            TriggerServerEvent('ps-housing:server:enterProperty', tostring(property_id))
        end
        -- PostSpawnPlayer()
    elseif type == "house" then
        PreSpawnPlayer()
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
        local property_id = data.spawnloc.property_id
        TriggerServerEvent('ps-housing:server:enterProperty', tostring(property_id))
        -- PostSpawnPlayer()
    elseif type == "normal" then
        local pos = QB.Spawns[location].coords
        PreSpawnPlayer()
        SetEntityCoords(ped, pos.x, pos.y, pos.z)
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
        TriggerServerEvent('ps-housing:server:resetMetaData')
        SetEntityCoords(ped, pos.x, pos.y, pos.z)
        SetEntityHeading(ped, pos.w)
        TriggerEvent("jays-spawn-anim:doSpawnAnimationAndSpawnIn", pos)
        print("Spawned A")
        Wait(8000)
        -- PostSpawnPlayer()
        print("Spawned B")
    end
    cb('ok')
end)

RegisterNetEvent('qb-spawn:client:OpenUIForSelectCoord', function()
    local PlayerCoord = GetEntityCoords(PlayerPedId(), 1)
    local PlayerHeading = GetEntityHeading(PlayerPedId())
    SendNUIMessage({
        action = "AddCoord",
        Coord = {x = PlayerCoord[1], y = PlayerCoord[2], z = PlayerCoord[3], h = PlayerHeading},
            
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback('CloseAddCoord', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

CreateThread(function()
    Wait(500)
        while true do
        Wait(0)
        if choosingSpawn then
            DisableAllControlActions(0)
        else
            Wait(1000)
        end
    end
end)
```

