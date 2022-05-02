local mod=RegisterMod("Beth's Heart",1)
local bethsheart=Isaac.GetEntityVariantByName("Beth's Heart")
local json = require("json")
CollectibleType.COLLECTIBLE_BETHS_HEART=Isaac.GetItemIdByName("Beth's Heart")
local bethsheartdesc=Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_BETHS_HEART)
local BHDescEng = "{{Throwable}} Spawns a throwable familiar#Stores soul and black hearts to use as charges for the active item, maximum 6 charges#{{HalfSoulHeart}}: 1 charge#{{SoulHeart}}: 2 charges#{{BlackHeart}}: 3 charges#Press {{ButtonRT}} to supply the charges to the active item"
local BHDescSpa = "{{Throwable}} Genera un familiar lanzable#Almacena corazones de alma y corazones negros para usarlos como cargas para el objeto activo, máximo 6 cargas#{{HalfSoulHeart}}: 1 carga#{{SoulHeart}}: 2 cargas#{{BlackHeart}}: 3 cargas#Presiona el botón {{ButtonRT}} para suministrar las cargas al objeto activo"
local BHDescRu = "{{Throwable}} Создает спутника, которого можно бросать в выбранном направлении#Сохраняет синие и чёрные сердца как заряды для активируемых предметов, максимум 6 зарядов#{{HalfSoulHeart}}: 1 заряд#{{SoulHeart}}: 2 заряда#{{BlackHeart}}: 3 заряда#Для обеспечения зарядами активируемого предмета нужно нажать кнопку {{ButtonRT}}"
local BHDescPt_Br = "{{Throwable}} Gera um familiar arremessável#Armazenas corações de alma e negros para usar como carga para o seu item ativado, máximo de 6 cargas#{{HalfSoulHeart}}: 1 carga#{{SoulHeart}}: 2 cargas#{{BlackHeart}}: 3 cargas##Aperta {{ButtonRT}} para fornecer as cargas para o item ativado"
if EID then 
	EID:addCollectible(CollectibleType.COLLECTIBLE_BETHS_HEART, BHDescEng, "Beth's Heart", "en_us")
	EID:addCollectible(CollectibleType.COLLECTIBLE_BETHS_HEART, BHDescSpa, "El corazón de Beth", "spa")
	EID:addCollectible(CollectibleType.COLLECTIBLE_BETHS_HEART, BHDescRu, "Сердце Вифании", "ru")
	EID:addCollectible(CollectibleType.COLLECTIBLE_BETHS_HEART, BHDescPt_Br, "Coração de Bethany", "pt_br")
end

include("lua/achievement_display_api.lua")

local Wiki = {
	BethsHeart = {
	  { -- Effect
		{str = "Effect", fsize = 2, clr = 3, halign = 0},
		{str = "Spawns a throwable familiar#Stores soul and black hearts to use as charges for the active item, maximum 6 pips of charge."},
		{str = "Half Soul Heart = 1 pip of charge. Soul Heart = 2 pips of charge. Black Heart = 3 pips of charge. Immortal Heart = 6 pips of charge."},
		{str = "Pressing the 'CTRL' key will supply pips of charge to the active item."},
	  },
	  { -- Notes
		{str = "Notes", fsize = 2, clr = 3, halign = 0},
		{str = "Getting BFFS! expands charge storage to 12 pips of charge."},
		{str = "Double tapping in one direction will launch Beth's Heart that direction."},
	  },
	  { -- Trivia
		{str = "Trivia", fsize = 2, clr = 3, halign = 0},
		{str = "Beth's Heart was one of the few items that was planned to be in Repentance but ultimately never came to fruition."},
		{str = "This is TC's third version of Beth's Heart. Originally, it was a trinket that had no familar, then a trinket with a familiar, and then an item."},

	  },
	  { -- Credits
		{str = "Credits", fsize = 2, clr = 3, halign = 0},
		{str = "Team Compliance Director: Sillst"},
		{str = "Coders: Akad, anchikai., BrakeDude"},
		{str = "Artists: Michael¿?, Sillst, Soaring___Sky, The Demisemihemidemisemiquaver"},
		{str = "Translators: BrakeDude, Kotry"},
		{str = "Playtesters: Akad, anchikai., BrakeDude, Kotry, Sillst"},
		{str = "Shoutout to im_tem for doing the familiar code!"},
	  },
	}
  }

if MiniMapiItemsAPI then
    local frame = 1
    local bethsHeartSprite = Sprite()
    bethsHeartSprite:Load("gfx/ui/minimapitems/bethsheart_icon.anm2", true)
    MiniMapiItemsAPI:AddCollectible(CollectibleType.COLLECTIBLE_BETHS_HEART, bethsHeartSprite, "CustomIconBethsHeart", frame)
end

if Encyclopedia then
	Encyclopedia.AddItem({
	  ID = CollectibleType.COLLECTIBLE_BETHS_HEART,
	  WikiDesc = Wiki.BethsHeart,
	  Pools = {
		Encyclopedia.ItemPools.POOL_TREASURE,
		Encyclopedia.ItemPools.POOL_ANGEL,
		Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		Encyclopedia.ItemPools.POOL_GREED_ANGEL,
	  },
	})
end

function mod:GetSlot(player,slot)
	local charge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
	local battery = player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY)
	local item = Isaac:GetItemConfig():GetCollectible(player:GetActiveItem(slot))
	if player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
		if charge < item.MaxCharges then
			return nil
		end
	elseif player:GetActiveItem(slot) > 0 and charge < item.MaxCharges * (battery and 2 or 1) and player:GetActiveItem(slot) ~= CollectibleType.COLLECTIBLE_ERASER then
		return slot
	elseif slot < ActiveSlot.SLOT_POCKET then
		slot = mod:GetSlot(player,slot + 1)
		return slot
	end
	return nil
end

function mod:OverCharge(player,slot,item)
	local effect = Isaac.Spawn(1000,49,1,player.Position+Vector(0,1),Vector.Zero,nil)
	effect:GetSprite().Offset = Vector(0,-22)
end

local DIRECTION_VECTOR = {
	[Direction.NO_DIRECTION] = Vector(0, 1),	-- when you don't shoot or move, you default to HeadDown
	[Direction.LEFT] = Vector(-1, 0),
	[Direction.UP] = Vector(0, -1),
	[Direction.RIGHT] = Vector(1, 0),
	[Direction.DOWN] = Vector(0, 1)
}

function mod:PostUpdateAchiv()
	local showAchievement
	if not showAchievement then
		showAchievement = mod:HasData() and json.decode(mod:LoadData()) or false
		if Isaac.GetPlayer().ControlsEnabled and showAchievement ~= true then
			showAchievement = true
			mod:SaveData(json.encode(showAchievement))
			CCO.AchievementDisplayAPI.PlayAchievement("gfx/ui/achievements/Cut_Achievement_Beth27s_Heart.png")
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.PostUpdateAchiv)

function mod:GetIdentifier(player)
	local outid=1
	if player:GetPlayerType()==PlayerType.PLAYER_LAZARUS2_B then
		outid=2
	end
	return player:GetCollectibleRNG(outid):GetSeed()
end

function mod:HeartCollectibleUpdate(player)
	if not mod:GetData(player).BethsHeartIdentifier then
		mod:GetData(player).BethsHeartIdentifier=mod:GetIdentifier(player)
	end
	local numFamiliars = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BETHS_HEART) + player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_BETHS_HEART)
	
	player:CheckFamiliar(bethsheart, numFamiliars, player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BETHS_HEART), bethsheartdesc)	
end

function mod:BethsHeartInit(heart)
	heart:AddToFollowers()
	heart.State = 0
	--heart.Hearts = 0
end
function mod:BethsHeartUpdate(heart)
	local player = heart.Player
	local bff = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 2 or 1
	if heart.Hearts > 6 * bff then
		heart.Hearts = 6 * bff
	end
	local heartspr=heart:GetSprite()
	if not heartspr:IsPlaying("Idle"..heart.Hearts) then
		heartspr:Play("Idle"..heart.Hearts,false)
	end
	if not heartspr:IsOverlayPlaying("Charge"..heart.Hearts) then
		heartspr:PlayOverlay("Charge"..heart.Hearts,false)
	end

	if heart.State ~= 1 then
		heart:FollowParent()
		heart.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	else
		heart:RemoveFromFollowers()
		heart.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
	end

	if heart.State == 1 then
		for _,soulheart in pairs(Isaac.FindInRadius(heart.Position,15 + 5 * (bff-1),EntityPartition.PICKUP)) do
			if soulheart.Variant == PickupVariant.PICKUP_HEART and not soulheart:GetSprite():IsPlaying("Collect") then
				local restoreamount=0
				if soulheart.SubType == 902 then
					restoreamount=6
				elseif soulheart.SubType == HeartSubType.HEART_BLACK then
					restoreamount=3
				elseif soulheart.SubType == HeartSubType.HEART_SOUL then
					restoreamount=2
				elseif soulheart.SubType == HeartSubType.HEART_HALF_SOUL then
					restoreamount=1
				end
				if (not soulheart:ToPickup():IsShopItem()) and restoreamount>0 then
					if player:GetPlayerType() ~= PlayerType.PLAYER_BETHANY then
						if heart.Hearts < 6 * bff then
							heart.Hearts=heart.Hearts+restoreamount
							local effect = Isaac.Spawn(1000,49,4,heart.Position,Vector.Zero,heart)
							effect:GetSprite().Offset = Vector(0,-11)
							SFXManager():Play(171,1)
							soulheart:GetSprite():Play("Collect")
							soulheart:Die()
							soulheart.EntityCollisionClass=0
						end
					end
				end
			end
		end
		if heart:CollidesWithGrid() then
			heart.Velocity = Vector.Zero
			heart.State = 2
		end
	end
	if heart.State == 2 then
		local target = player
		if player:HasCollectible(CollectibleType.COLLECTIBLE_KING_BABY) then
			for _,king in ipairs(Isaac.FindByType(3,FamiliarVariant.KING_BABY)) do
				local baby = king:ToFamiliar()
				if GetPtrHash(baby.Player) == GetPtrHash(player) then
					target = baby
				end
			end
		end
		if (heart.Position - target.Position):Length() <= 70 then
			heart.State = 0
			heart:AddToFollowers()
		end
	end
end

function mod:BethInputUpdate(player)
	for _,heart in ipairs(Isaac.FindByType(3,bethsheart)) do
		if GetPtrHash(player) == GetPtrHash(heart:ToFamiliar().Player) then
			heart = heart:ToFamiliar()
			local heartData = mod:GetData(heart)
			local idx = player.ControllerIndex
			if Input.IsActionTriggered(ButtonAction.ACTION_DROP, idx) and heart.Hearts > 0 then
				local slot = mod:GetSlot(player,ActiveSlot.SLOT_PRIMARY)
				local charge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
				local item = Isaac:GetItemConfig():GetCollectible(player:GetActiveItem(slot))
				local battery = player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and 2 or 1
				if charge < item.MaxCharges * battery and item.ChargeType ~= 1 then
					Game():GetHUD():FlashChargeBar(player, slot)
					local charging
					if charge + heart.Hearts < item.MaxCharges * battery then
						charging = charge + heart.Hearts
						heart.Hearts = 0
					else
						charging = item.MaxCharges * battery
						heart.Hearts = heart.Hearts + charge - item.MaxCharges * battery
					end
					player:SetActiveCharge(charging, slot)
					SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE)
					mod:OverCharge(player)
				elseif item.ChargeType == 1 and charge < item.MaxCharges * battery then
					for i = 1,battery do
						if heart.Hearts > 0 and charge < item.MaxCharges * battery then
							player:FullCharge(slot)
							charge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
							heart.Hearts = heart.Hearts - 1
						else
							break
						end
					end
					mod:OverCharge(player)
				end
			end

			if not heartData.ShootButtonState and heart.State == 0 then
				if Input.IsActionTriggered(4, idx) then
				heartData.ShootButtonPressed = 4
				heartData.ShootButtonState = "listening for second tap"
				heartData.PressFrame = Game():GetFrameCount()
				elseif Input.IsActionTriggered(5, idx) then
					heartData.ShootButtonPressed = 5
					heartData.ShootButtonState = "listening for second tap"
					heartData.PressFrame = Game():GetFrameCount()
				elseif Input.IsActionTriggered(6, idx) then
					heartData.ShootButtonPressed = 6
					heartData.ShootButtonState = "listening for second tap"
					heartData.PressFrame = Game():GetFrameCount()
				elseif Input.IsActionTriggered(7, idx) then
					heartData.ShootButtonPressed = 7
					heartData.ShootButtonState = "listening for second tap"
					heartData.PressFrame = Game():GetFrameCount()
				end
			end

			if heartData.ShootButtonPressed and heartData.PressFrame and (Game():GetFrameCount() <= heartData.PressFrame + 10) and heart.State == 0 then
				if not Input.IsActionTriggered(heartData.ShootButtonPressed, idx) and heartData.ShootButtonState == "listening for second tap" then
					heartData.ShootButtonState = "button released"
				end
				
				if heartData.ShootButtonState == "button released" and Input.IsActionTriggered(heartData.ShootButtonPressed, idx) then
					heart.State = 1
					heart.Velocity =  DIRECTION_VECTOR[player:GetFireDirection()]:Resized(12) + heart.Velocity / 2
					heartData.ShootButtonState = nil
					heartData.ShootButtonPressed = nil
					heartData.PressFrame = nil
				end
			else
				heartData.ShootButtonState = nil
				heartData.ShootButtonPressed = nil
				heartData.PressFrame = nil
			end

		end
	end
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT,mod.BethsHeartInit,bethsheart)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE,mod.BethsHeartUpdate,bethsheart)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,mod.BethInputUpdate)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE,mod.HeartCollectibleUpdate,CacheFlag.CACHE_FAMILIARS)



function mod:GetData(entity)
	if entity and entity.GetData then
		local data = entity:GetData()
		if not data.BethsHeart then
			data.BethsHeart = {}
		end
		return data.BethsHeart
	end
	return nil
end