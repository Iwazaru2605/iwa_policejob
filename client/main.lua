print("^0================================IWA POLICE JOB================================7")
print("^0[^4Author^0] ^7:^0 Iwazaru^7")
print("^0[^3Version^0] ^7:^0 ^01.0.1^7")
print("^0[^4Server^0] ^7:^0 SunnyRP^7")
print("^0=================================FOR SUNNY RP=================================^7")

local PlayerData, CurrentActionData, handcuffTimer, dragStatus, blipsCops, currentTask, spawnedVehicles = {}, {}, {}, {}, {}, {}, {}
local HasAlreadyEnteredMarker, isDead, isHandcuffed, hasAlreadyJoined, isInShopMenu = false, false, false, false, false, false
local LastStation, LastPart, LastPartNum, LastEntity, CurrentAction, CurrentActionMsg
local personalmenu = {}
dragStatus.isDragged = false
local ESX = nil
locksound = false
onDuty = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

_menuPool =  NativeUI.CreatePool()
cloakMenu = NativeUI.CreateMenu("L.S.P.D", "Vestiaires", "")
_menuPool:Add(cloakMenu)

armMenu = NativeUI.CreateMenu("L.S.P.D", "Armurie", "")
_menuPool:Add(armMenu)

carMenu = NativeUI.CreateMenu("L.S.P.D", "Garage")
_menuPool:Add(carMenu)

bossMenu = NativeUI.CreateMenu("L.S.P.D", "Gestion entreprise")
_menuPool:Add(bossMenu)

mobMenu = NativeUI.CreateMenu("L.S.P.D", "Menu intéractions")
_menuPool:Add(mobMenu)

RegisterNetEvent('esx_policejob:onDuty')
AddEventHandler('esx_policejob:onDuty', function()
	onDuty = true
	local mugshot, mugshotStr = ESX.Game.GetPedMugshot(PlayerPedId())
	ESX.ShowAdvancedNotification("L.S.P.D", "Prise de service", "Vous avez pris votre service !", mugshotStr, 8)
    UnregisterPedheadshot(mugshot)
end)

RegisterNetEvent('esx_policejob:offDuty')
AddEventHandler('esx_policejob:offDuty', function()
	local mugshot, mugshotStr = ESX.Game.GetPedMugshot(PlayerPedId())
	ESX.ShowAdvancedNotification("L.S.P.D", "Prise de service", "Vous avez pris votre fin de service !", mugshotStr, 8)
    UnregisterPedheadshot(mugshot)
	onDuty = false
end)

function AddCloakMenu(menu)
	local playerPed = PlayerPedId()
		
	separator1 = NativeUI.CreateItem("↓ Service", "")
	civil = NativeUI.CreateItem("Prendre votre fin de service", "Appuyez sur ENTRER pour prendre votre fin de service")
	service = NativeUI.CreateItem("Prendre votre service", "Appuyez sur ENTRER pour prendre votre service")
	separator2 = NativeUI.CreateItem("↓ Tenues", "")
    bullet = NativeUI.CreateItem("Mettre un kevlar", "Appuyez sur ENTRER pour mettre un kevlar")
	tenu = NativeUI.CreateItem("Mettre votre tenue de service", "Appuyez sur ENTRER pour mettre votre uniforme")

	separator1:RightLabel("↓")
	service:RightLabel("→")
	separator2:RightLabel("↓")
	civil:RightLabel("→")
	bullet:RightLabel("→")
	tenu:RightLabel("→")

	menu:AddItem(separator1)
	menu:AddItem(service)
	menu:AddItem(civil)
	menu:AddItem(separator2)
    menu:AddItem(bullet)
	-- menu:AddItem(gilet)
	menu:AddItem(tenu)

    menu.OnItemSelect = function(sender, item, index)
			if item == civil then
				TriggerEvent('esx_policejob:offDuty')
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                    TriggerEvent('skinchanger:loadSkin', skin)
				end)
				SetPedArmour(playerPed, 0)
			end

			if item == service then
				TriggerEvent('esx_policejob:onDuty')
			end

			if item == bullet then
				TriggerEvent('skinchanger:getSkin', function(skin)
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.bullet_wear.male)
					elseif skin.sex == 1 then
						TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.bullet_wear.female)
					end
				end)
				SetPedArmour(playerPed, 100)
            end

			if item == gilet then 
				TriggerEvent('skinchanger:getSkin', function(skin)
					if skin.sex == 0 then
						TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.gilet_wear.male)
					elseif skin.sex == 1 then
						TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.gilet_wear.female)
					end
				end)
            end

			if item == tenu then
				if PlayerData.job.grade_name == 'recruit' then
					TriggerEvent('skinchanger:getSkin', function(skin)
						if skin.sex == 0 then
								TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.recruit_wear.male)
						elseif skin.sex == 1 then
								TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.recruit_wear.female)
						end
					end)
				elseif PlayerData.job.grade_name == 'officer' then 
					TriggerEvent('skinchanger:getSkin', function(skin)
						if skin.sex == 0 then
								TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.officer_wear.male)
						elseif skin.sex == 1 then
								TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.officer_wear.female)
						end
					end)
				elseif PlayerData.job.grade_name == 'sergeant' then
					TriggerEvent('skinchanger:getSkin', function(skin)
						if skin.sex == 0 then
								TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.sergeant_wear.male)
						elseif skin.sex == 1 then
								TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.sergeant_wear.female)
						end
				end)
				elseif PlayerData.job.grade_name == 'lieutenant' then
					TriggerEvent('skinchanger:getSkin', function(skin)
						if skin.sex == 0 then
								TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.lieutenant_wear.male)
						elseif skin.sex == 1 then
								TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.lieutenant_wear.female)
						end
					end)
				elseif PlayerData.job.grade_name == 'boss' then
					TriggerEvent('skinchanger:getSkin', function(skin)
						if skin.sex == 0 then
								TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.boss_wear.male)
						elseif skin.sex == 1 then
								TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms.boss_wear.female)
						end
					end)
				end
			end
		end
end

AddCloakMenu(cloakMenu)

function cleanPlayer(playerPed)
	SetPedArmour(playerPed, 0)
	ClearPedBloodDamage(playerPed)
	ResetPedVisibleDamage(playerPed)
	ClearPedLastWeaponDamage(playerPed)
	ResetPedMovementClipset(playerPed, 0)
end

function setUniform(job, playerPed)
	TriggerEvent('skinchanger:getSkin', function(skin)
		if skin.sex == 0 then
			if Config.Uniforms[job].male then
				TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].male)
			else
				ESX.ShowNotification(_U('no_outfit'))
			end

			if job == 'bullet_wear' then
				SetPedArmour(playerPed, 100)
			end
		else
			if Config.Uniforms[job].female then
				TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].female)
			else
				ESX.ShowNotification(_U('no_outfit'))
			end

			if job == 'bullet_wear' then
				SetPedArmour(playerPed, 100)
			end
		end
	end)
end

function AddArmMenu(menu)

	deposit = NativeUI.CreateItem("Déposer vos armes", "Appuyez sur ENTRER pour déposer toutes vos armes")
	kitBasique = NativeUI.CreateItem("Prendre un kit basique", "Appuyez sur ENTRER pour prendre un kit basique")
	kitIntervention = NativeUI.CreateItem("Prendre un kit d'intervention", "Appuyez sur ENTRER pour prendre un kit d'intervention")
	-- tazer = NativeUI.CreateItem("Tazer", "Prendre un tazer")
	-- pistol = NativeUI.CreateItem("Pistolet", "Prendre un pistolet")
	-- compistol = NativeUI.CreateItem("Pistolet de combat", "Prendre un pistolet de combat")
	-- smg = NativeUI.CreateItem("Smg d'assault", "Prendre une SMG d'assault")
	-- rifle = NativeUI.CreateItem("Fussil d'assault", "Prendre un fusil d'assault")
	-- sniper = NativeUI.CreateItem("Sniper", "Prendre un sniper")
	-- pompe = NativeUI.CreateItem("Pompe", "Prendre un pompe")

	kitBasique:RightLabel("→")
	kitIntervention:RightLabel("→")

	menu:AddItem(deposit)
	menu:AddItem(kitBasique)
	menu:AddItem(kitIntervention)
	-- menu:AddItem(tazer)
	-- menu:AddItem(pistol)
	-- menu:AddItem(compistol)
	-- menu:AddItem(smg)
	-- menu:AddItem(rifle)
	-- menu:AddItem(sniper)
	-- menu:AddItem(pompe)

	menu.OnItemSelect = function(sender, item, index)
		if item == deposit then
			RemoveAllPedWeapons(GetPlayerPed(-1), true)
			ESX.ShowAdvancedNotification("L.S.P.D", "Bob", "Merci, je m'occupe de les ranger", "CHAR_MP_ARMY_CONTACT", 8)
		end

		if item == kitBasique then
			ESX.ShowAdvancedNotification("Bob", "Voilà ton kit !", "N'oublie pas de me le rendre à la fin de ton service !", "CHAR_MP_ARMY_CONTACT", 8)
			TriggerServerEvent('esx_policejob:givebasickit')
		end

		if item == kitIntervention then
			ESX.ShowAdvancedNotification("Bob", "Voilà ton kit !", "N'oublie pas de me le rendre à la fin de ton service !", "CHAR_MP_ARMY_CONTACT", 8)
			TriggerServerEvent('esx_policejob:giveinterventionkit')
		end
		-- if item == tazer then
		-- 	TriggerServerEvent('esx_policejob:AddTazer') 
		-- end

		-- if item == pistol then
		-- 	TriggerServerEvent('esx_policejob:AddPistol') 
		-- end

		-- if item == compistol then 
		-- 	TriggerServerEvent('esx_policejob:AddComPistol')
		-- end

		-- if item == smg then 
		-- 	TriggerServerEvent('esx_policejob:AddSmg')
		-- end

		-- if item == rifle then 
		-- 	TriggerServerEvent('esx_policejob:AddRifle')
		-- end

		-- if item == sniper then 
		-- 	TriggerServerEvent('esx_policejob:AddSniperRifle')
		-- end

		-- if item == pompe then
		-- 	TriggerServerEvent('esx_policejob:AddPump')
		-- end
	end
end

AddArmMenu(armMenu)

function AddCarMenu(menu)

	local cadet = NativeUI.CreateItem("↓ À partir de cadet", "")
	cadet:RightLabel("↓")
	menu:AddItem(cadet)
	local scorcher = NativeUI.CreateItem("Vélo de patrouille", "Appuyez sur ENTRER pour sortir un 'scorcher'")
	scorcher:RightLabel("→")
	menu:AddItem(scorcher)
	local cruiser = NativeUI.CreateItem("Cruiser de police", "Appuyez sur ENTRER pour sortir un 'police'")
	cruiser:RightLabel("→")
	menu:AddItem(cruiser)
	local officier = NativeUI.CreateItem("↓ À partir d'officier", "")
	officier:RightLabel("↓")
	menu:AddItem(officier)
	local buffalo = NativeUI.CreateItem("Buffalo de police", "Appuyez sur ENTRER pour sortir un 'police2'")
	buffalo:RightLabel("→")
	menu:AddItem(buffalo)
	local interceptor = NativeUI.CreateItem("Interceptor de police", "Appuyez sur ENTRER pour sortir un 'police3'")
	interceptor:RightLabel("→")
	menu:AddItem(interceptor)
	local moto = NativeUI.CreateItem("Moto de police", "Appuyez sur ENTRER pour sortir un 'policeb'")
	moto:RightLabel("→")
	menu:AddItem(moto)
	local sergent = NativeUI.CreateItem("↓ À partir de sergent", "")
	sergent:RightLabel("↓")
	menu:AddItem(sergent)
	local riot = NativeUI.CreateItem("Blindé de police", "Appuyez sur ENTRER pour sortir un 'riot'")
	riot:RightLabel("→")
	menu:AddItem(riot)
	local fourgon = NativeUI.CreateItem("Fourgon de transport", "Appuyez sur ENTRER pour sortir un 'policet'")
	fourgon:RightLabel("→")
	menu:AddItem(fourgon)
	local unmarked = NativeUI.CreateItem("↓ Véhicules banalisés", "")
	unmarked:RightLabel("↓")
	menu:AddItem(unmarked)
	local cruiser2 = NativeUI.CreateItem("Cruiser banalisée", "Appuyez sur ENTRER pour sortir un 'police4'")
	cruiser2:RightLabel("→")
	menu:AddItem(cruiser2)
	local buffalo2 = NativeUI.CreateItem("Buffalo banalisée", "Appuyez sur ENTRER pour sortir un 'fbi'")
	buffalo2:RightLabel("→")
	menu:AddItem(buffalo2)
	local sultan = NativeUI.CreateItem("Véhicule de formation", "Appuyez sur ENTRER pour sortir un 'sultan'")
	sultan:RightLabel("→")
	menu:AddItem(sultan)




	menu.OnItemSelect = function(sender, item, index)
		if item == cruiser then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("police")
		elseif item == scorcher then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("scorcher")
		elseif item == buffalo then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("police2")
		elseif item == interceptor then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("police3")
		elseif item == moto then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("policeb")
		elseif item == riot then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("riot")
		elseif item == fourgon then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("policet")
		elseif item == cruiser2 then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("police4")
		elseif item == buffalo2 then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("fbi")
		elseif item == sultan then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("sultan")
		end
	end
end

AddCarMenu(carMenu)

function notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(true, true)
end

function spawnCar(car)
    local car = GetHashKey(car)

    RequestModel(car)
    while not HasModelLoaded(car) do
        RequestModel(car)
        Citizen.Wait(50)
    end

    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), false))
    local vehicle = CreateVehicle(car, 452.84, -1019.61, 28.24, 90.89, true, false)
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
    
    SetEntityAsNoLongerNeeded(vehicle)
	SetModelAsNoLongerNeeded(vehicleName)
	SetVehicleNumberPlateText(vehicle, "LSPD")
        
end

function StoreNearbyVehicle(playerCoords)
	local vehicles, vehiclePlates = ESX.Game.GetVehiclesInArea(playerCoords, 30.0), {}

	if #vehicles > 0 then
		for k,v in ipairs(vehicles) do

			-- Make sure the vehicle we're saving is empty, or else it wont be deleted
			if GetVehicleNumberOfPassengers(v) == 0 and IsVehicleSeatFree(v, -1) then
				table.insert(vehiclePlates, {
					vehicle = v,
					plate = ESX.Math.Trim(GetVehicleNumberPlateText(v))
				})
			end
		end
	else
		ESX.ShowNotification(_U('garage_store_nearby'))
		return
	end

	ESX.TriggerServerCallback('esx_policejob:storeNearbyVehicle', function(storeSuccess, foundNum)
		if storeSuccess then
			local vehicleId = vehiclePlates[foundNum]
			local attempts = 0
			ESX.Game.DeleteVehicle(vehicleId.vehicle)
			IsBusy = true

			Citizen.CreateThread(function()
				BeginTextCommandBusyString('STRING')
				AddTextComponentSubstringPlayerName(_U('garage_storing'))
				EndTextCommandBusyString(4)

				while IsBusy do
					Citizen.Wait(100)
				end

				RemoveLoadingPrompt()
			end)

			-- Workaround for vehicle not deleting when other players are near it.
			while DoesEntityExist(vehicleId.vehicle) do
				Citizen.Wait(500)
				attempts = attempts + 1

				-- Give up
				if attempts > 30 then
					break
				end

				vehicles = ESX.Game.GetVehiclesInArea(playerCoords, 30.0)
				if #vehicles > 0 then
					for k,v in ipairs(vehicles) do
						if ESX.Math.Trim(GetVehicleNumberPlateText(v)) == vehicleId.plate then
							ESX.Game.DeleteVehicle(v)
							break
						end
					end
				end
			end

			IsBusy = false
			ESX.ShowNotification(_U('garage_has_stored'))
		else
			ESX.ShowNotification(_U('garage_has_notstored'))
		end
	end, vehiclePlates)
end

function GetAvailableVehicleSpawnPoint(station, part, partNum)
	local spawnPoints = Config.PoliceStations[station][part][partNum].SpawnPoints
	local found, foundSpawnPoint = false, nil

	for i=1, #spawnPoints, 1 do
		if ESX.Game.IsSpawnPointClear(spawnPoints[i].coords, spawnPoints[i].radius) then
			found, foundSpawnPoint = true, spawnPoints[i]
			break
		end
	end

	if found then
		return true, foundSpawnPoint
	else
		ESX.ShowNotification(_U('vehicle_blocked'))
		return false
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if isInShopMenu then
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
		else
			Citizen.Wait(500)
		end
	end
end)

function DeleteSpawnedVehicles()
	while #spawnedVehicles > 0 do
		local vehicle = spawnedVehicles[1]
		ESX.Game.DeleteVehicle(vehicle)
		table.remove(spawnedVehicles, 1)
	end
end

function WaitForVehicleToLoad(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		BeginTextCommandBusyString('STRING')
		AddTextComponentSubstringPlayerName(_U('vehicleshop_awaiting_model'))
		EndTextCommandBusyString(4)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(0)
			DisableAllControlActions(0)
		end

		RemoveLoadingPrompt()
	end
end

function AddMobMenu(menu)
	citizen = _menuPool:AddSubMenu(menu, "Citoyens", "")
	citizen.Item:RightLabel("→")
	vehicle = _menuPool:AddSubMenu(menu, "Véhicules", "")
	vehicle.Item:RightLabel("→")
	object = _menuPool:AddSubMenu(menu, "Objets", "")
	object.Item:RightLabel("→")

	interaction = NativeUI.CreateItem("↓ Intéractions avec la personne", "")
	interaction:RightLabel("↓")
	search = NativeUI.CreateItem("Fouiller la personne", "Appuyez sur ENTRER pour fouiller la personne en face de vous")
	search:RightLabel("→")
	handcuff = NativeUI.CreateItem("Menotter la personne", "Appuyez sur ENTRER pour menotter la personne en face de vous")
	handcuff:RightLabel("→")
	drag = NativeUI.CreateItem("Prendre la personne par le bras", "Appuyez sur ENTRER pour prendre la personne en face de vous par le bras")
	drag:RightLabel("→")
	papier = NativeUI.CreateItem("↓ Vérifier les papiers", "")
	papier:RightLabel("↓")
	fine = NativeUI.CreateItem("Envoyer une amende", "Appuyez sur ENTRER pour amender la personne en face de vous")
	fine:RightLabel("→")
	unpaid_bills = NativeUI.CreateItem("Voir les factures impayés", "Appuyez sur ENTRER pour vérifier si la personne en face de vous a des factures impayées")
	unpaid_bills:RightLabel("→")
	license_check = NativeUI.CreateItem("Voir les licenses", "Appuyez sur ENTRER pour voir les licenses de la personne en face de vous")
	license_check:RightLabel("→")

	-- citizen.SubMenu:AddItem(card)
	citizen.SubMenu:AddItem(interaction)
	citizen.SubMenu:AddItem(search)
	citizen.SubMenu:AddItem(handcuff)
	citizen.SubMenu:AddItem(drag)
	citizen.SubMenu:AddItem(papier)
	citizen.SubMenu:AddItem(fine)
	citizen.SubMenu:AddItem(unpaid_bills)
	citizen.SubMenu:AddItem(license_check)

	citizen.SubMenu.OnItemSelect = function(sender, item, index)
		local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
		if closestPlayer ~= -1 and closestDistance <= 3.0 then
			if item == card then
				_menuPool:CloseAllMenus(true)
				OpenIdentityCardMenu(closestPlayer)
			end

			if item == search then
				_menuPool:CloseAllMenus(true)
				TriggerServerEvent('esx_policejob:message', GetPlayerServerId(closestPlayer), _U('being_searched'))
				OpenBodySearchMenu(closestPlayer)
			end

			if item == handcuff then
				_menuPool:CloseAllMenus(true)
				TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(closestPlayer))
			end

			if item == drag then
				_menuPool:CloseAllMenus(true)
				TriggerServerEvent('esx_policejob:drag', GetPlayerServerId(closestPlayer))
			end

			if item == put_in_vehicle then
				_menuPool:CloseAllMenus(true)
				TriggerServerEvent('esx_policejob:putInVehicle', GetPlayerServerId(closestPlayer))
			end

			if item == out_the_vehicle then
				_menuPool:CloseAllMenus(true)
				TriggerServerEvent('esx_policejob:OutVehicle', GetPlayerServerId(closestPlayer))
			end

			if item == fine then
				_menuPool:CloseAllMenus(true)
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
					title = "Montant de l'amande"
				}, function(data, menu)
	
					local amount = tonumber(data.value)
					if amount == nil then
						ESX.ShowNotification("Montant invalide")
					else
						menu.close()
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						if closestPlayer == -1 or closestDistance > 3.0 then
							ESX.ShowNotification("Aucune personne à proximité")
						else
							TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_police', 'Police', amount)
							ESX.ShowNotification("Amande envoyée")
						end
	
					end
				end) 
			end

			if item == unpaid_bills then
				_menuPool:CloseAllMenus(true)
				OpenUnpaidBillsMenu(closestPlayer)
			end

			if item == license_check then 
				_menuPool:CloseAllMenus(true)
				ShowPlayerLicense(closestPlayer)
			end
		else
			ESX.ShowNotification(_U('no_players_nearby'))
		end
	end
	-- Fin de citizen

	--Debut de vehicule
	local playerPed = PlayerPedId()
	--local vehicle = ESX.Game.GetVehicleInDirection()

	vehicle_info = NativeUI.CreateItem("Vérifier la plaque du véhicule", "Appuyez sur ENTRER pour vérifier la plaque du véhicule via la centrale")
	pick_lock = NativeUI.CreateItem("Crocheter le véhicule", "Appuyez sur ENTRER pour crocheter le véhicule")
	impound = NativeUI.CreateItem("Mettre le véhicule en fourrière", "SEULEMENT SI AUCUN MECANO DISPO")
	database = NativeUI.CreateItem("Rechercher une plaque via la centrale", "Appuyez sur ENTRER pour communiquer avec la centrale")
	vehicle.SubMenu:AddItem(vehicle_info)
	vehicle.SubMenu:AddItem(pick_lock)
	vehicle.SubMenu:AddItem(impound)
	vehicle.SubMenu:AddItem(database)


	vehicle.SubMenu.OnItemSelect = function(sender, item, index)
		local coords  = GetEntityCoords(playerPed)
		vehicle = ESX.Game.GetVehicleInDirection()

		if item == database then
			LookupVehicle()
		elseif DoesEntityExist(vehicle) then
		
			if item == vehicle_info then
				local vehicleData = ESX.Game.GetVehicleProperties(vehicle)
				OpenVehicleInfosMenu(vehicleData)
			end

			if item == pick_lock then
				if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 3.0) then
					TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
					Citizen.Wait(20000)
					ClearPedTasksImmediately(playerPed)

					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					ESX.ShowNotification(_U('vehicle_unlocked'))
				end
			end

			if item == impound then
				if currentTask.busy then
					return
				end

				ESX.ShowHelpNotification(_U('impound_prompt'))
				TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)

				currentTask.busy = true
				currentTask.task = ESX.SetTimeout(10000, function()
					ClearPedTasks(playerPed)
					ImpoundVehicle(vehicle)
					Citizen.Wait(100) -- sleep the entire script to let stuff sink back to reality
				end)

				-- keep track of that vehicle!
				Citizen.CreateThread(function()
					while currentTask.busy do
						Citizen.Wait(1000)

						vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 3.0, 0, 71)
						if not DoesEntityExist(vehicle) and currentTask.busy then
							ESX.ShowNotification(_U('impound_canceled_moved'))
							ESX.ClearTimeout(currentTask.task)
							ClearPedTasks(playerPed)
							currentTask.busy = false
							break
						end
					end
				end)
			end
		else
			ESX.ShowNotification(_U('no_vehicles_nearby'))
		end
	end
	-- Fin de vehicle

	cone = NativeUI.CreateItem("Placer un cône de circulation", "Appuyer sur ENTRER pour placer un cone")
	barrier = NativeUI.CreateItem("Placer une barrière de securité", "Appuyer sur ENTRER pour placer une barrière")
	herse = NativeUI.CreateItem("Placer une herse", "Appuyer sur ENTRER pour placer une herse")

	object.SubMenu:AddItem(cone)
	object.SubMenu:AddItem(barrier)
	object.SubMenu:AddItem(herse)

	object.SubMenu.OnItemSelect = function(sender, item, index)
		local playerPed = PlayerPedId()
		local coords    = GetEntityCoords(playerPed)
		local forward   = GetEntityForwardVector(playerPed)
		local x, y, z   = table.unpack(coords + forward * 1.0)

		if item == cone then
			ESX.Game.SpawnObject('prop_roadcone02a', {x = x, y = y, z = z - 2.0}, function(obj)
				SetEntityHeading(obj, GetEntityHeading(playerPed))
				PlaceObjectOnGroundProperly(obj)
			end)
		end

		if item == barrier then 
			ESX.Game.SpawnObject('prop_barrier_work05', {x = x, y = y, z = z}, function(obj)
				SetEntityHeading(obj, GetEntityHeading(playerPed))
				PlaceObjectOnGroundProperly(obj)
			end)
		end

		if item == herse then
			ESX.Game.SpawnObject('p_ld_stinger_s', {x = x, y = y, z = z}, function(obj)
				SetEntityHeading(obj, GetEntityHeading(playerPed))
				PlaceObjectOnGroundProperly(obj)
			end)
		end

		if item == box then
			ESX.Game.SpawnObject('prop_boxpile_07d', {x = x, y = y, z = z}, function(obj)
				SetEntityHeading(obj, GetEntityHeading(playerPed))
				PlaceObjectOnGroundProperly(obj)
			end)
		end

		if item == cash then
			ESX.Game.SpawnObject('hei_prop_cash_crate_half_full', {x = x, y = y, z = z}, function(obj)
				SetEntityHeading(obj, GetEntityHeading(playerPed))
				PlaceObjectOnGroundProperly(obj)
			end)
		end
	end
end

AddMobMenu(mobMenu)

function OpenBodySearchMenu(player)
	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)
		local elements = {}

		for i=1, #data.accounts, 1 do
			if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
				table.insert(elements, {
					label    = _U('confiscate_dirty', ESX.Math.Round(data.accounts[i].money)),
					value    = 'black_money',
					itemType = 'item_account',
					amount   = data.accounts[i].money
				})

				break
			end
		end

		table.insert(elements, {label = _U('guns_label')})

		for i=1, #data.weapons, 1 do
			table.insert(elements, {
				label    = _U('confiscate_weapon', ESX.GetWeaponLabel(data.weapons[i].name), data.weapons[i].ammo),
				value    = data.weapons[i].name,
				itemType = 'item_weapon',
				amount   = data.weapons[i].ammo
			})
		end

		table.insert(elements, {label = _U('inventory_label')})

		for i=1, #data.inventory, 1 do
			if data.inventory[i].count > 0 then
				table.insert(elements, {
					label    = _U('confiscate_inv', data.inventory[i].count, data.inventory[i].label),
					value    = data.inventory[i].name,
					itemType = 'item_standard',
					amount   = data.inventory[i].count
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'body_search', {
			title    = _U('search'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			if data.current.value then
				TriggerServerEvent('esx_policejob:confiscatePlayerItem', GetPlayerServerId(player), data.current.itemType, data.current.value, data.current.amount)
				OpenBodySearchMenu(player)
			end
		end, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

function OpenFineMenu(player)
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine', {
		title    = _U('fine'),
		align    = 'top-left',
		elements = {
			{label = _U('traffic_offense'), value = 0},
			{label = _U('minor_offense'),   value = 1},
			{label = _U('average_offense'), value = 2},
			{label = _U('major_offense'),   value = 3}
	}}, function(data, menu)
		OpenFineCategoryMenu(player, data.current.value)
	end, function(data, menu)
		menu.close()
	end)
end

function OpenFineCategoryMenu(player, category)
	ESX.TriggerServerCallback('esx_policejob:getFineList', function(fines)
		local elements = {}

		for k,fine in ipairs(fines) do
			table.insert(elements, {
				label     = ('%s <span style="color:green;">%s</span>'):format(fine.label, _U('armory_item', ESX.Math.GroupDigits(fine.amount))),
				value     = fine.id,
				amount    = fine.amount,
				fineLabel = fine.label
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fine_category', {
			title    = _U('fine'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			menu.close()

			if Config.EnablePlayerManagement then
				TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), 'society_police', _U('fine_total', data.current.fineLabel), data.current.amount)
			else
				TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(player), '', _U('fine_total', data.current.fineLabel), data.current.amount)
			end

			ESX.SetTimeout(300, function()
				OpenFineCategoryMenu(player, category)
			end)
		end, function(data, menu)
			menu.close()
		end)
	end, category)
end

function LookupVehicle()
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'lookup_vehicle',
	{
		title = _U('search_database_title'),
	}, function(data, menu)
		local length = string.len(data.value)
		if data.value == nil or length < 2 or length > 13 then
			ESX.ShowNotification(_U('search_database_error_invalid'))
		else
			ESX.TriggerServerCallback('esx_policejob:getVehicleFromPlate', function(owner, found)
				if found then
					ESX.ShowNotification(_U('search_database_found', owner))
				else
					ESX.ShowNotification(_U('search_database_error_not_found'))
				end
			end, data.value)
			menu.close()
		end
	end, function(data, menu)
		menu.close()
	end)
end

function ShowPlayerLicense(player)
	local elements, targetName = {}

	ESX.TriggerServerCallback('esx_policejob:getOtherPlayerData', function(data)
		if data.licenses then
			for i=1, #data.licenses, 1 do
				if data.licenses[i].label and data.licenses[i].type then
					table.insert(elements, {
						label = data.licenses[i].label,
						type = data.licenses[i].type
					})
				end
			end
		end

		if Config.EnableESXIdentity then
			targetName = data.firstname .. ' ' .. data.lastname
		else
			targetName = data.name
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_license', {
			title    = _U('license_revoke'),
			align    = 'top-left',
			elements = elements,
		}, function(data, menu)
			ESX.ShowNotification(_U('licence_you_revoked', data.current.label, targetName))
			TriggerServerEvent('esx_policejob:message', GetPlayerServerId(player), _U('license_revoked', data.current.label))

			TriggerServerEvent('esx_license:removeLicense', GetPlayerServerId(player), data.current.type)

			ESX.SetTimeout(300, function()
				ShowPlayerLicense(player)
			end)
		end, function(data, menu)
			menu.close()
		end)

	end, GetPlayerServerId(player))
end

function OpenUnpaidBillsMenu(player)
	local elements = {}

	ESX.TriggerServerCallback('esx_billing:getTargetBills', function(bills)
		for k,bill in ipairs(bills) do
			table.insert(elements, {
				label = ('%s - <span style="color:red;">%s</span>'):format(bill.label, _U('armory_item', ESX.Math.GroupDigits(bill.amount))),
				billId = bill.id
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'billing', {
			title    = _U('unpaid_bills'),
			align    = 'top-left',
			elements = elements
		}, nil, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

function OpenVehicleInfosMenu(vehicleData)
	ESX.TriggerServerCallback('esx_policejob:getVehicleInfos', function(retrivedInfo)

		if retrivedInfo.owner == nil then
			ESX.ShowNotification("Propriétaire: inconnu")
		else
			ESX.ShowNotification("Propriétaire: ", retrivedInfo.owner)
			ESX.ShowNotification("Plaque: ", retrivedInfo.plate)
		end
	end)
end

function OpenGetStocksMenu()
	ESX.TriggerServerCallback('esx_policejob:getStockItems', function(items)
		local elements = {}

		for i=1, #items, 1 do
			table.insert(elements, {
				label = 'x' .. items[i].count .. ' ' .. items[i].label,
				value = items[i].name
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = _U('police_stock'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_policejob:getStockItem', itemName, count)

					Citizen.Wait(300)
					OpenGetStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenPutStocksMenu()
	ESX.TriggerServerCallback('esx_policejob:getPlayerInventory', function(inventory)
		local elements = {}

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = _U('inventory'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			local itemName = data.current.value

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
				title = _U('quantity')
			}, function(data2, menu2)
				local count = tonumber(data2.value)

				if count == nil then
					ESX.ShowNotification(_U('quantity_invalid'))
				else
					menu2.close()
					menu.close()
					TriggerServerEvent('esx_policejob:putStockItems', itemName, count)

					Citizen.Wait(300)
					OpenPutStocksMenu()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
	end)
end

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job

	Citizen.Wait(5000)
	TriggerServerEvent('esx_policejob:forceBlip')
end)

RegisterNetEvent('esx_phone:loaded')
AddEventHandler('esx_phone:loaded', function(phoneNumber, contacts)
	local specialContact = {
		name       = _U('phone_police'),
		number     = 'police',
		base64Icon = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAyJpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMy1jMDExIDY2LjE0NTY2MSwgMjAxMi8wMi8wNi0xNDo1NjoyNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvIiB4bWxuczp4bXBNTT0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL21tLyIgeG1sbnM6c3RSZWY9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZVJlZiMiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIENTNiAoV2luZG93cykiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6NDFGQTJDRkI0QUJCMTFFN0JBNkQ5OENBMUI4QUEzM0YiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6NDFGQTJDRkM0QUJCMTFFN0JBNkQ5OENBMUI4QUEzM0YiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDo0MUZBMkNGOTRBQkIxMUU3QkE2RDk4Q0ExQjhBQTMzRiIgc3RSZWY6ZG9jdW1lbnRJRD0ieG1wLmRpZDo0MUZBMkNGQTRBQkIxMUU3QkE2RDk4Q0ExQjhBQTMzRiIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PoW66EYAAAjGSURBVHjapJcLcFTV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'
	}

	TriggerEvent('esx_phone:addSpecialContact', specialContact.name, specialContact.number, specialContact.base64Icon)
end)

-- don't show dispatches if the player isn't in service
AddEventHandler('esx_phone:cancelMessage', function(dispatchNumber)
	if PlayerData.job and PlayerData.job.name == 'police' and PlayerData.job.name == dispatchNumber then
		-- if esx_service is enabled
		if Config.MaxInService ~= -1 and not onDuty then
			CancelEvent()
		end
	end
end)

function AddMenuBossMenu(menu)

	local coffreItem = nil

	if societymoney ~= nil then
		coffreItem = NativeUI.CreateItem(_U('bossmanagement_chest_button'), "")
		coffreItem:RightLabel("$" .. societymoney)
		menu:AddItem(coffreItem)
	end

	local ppa = NativeUI.CreateItem("Permis de port d'arme", "")
	menu:AddItem(ppa)
	ppa:RightLabel("→")


    local beta = NativeUI.CreateItem("Gestion Entreprise", "")
	menu:AddItem(beta)
	beta:RightLabel("→→")

    menu.OnItemSelect = function(sender, item, index)
        if item == beta then
            _menuPool:CloseAllMenus(true)
            TriggerEvent('esx_society:openBossMenu', 'police', function(data, menu)
				menu.close()
            end)
		end

		if item == ppa then 
			TriggerServerEvent('buyPPA')
		end

	end
end

AddMenuBossMenu(bossMenu)

AddEventHandler('esx_policejob:hasEnteredMarker', function(station, part, partNum)
	--if part == 'Cloakroom' then
		--CurrentAction     = 'menu_cloakroom'
		--CurrentActionMsg  = _U('open_cloackroom')
		--CurrentActionData = {}
	-- if part == 'Armory' then
	-- 	CurrentAction     = 'menu_armory'
	-- 	CurrentActionMsg  = _U('open_armory')
	-- 	CurrentActionData = {station = station}
	if part == 'Vehicles' then
		CurrentAction     = 'menu_vehicle_spawner'
		CurrentActionMsg  = _U('garage_prompt')
		CurrentActionData = {station = station, part = part, partNum = partNum}
	elseif part == 'Helicopters' then
		CurrentAction     = 'Helicopters'
		CurrentActionMsg  = _U('helicopter_prompt')
		CurrentActionData = {station = station, part = part, partNum = partNum}
	elseif part == 'BossActions' then
		CurrentAction     = 'menu_boss_actions'
		CurrentActionMsg  = _U('open_bossmenu')
		CurrentActionData = {}
	end
end)

AddEventHandler('esx_policejob:hasExitedMarker', function(station, part, partNum)
	if not isInShopMenu then
		ESX.UI.Menu.CloseAll()
	end

	CurrentAction = nil
end)

AddEventHandler('esx_policejob:hasEnteredEntityZone', function(entity)
	local playerPed = PlayerPedId()

	if PlayerData.job and PlayerData.job.name == 'police' and IsPedOnFoot(playerPed) then
		CurrentAction     = 'remove_entity'
		CurrentActionMsg  = _U('remove_prop')
		CurrentActionData = {entity = entity}
	end

	if GetEntityModel(entity) == GetHashKey('p_ld_stinger_s') then
		local playerPed = PlayerPedId()
		local coords    = GetEntityCoords(playerPed)

		if IsPedInAnyVehicle(playerPed, false) then
			local vehicle = GetVehiclePedIsIn(playerPed)

			for i=0, 7, 1 do
				SetVehicleTyreBurst(vehicle, i, true, 1000)
			end
		end
	end
end)

AddEventHandler('esx_policejob:hasExitedEntityZone', function(entity)
	if CurrentAction == 'remove_entity' then
		CurrentAction = nil
	end
end)

RegisterNetEvent('esx_policejob:handcuff')
AddEventHandler('esx_policejob:handcuff', function()
	isHandcuffed = not isHandcuffed
	local playerPed = PlayerPedId()

	Citizen.CreateThread(function()
		if isHandcuffed then

			RequestAnimDict('mp_arresting')
			while not HasAnimDictLoaded('mp_arresting') do
				Citizen.Wait(100)
			end

			TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0, 0, 0, 0)

			SetEnableHandcuffs(playerPed, true)
			DisablePlayerFiring(playerPed, true)
			SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
			SetPedCanPlayGestureAnims(playerPed, false)
			FreezeEntityPosition(playerPed, true)
			DisplayRadar(false)

			if Config.EnableHandcuffTimer then
				if handcuffTimer.active then
					ESX.ClearTimeout(handcuffTimer.task)
				end

				StartHandcuffTimer()
			end
		else
			if Config.EnableHandcuffTimer and handcuffTimer.active then
				ESX.ClearTimeout(handcuffTimer.task)
			end

			ClearPedSecondaryTask(playerPed)
			SetEnableHandcuffs(playerPed, false)
			DisablePlayerFiring(playerPed, false)
			SetPedCanPlayGestureAnims(playerPed, true)
			FreezeEntityPosition(playerPed, false)
			DisplayRadar(true)
		end
	end)
end)

RegisterNetEvent('esx_policejob:unrestrain')
AddEventHandler('esx_policejob:unrestrain', function()
	if isHandcuffed then
		local playerPed = PlayerPedId()
		isHandcuffed = false

		ClearPedSecondaryTask(playerPed)
		SetEnableHandcuffs(playerPed, false)
		DisablePlayerFiring(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		FreezeEntityPosition(playerPed, false)
		DisplayRadar(true)

		-- end timer
		if Config.EnableHandcuffTimer and handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end
	end
end)

RegisterNetEvent('esx_policejob:drag')
AddEventHandler('esx_policejob:drag', function(copId)
	if not isHandcuffed then
		return
	end

	dragStatus.isDragged = not dragStatus.isDragged
	dragStatus.CopId = copId
end)

Citizen.CreateThread(function()
	local playerPed
	local targetPed

	while true do
		Citizen.Wait(1)

		if isHandcuffed then
			playerPed = PlayerPedId()

			if dragStatus.isDragged then
				targetPed = GetPlayerPed(GetPlayerFromServerId(dragStatus.CopId))

				-- undrag if target is in an vehicle
				if not IsPedSittingInAnyVehicle(targetPed) then
					AttachEntityToEntity(playerPed, targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
				else
					dragStatus.isDragged = false
					DetachEntity(playerPed, true, false)
				end

				if IsPedDeadOrDying(targetPed, true) then
					dragStatus.isDragged = false
					DetachEntity(playerPed, true, false)
				end

			else
				DetachEntity(playerPed, true, false)
			end
		else
			Citizen.Wait(500)
		end
	end
end)

RegisterNetEvent('esx_policejob:putInVehicle')
AddEventHandler('esx_policejob:putInVehicle', function()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	if not isHandcuffed then
		return
	end

	if IsAnyVehicleNearPoint(coords, 5.0) then
		local vehicle = GetClosestVehicle(coords, 5.0, 0, 71)

		if DoesEntityExist(vehicle) then
			local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)

			for i=maxSeats - 1, 0, -1 do
				if IsVehicleSeatFree(vehicle, i) then
					freeSeat = i
					break
				end
			end

			if freeSeat then
				TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
				dragStatus.isDragged = false
			end
		end
	end
end)

RegisterNetEvent('esx_policejob:OutVehicle')
AddEventHandler('esx_policejob:OutVehicle', function()
	local playerPed = PlayerPedId()

	if not IsPedSittingInAnyVehicle(playerPed) then
		return
	end

	local vehicle = GetVehiclePedIsIn(playerPed, false)
	TaskLeaveVehicle(playerPed, vehicle, 16)
end)

-- Handcuff
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()

		if isHandcuffed then
			DisableControlAction(0, 1, true) -- Disable pan
			DisableControlAction(0, 2, true) -- Disable tilt
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			DisableControlAction(0, 32, true) -- W
			DisableControlAction(0, 34, true) -- A
			DisableControlAction(0, 31, true) -- S
			DisableControlAction(0, 30, true) -- D

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?

			DisableControlAction(0, 288,  true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job

			DisableControlAction(0, 0, true) -- Disable changing view
			DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			DisableControlAction(2, 199, true) -- Disable pause screen

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle

			if IsEntityPlayingAnim(playerPed, 'mp_arresting', 'idle', 3) ~= 1 then
				ESX.Streaming.RequestAnimDict('mp_arresting', function()
					TaskPlayAnim(playerPed, 'mp_arresting', 'idle', 8.0, -8, -1, 49, 0.0, false, false, false)
				end)
			end
		else
			Citizen.Wait(500)
		end
	end
end)

-- Create blips
Citizen.CreateThread(function()

	for k,v in pairs(Config.PoliceStations) do
		local blip = AddBlipForCoord(v.Blip.Coords)

		SetBlipSprite (blip, v.Blip.Sprite)
		SetBlipDisplay(blip, v.Blip.Display)
		SetBlipScale  (blip, v.Blip.Scale)
		SetBlipColour (blip, v.Blip.Colour)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString(_U('map_blip'))
		EndTextCommandSetBlipName(blip)
	end

end)

-- -- Display markers
-- Citizen.CreateThread(function()
-- 	while true do
-- 		Citizen.Wait(0)

-- 		if PlayerData.job and PlayerData.job.name == 'police' then

-- 			local playerPed = PlayerPedId()
-- 			local coords    = GetEntityCoords(playerPed)
-- 			local isInMarker, hasExited, letSleep = false, false, true
-- 			local currentStation, currentPart, currentPartNum

-- 			for k,v in pairs(Config.PoliceStations) do

-- 				for i=1, #v.Cloakrooms, 1 do
-- 					local distance = GetDistanceBetweenCoords(coords, v.Cloakrooms[i], true)

-- 					if distance < Config.DrawDistance then
-- 						DrawMarker(20, v.Cloakrooms[i], 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
-- 						letSleep = false
-- 					end

-- 					if distance < Config.MarkerSize.x then
-- 						isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Cloakroom', i
-- 					end
-- 				end

-- 				for i=1, #v.Armories, 1 do
-- 					local distance = GetDistanceBetweenCoords(coords, v.Armories[i], true)

-- 					if distance < Config.DrawDistance then
-- 						DrawMarker(21, v.Armories[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
-- 						letSleep = false
-- 					end

-- 					if distance < Config.MarkerSize.x then
-- 						isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Armory', i
-- 					end
-- 				end

-- 				for i=1, #v.Vehicles, 1 do
-- 					local distance = GetDistanceBetweenCoords(coords, v.Vehicles[i].Spawner, true)

-- 					if distance < Config.DrawDistance then
-- 						DrawMarker(36, v.Vehicles[i].Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
-- 						letSleep = false
-- 					end

-- 					if distance < Config.MarkerSize.x then
-- 						isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Vehicles', i
-- 					end
-- 				end

-- 				for i=1, #v.Helicopters, 1 do
-- 					local distance =  GetDistanceBetweenCoords(coords, v.Helicopters[i].Spawner, true)

-- 					if distance < Config.DrawDistance then
-- 						DrawMarker(34, v.Helicopters[i].Spawner, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
-- 						letSleep = false
-- 					end

-- 					if distance < Config.MarkerSize.x then
-- 						isInMarker, currentStation, currentPart, currentPartNum = true, k, 'Helicopters', i
-- 					end
-- 				end

-- 				if Config.EnablePlayerManagement and PlayerData.job.grade_name == 'boss' then
-- 					for i=1, #v.BossActions, 1 do
-- 						local distance = GetDistanceBetweenCoords(coords, v.BossActions[i], true)

-- 						if distance < Config.DrawDistance then
-- 							DrawMarker(22, v.BossActions[i], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, true, false, false, false)
-- 							letSleep = false
-- 						end

-- 						if distance < Config.MarkerSize.x then
-- 							isInMarker, currentStation, currentPart, currentPartNum = true, k, 'BossActions', i
-- 						end
-- 					end
-- 				end
-- 			end

-- 			if isInMarker and not HasAlreadyEnteredMarker or (isInMarker and (LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)) then
-- 				if
-- 					(LastStation and LastPart and LastPartNum) and
-- 					(LastStation ~= currentStation or LastPart ~= currentPart or LastPartNum ~= currentPartNum)
-- 				then
-- 					TriggerEvent('esx_policejob:hasExitedMarker', LastStation, LastPart, LastPartNum)
-- 					hasExited = true
-- 				end

-- 				HasAlreadyEnteredMarker = true
-- 				LastStation             = currentStation
-- 				LastPart                = currentPart
-- 				LastPartNum             = currentPartNum

-- 				TriggerEvent('esx_policejob:hasEnteredMarker', currentStation, currentPart, currentPartNum)
-- 			end

-- 			if not hasExited and not isInMarker and HasAlreadyEnteredMarker then
-- 				HasAlreadyEnteredMarker = false
-- 				TriggerEvent('esx_policejob:hasExitedMarker', LastStation, LastPart, LastPartNum)
-- 			end

-- 			if letSleep then
-- 				Citizen.Wait(500)
-- 			end

-- 		else
-- 			Citizen.Wait(500)
-- 		end
-- 	end
-- end)

-- Enter / Exit entity zone events
Citizen.CreateThread(function()
	local trackedEntities = {
		'prop_roadcone02a',
		'prop_barrier_work05',
		'p_ld_stinger_s',
		'prop_boxpile_07d',
		'hei_prop_cash_crate_half_full'
	}

	while true do
		Citizen.Wait(500)

		local playerPed = PlayerPedId()
		local coords    = GetEntityCoords(playerPed)

		local closestDistance = -1
		local closestEntity   = nil

		for i=1, #trackedEntities, 1 do
			local object = GetClosestObjectOfType(coords, 3.0, GetHashKey(trackedEntities[i]), false, false, false)

			if DoesEntityExist(object) then
				local objCoords = GetEntityCoords(object)
				local distance  = GetDistanceBetweenCoords(coords, objCoords, true)

				if closestDistance == -1 or closestDistance > distance then
					closestDistance = distance
					closestEntity   = object
				end
			end
		end

		if closestDistance ~= -1 and closestDistance <= 3.0 then
			if LastEntity ~= closestEntity then
				TriggerEvent('esx_policejob:hasEnteredEntityZone', closestEntity)
				LastEntity = closestEntity
			end
		else
			if LastEntity then
				TriggerEvent('esx_policejob:hasExitedEntityZone', LastEntity)
				LastEntity = nil
			end
		end
	end
end)

-- Create blip for colleagues
function createBlip(id)
	local ped = GetPlayerPed(id)
	local blip = GetBlipFromEntity(ped)

	if not DoesBlipExist(blip) then -- Add blip and create head display on player
		blip = AddBlipForEntity(ped)
		SetBlipSprite(blip, 1)
		ShowHeadingIndicatorOnBlip(blip, true) -- Player Blip indicator
		SetBlipRotation(blip, math.ceil(GetEntityHeading(ped))) -- update rotation
		SetBlipNameToPlayerName(blip, id) -- update blip name
		SetBlipScale(blip, 0.85) -- set scale
		SetBlipAsShortRange(blip, true)

		table.insert(blipsCops, blip) -- add blip to array so we can remove it later
	end
end

RegisterNetEvent('esx_policejob:updateBlip')
AddEventHandler('esx_policejob:updateBlip', function()

	-- Refresh all blips
	for k, existingBlip in pairs(blipsCops) do
		RemoveBlip(existingBlip)
	end

	-- Clean the blip table
	blipsCops = {}

	-- Enable blip?
	if Config.MaxInService ~= -1 and not onDuty then
		return
	end

	if not Config.EnableJobBlip then
		return
	end

	-- Is the player a cop? In that case show all the blips for other cops
	if PlayerData.job and PlayerData.job.name == 'police' then
		ESX.TriggerServerCallback('esx_society:getOnlinePlayers', function(players)
			for i=1, #players, 1 do
				if players[i].job.name == 'police' then
					local id = GetPlayerFromServerId(players[i].source)
					if NetworkIsPlayerActive(id) and GetPlayerPed(id) ~= PlayerPedId() then
						createBlip(id)
					end
				end
			end
		end)
	end

end)

AddEventHandler('playerSpawned', function(spawn)
	isDead = false
	TriggerEvent('esx_policejob:unrestrain')

	if not hasAlreadyJoined then
		TriggerServerEvent('esx_policejob:spawned')
	end
	hasAlreadyJoined = true
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('esx_policejob:unrestrain')
		TriggerEvent('esx_phone:removeSpecialContact', 'police')

		if Config.MaxInService ~= -1 then
			TriggerServerEvent('esx_service:disableService', 'police')
		end

		if Config.EnableHandcuffTimer and handcuffTimer.active then
			ESX.ClearTimeout(handcuffTimer.task)
		end
	end
end)

-- handcuff timer, unrestrain the player after an certain amount of time
function StartHandcuffTimer()
	if Config.EnableHandcuffTimer and handcuffTimer.active then
		ESX.ClearTimeout(handcuffTimer.task)
	end

	handcuffTimer.active = true

	handcuffTimer.task = ESX.SetTimeout(Config.HandcuffTimer, function()
		ESX.ShowNotification(_U('unrestrained_timer'))
		TriggerEvent('esx_policejob:unrestrain')
		handcuffTimer.active = false
	end)
end

-- TODO
--   - return to garage if owned
--   - message owner that his vehicle has been impounded
function ImpoundVehicle(vehicle)
	--local vehicleName = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
	ESX.Game.DeleteVehicle(vehicle)
	ESX.ShowNotification(_U('impound_successful'))
	currentTask.busy = false
end

_menuPool:RefreshIndex()

local arm = {
    {x = 451.7, y = -980.1, z = 30.6},
}

local cloak = {
    {x = 452.6, y = -992.8, z = 30.6},
}

local garage = {
    {x = 458.8, y = -1007.9, z = 28.7}
}

local boss = {
    {x = 448.4, y = -973.2, z = 30.6}
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
		_menuPool:ProcessMenus()
		
		if IsControlJustPressed(1,167) and PlayerData.job and PlayerData.job.name == 'police' then
			if onDuty then
				mobMenu:Visible(not mobMenu:Visible())
			else
				local mugshot, mugshotStr = ESX.Game.GetPedMugshot(PlayerPedId())
				ESX.ShowAdvancedNotification("L.S.P.D", "Action impossible", "Tu dois prendre ton service pour faire cela", mugshotStr, 8)
				UnregisterPedheadshot(mugshot)
			end
		end

        for k in pairs(arm) do

            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, arm[k].x, arm[k].y, arm[k].z)

            if dist <= 1.2 and onDuty and PlayerData.job and  PlayerData.job.name == 'police' then
                ESX.ShowHelpNotification("Appuyez sur ~INPUT_PICKUP~ pour ouvrir ~b~l'armurie~s~")
				if IsControlJustPressed(1,38) then 
					armMenu:Visible(not armMenu:Visible())
				end
            end
		end
		for k in pairs(cloak) do

            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, cloak[k].x, cloak[k].y, cloak[k].z)

            if dist <= 1.2 and PlayerData.job and PlayerData.job.name == 'police' then
                ESX.ShowHelpNotification("Appuyez sur ~INPUT_PICKUP~ pour ouvrir le ~b~vestiaire~s~")
				if IsControlJustPressed(1,38) then 
					cloakMenu:Visible(not cloakMenu:Visible())
				end
            end
		end
		for k in pairs(garage) do

            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, garage[k].x, garage[k].y, garage[k].z)

            if dist <= 1.2 and onDuty and PlayerData.job and PlayerData.job.name == 'police' then
                ESX.ShowHelpNotification("Appuyez sur ~INPUT_PICKUP~ pour accéder au ~b~garage~s~")
				if IsControlJustPressed(1,38) then 
					carMenu:Visible(not carMenu:Visible())
				end
            end
		end
		for k in pairs(boss) do

            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, boss[k].x, boss[k].y, boss[k].z)

            if dist <= 1.2 and onDuty and PlayerData.job and PlayerData.job.name == 'police' and PlayerData.job.grade_name == 'boss' then
                ESX.ShowHelpNotification("Appuyez sur ~INPUT_PICKUP~ pour accéder à l'ordinateur de ~b~l'entreprise~s~")
				if IsControlJustPressed(1,38) then 
					bossMenu:Visible(not bossMenu:Visible())
				end
            end
        end
    end
end)

local del = {
    {x = 462.4, y = -1014.7, z = 27.4}
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

		for k in pairs(del) do
			
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, del[k].x, del[k].y, del[k].z)

            if dist <= 1.2 and onDuty and PlayerData.job and PlayerData.job.name == 'police' and IsPedInAnyVehicle(PlayerPedId(-1), false) then
                ESX.ShowHelpNotification("Appuyez sur ~INPUT_PICKUP~ pour rentrer le ~b~vehicule~s~ dans le ~b~garage~s~")
				if IsControlJustPressed(1,38) then 			
					TriggerEvent('esx:deleteVehicle')
				end
            end
		end
	end
end)

-- _menuPool:MouseEdgeEnabled (false);
_menuPool:MouseControlsEnabled (false)
_menuPool:ControlDisablingEnabled (false)
