local dashcamActive = false
local attachedVehicle = nil
local cameraHandle = nil

local screenEffect = "HeistLocate"

Citizen.CreateThread(function()
    while true do
        if dashcamActive then

            if dashcamActive and not IsPedInAnyVehicle(GetPlayerPed(PlayerId()), false) then
                DisableDash()
                dashcamActive = false
            end

            if IsPedInAnyVehicle(GetPlayerPed(PlayerId()), false) and dashcamActive then
                UpdateDashcam()
            end

        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        if IsControlJustPressed(1, 311) and IsPedInAnyVehicle(GetPlayerPed(PlayerId()), false) then
            if dashcamActive then
                DisableDash()
            else
                EnableDash()
            end
        end

        if dashcamActive then
            local bonPos = GetWorldPositionOfEntityBone(attachedVehicle, GetEntityBoneIndexByName(attachedVehicle, "windscreen"))
            local vehRot = GetEntityRotation(attachedVehicle, 0)
            SetCamCoord(cameraHandle, bonPos.x, bonPos.y, bonPos.z)
            SetCamRot(cameraHandle, vehRot.x, vehRot.y, vehRot.z, 0)
        end
        Citizen.Wait(0)
    end
end)

function EnableDash()
    attachedVehicle = GetVehiclePedIsIn(GetPlayerPed(PlayerId()), false)
    if DashcamConfig.RestrictVehicles then
        if CheckVehicleRestriction() then
            StartScreenEffect(screenEffect, -1, false)
            local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
            RenderScriptCams(1, 0, 0, 1, 1)
            SetFocusEntity(attachedVehicle)
            cameraHandle = cam
            SendNUIMessage({
                type = "enabledash"
            })
            dashcamActive = true
        end
    else
        StartScreenEffect(screenEffect, -1, false)
        local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
        RenderScriptCams(1, 0, 0, 1, 1)
        SetFocusEntity(attachedVehicle)
        cameraHandle = cam
        SendNUIMessage({
            type = "enabledash"
        })
        dashcamActive = true
    end
end

function DisableDash()
    StopScreenEffect(screenEffect)
    RenderScriptCams(0, 0, 1, 1, 1)
    DestroyCam(cameraHandle, false)
    SetFocusEntity(GetPlayerPed(PlayerId()))
    SendNUIMessage({
        type = "disabledash"
    })
    dashcamActive = false
end

function UpdateDashcam()
    local gameTime = GetGameTimer()
    local year, month, day, hour, minute, second = GetLocalTime()
    local unitNumber = GetPlayerServerId(PlayerId())
    local unitName = GetPlayerName(PlayerId())
    local unitSpeed = nil

    if DashcamConfig.useMPH then
        unitSpeed = GetEntitySpeed(attachedVehicle) * 2.23694
    else
        unitSpeed = GetEntitySpeed(attachedVehicle) * 3.6
    end

    SendNUIMessage({
        type = "updatedash",
        info = {
            gameTime = gameTime,
            clockTime = {year = year, month = month, day = day, hour = hour, minute = minute, second = second},
            unitNumber = unitNumber,
            unitName = unitName,
            unitSpeed = unitSpeed,
            useMPH = DashcamConfig.useMPH
        }
    })
end

function CheckVehicleRestriction()
    if DashcamConfig.RestrictionType == "custom" then
        for a = 1, #DashcamConfig.AllowedVehicles do
            print(GetHashKey(DashcamConfig.AllowedVehicles[a]))
            print(GetEntityModel(attachedVehicle))
            if GetHashKey(DashcamConfig.AllowedVehicles[a]) == GetEntityModel(attachedVehicle) then
                return true
            end
        end
        return false
    elseif DashcamConfig.RestrictionType == "class" then
        if GetVehicleClass(attachedVehicle) == 18 then
            return true
        else
            return false
        end
    else
        return false
    end
end