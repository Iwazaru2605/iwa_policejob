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

	local deposit = NativeUI.CreateItem("Déposer vos armes", "Appuyez sur ENTRER pour déposer toutes vos armes")
	menu:AddItem(deposit)

	local kitBasique = NativeUI.CreateItem("Prendre un kit basique", "Appuyez sur ENTRER pour prendre un kit basique")
	kitBasique:RightLabel("→")
	menu:AddItem(kitBasique)

	local kitIntervention = NativeUI.CreateItem("Prendre un kit d'intervention", "Appuyez sur ENTRER pour prendre un kit d'intervention")
	kitIntervention:RightLabel("→")
	menu:AddItem(kitIntervention)

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
	end
end

AddArmMenu(armMenu)

function AddCadetMenu(menu)
	cadetmenu = _menuPool:AddSubMenu(menu, "À partir de cadet")
	cadetmenu.Item:RightLabel("→")

	local scorcher = NativeUI.CreateItem("Vélo de patrouille", "Appuyez sur ENTRER pour sortir un 'scorcher'")
	scorcher:RightLabel("→")
	cadetmenu.SubMenu:AddItem(scorcher)
	_menuPool:CloseAllMenus()
	local cruiser = NativeUI.CreateItem("Cruiser de police", "Appuyez sur ENTRER pour sortir un 'police'")
	cruiser:RightLabel("→")
	cadetmenu.SubMenu:AddItem(cruiser)
	_menuPool:CloseAllMenus()

	cadetmenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == cruiser then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("police")
		elseif item == scorcher then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("scorcher")
		end
	end
end

function AddOfficierMenu(menu)
	officiermenu = _menuPool:AddSubMenu(menu, "À partir d'officier")
	officiermenu.Item:RightLabel("→")

	local buffalo = NativeUI.CreateItem("Buffalo de police", "Appuyez sur ENTRER pour sortir un 'police2'")
	buffalo:RightLabel("→")
	officiermenu.SubMenu:AddItem(buffalo)
	local interceptor = NativeUI.CreateItem("Interceptor de police", "Appuyez sur ENTRER pour sortir un 'police3'")
	interceptor:RightLabel("→")
	officiermenu.SubMenu:AddItem(interceptor)
	local moto = NativeUI.CreateItem("Moto de police", "Appuyez sur ENTRER pour sortir un 'policeb'")
	moto:RightLabel("→")
	officiermenu.SubMenu:AddItem(moto)

	officiermenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == buffalo then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("police2")
			_menuPool:CloseAllMenus()
		elseif item == interceptor then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("police3")
			_menuPool:CloseAllMenus()
		elseif item == moto then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("policeb")
			_menuPool:CloseAllMenus()
		end
	end
end

function AddTransportMenu(menu)
	transportmenu = _menuPool:AddSubMenu(menu, "Véhicules de transport", "Accessible à partir de sergent")
	transportmenu.Item:RightLabel("→")

	local riot = NativeUI.CreateItem("Blindé de police", "Appuyez sur ENTRER pour sortir un 'riot'")
	riot:RightLabel("→")
	transportmenu.SubMenu:AddItem(riot)
	local fourgon = NativeUI.CreateItem("Fourgon de transport", "Appuyez sur ENTRER pour sortir un 'policet'")
	fourgon:RightLabel("→")
	transportmenu.SubMenu:AddItem(fourgon)
	local pbus = NativeUI.CreateItem("Bus de transport pénitentier", "Appuyez sur ENTRER pour sortir un 'pbus'")
	pbus:RightLabel("→")
	transportmenu.SubMenu:AddItem(pbus)
	local riot2 = NativeUI.CreateItem("Fourgon anti-émeute", "Appuyez sur ENTRER pour sortir un 'riot2'")
	riot2:RightLabel("→")
	transportmenu.SubMenu:AddItem(riot2)

	transportmenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == riot then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("riot")
			_menuPool:CloseAllMenus()
		elseif item == fourgon then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("policet")
			_menuPool:CloseAllMenus()
		elseif item == pbus then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("pbus")
			_menuPool:CloseAllMenus()
		elseif item == riot2 then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("riot2")
			_menuPool:CloseAllMenus()
		end
	end
end

function AddUnmarkedMenu(menu)
	unmarkedmenu = _menuPool:AddSubMenu(menu, "Véhicules banalisé")
	unmarkedmenu.Item:RightLabel("→")

	local cruiser2 = NativeUI.CreateItem("Cruiser banalisée", "Appuyez sur ENTRER pour sortir un 'police4'")
	cruiser2:RightLabel("→")
	unmarkedmenu.SubMenu:AddItem(cruiser2)
	local buffalo2 = NativeUI.CreateItem("Buffalo banalisée", "Appuyez sur ENTRER pour sortir un 'fbi'")
	buffalo2:RightLabel("→")
	unmarkedmenu.SubMenu:AddItem(buffalo2)
	local granger2 = NativeUI.CreateItem("Granger banalisé", "Appuyez sur ENTRER pour sortir un 'fbi2'")
	granger2:RightLabel("→")
	unmarkedmenu.SubMenu:AddItem(granger2)
	local sultan = NativeUI.CreateItem("Véhicule de formation", "Appuyez sur ENTRER pour sortir un 'sultan'")
	sultan:RightLabel("→")
	unmarkedmenu.SubMenu:AddItem(sultan)

	unmarkedmenu.SubMenu.OnItemSelect = function(sender, item, index)
		if item == cruiser2 then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("police4")
			_menuPool:CloseAllMenus()
		elseif item == buffalo2 then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("fbi")
			_menuPool:CloseAllMenus()
		elseif item == granger2 then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("fbi2")
			_menuPool:CloseAllMenus()
		elseif item == sultan then
			ESX.ShowAdvancedNotification("Jack", "Voilà ton véhicule !", "N'oublie pas de le ranger à la fin de ton service !", "CHAR_JIMMY_BOSTON", 8)
			spawnCar("sultan")
			_menuPool:CloseAllMenus()
		end
	end
end

function AddCarMenu(menu)
	AddCadetMenu(carMenu)
	AddOfficierMenu(carMenu)
	AddTransportMenu(carMenu)
	AddUnmarkedMenu(carMenu)
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

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	PlayerData.job = job

	Citizen.Wait(5000)
	TriggerServerEvent('esx_policejob:forceBlip')
end)

function AddMenuBossMenu(menu)

	local coffreItem = nil

	if societymoney ~= nil then
		coffreItem = NativeUI.CreateItem("Compte de la société", "")
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
	{x = 461.73, y = -1014.40, z = 28.06},
	{x = 462.03, y = -1019.55, z = 28.09}
}

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

		for k in pairs(del) do
			
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, del[k].x, del[k].y, del[k].z)

            if dist <= 5.5 and onDuty and PlayerData.job and PlayerData.job.name == 'police' and IsPedInAnyVehicle(PlayerPedId(-1), false) then
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
