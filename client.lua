local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand(Config.Command, function(source, args, raw)
    local playerData = QBCore.Functions.GetPlayerData()
    local playerPed = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if not vehicle or vehicle == 0 then
        if Config.NotifyType == 'ox_lib' then
            lib.notify({
                title = "You're not in a vehicle!",
                description = '',
                type = 'error'
            })
        else
            QBCore.Functions.Notify("You're not in a vehicle!", "error")
        end
        return
    end

    if not Config.ForEveryone then
        for _, job in pairs(Config.Jobs) do
            if playerData.job.name == job and vehicle then
                local options = {}
                for modName, modIndex in pairs(Config.ModTypes) do
                    local modCount = GetNumVehicleMods(vehicle, modIndex)
                    if modCount > 0 then
                        table.insert(options, {
                            label = modName .. " (" .. modCount .. " mods available)",
                            description = "Select to modify",
                            args = {
                                modName = modName,
                                modCount = modCount,
                                modType = modIndex
                            }
                        })

                        if Config.MenuType == 'ox_lib' then
                            lib.registerMenu({
                                id = 'modkits_menu',
                                title = 'Vehicle Modkits',
                                position = 'top-right',
                                options = options
                            }, function(selected, _, args)
                                TriggerEvent("pd_modkits:client:ModMenu", args)
                            end)

                            lib.showMenu('modkits_menu')
                        else
                            exports['qb-menu']:openMenu(options)
                        end
                    else
                        if Config.NotifyType == 'ox_lib' then
                            lib.notify({
                                title = "Vehicle doesnt have modkits!",
                                description = '',
                                type = 'error'
                            })
                        else
                            QBCore.Functions.Notify("Vehicle doesnt have modkits!", "error")
                        end
                    end
                end
            end
        end
    else
        local options = {} 
        for modName, modIndex in pairs(Config.ModTypes) do
            local modCount = GetNumVehicleMods(vehicle, modIndex)
            if modCount > 0 then
                table.insert(options, {
                    label = modName .. " (" .. modCount .. " mods available)",
                    description = "Select to modify",
                    args = {
                        modName = modName,
                        modCount = modCount,
                        modType = modIndex
                    }
                })

                if Config.MenuType == 'ox_lib' then
                    lib.registerMenu({
                        id = 'modkits_menu',
                        title = 'Vehicle Modkits',
                        position = 'top-right',
                        options = options
                    }, function(selected, _, args)
                        TriggerEvent("pd_modkits:client:ModMenu", args)
                    end)
                    lib.showMenu('modkits_menu')
                else
                    exports['qb-menu']:openMenu(options)
                end
            else
                if Config.NotifyType == 'ox_lib' then
                    lib.notify({
                        title = "Vehicle doesnt have modkits!",
                        description = '',
                        type = 'error'
                    })
                else
                    QBCore.Functions.Notify("Vehicle doesnt have modkits!", "error")
                end
            end
        end
    end
end)

RegisterNetEvent('pd_modkits:client:ModMenu', function(data)
    local options = {}
    
    for i = 0, data.modCount do
        table.insert(options, {
            label = data.modName .. " " .. i,
            description = "Select to modify",
            args = {
                modName = data.modName,
                modType = data.modType,
                modIndex = i
            }
        })
    end
    
    table.insert(options, {
        label = "< Go Back",
        args = {},
        onSelect = function()
            if Config.Framework == 'ox_lib' then
                lib.showMenu('modkits_menu')
            else
                exports['qb-menu']:openMenu(options)
            end
        end
    })

    if Config.MenuType == 'ox_lib' then
        lib.registerMenu({
            id = 'modkits_submenu',
            title = data.modName .. " (" .. data.modCount .. " mods available)",
            position = 'top-right',
            options = options
        }, function(selected, _, args)
            TriggerEvent("pd_modkits:client:setModkits", args)
        end)

        lib.showMenu('modkits_submenu')
    else
        exports['qb-menu']:openMenu(options)
    end
end)

RegisterNetEvent('pd_modkits:client:setModkits', function(data)
    local playerPed = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    
    if vehicle and vehicle ~= 0 then
        local modCount = GetNumVehicleMods(vehicle, data.modType)
        if modCount > 0 then
            SetVehicleMod(vehicle, data.modType, data.modIndex, false)
            if Config.NotifyType == 'ox_lib' then
                lib.notify({
                    title = "Applied ".. data.modIndex .." for mod " .. data.modName,
                    description = '',
                    type = 'success'
                })
            else
                QBCore.Functions.Notify("Applied ".. data.modIndex .." for mod " .. data.modName, "success")
            end
        else
            if Config.NotifyType == 'ox_lib' then
                lib.notify({
                    title = "No mods available for this category!",
                    description = '',
                    type = 'error'
                })
            else
                QBCore.Functions.Notify("No mods available for this category!", "error")
            end
        end
    end
end)
