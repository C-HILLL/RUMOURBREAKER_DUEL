--[[
	Game mode: Duel.
	Idea: Two AI players battle in a Circle Zone. The winner is the AI that kills the other one.

	Starting level: 25
	Starting gold: 99999

	other need to do:
	--buy item in stategystate
	--write constraint code
]]

--Create a gamemode object from the default gamemode object
local AIGameMode = BaseAIGameMode()

--AIGameMode.playerInfo

AIGameMode.StartingLevel = 25
AIGameMode.StartingGold = 99999
--StartingItem
--StartingSkill

function AIGameMode:Setup()
	print('DuelMode Setup')

	--Set pre game time
	GameRules:SetStrategyTime( 0 )
	GameRules:SetShowcaseTime( 0 )
	GameRules:SetPreGameTime( 5.0 )

	--Disable side lanes
	Convars:SetBool( 'dota_disable_bot_lane', true )
	Convars:SetBool( 'dota_disable_mid_lane', true )
	Convars:SetBool( 'dota_disable_top_lane', true )
end

function AIGameMode:HeroSelect()
	
	for i,info in pairs(self.playerInfo) do
		if type(i) == 'number' then
			local hero_name = info['hero']
			if hero_name ~= 'SPECTOR' then
				local hero = CreateHeroForPlayer(hero_name, PlayerResource:GetPlayer(i))
				UTIL_Remove(hero)
			end
		end
	end
end

function AIGameMode:HeroInit()

	local custom_heros = LoadKeyValues("scripts/config/custom_heros.kv")
	
	DeepPrintTable(custom_heros)

	local heroTable = HeroList:GetAllHeroes()
	--init item,skill according to custom config
	for _,hero in pairs(heroTable) do
		local pId = hero:GetPlayerID()
		self.playerInfo[pId]['hHero'] = hero
	end
	

	for i,info in pairs(self.playerInfo) do
		if type(i) == 'number' and info['hero'] ~= 'SPECTOR' then
			local hero = info['hHero']

			local team = info['team']
			local itemAndTalent = custom_heros[tostring(team-1)]

			for _,item_name in pairs(itemAndTalent['Item']) do
				hero:AddItemByName(item_name)
			end

			for _=1,24 do
				hero:HeroLevelUp( true )
			end
			local t_offset
			for a_index=0,10 do
				local ability = hero:GetAbilityByIndex(a_index)
				if ability and string.match(ability:GetAbilityName(),"special_bonus") then
					t_offset = a_index
					break  
			    else
					for _=ability:GetLevel(),ability:GetMaxLevel()-1 do
						hero:UpgradeAbility(ability)
					end
				end
			end
			for t=0,3 do
				local tt = itemAndTalent['Talent'][tostring(t+1)]
				print(tt..'..'..type(tt))
				t_index = t_offset+tt+t*2
				local ability = hero:GetAbilityByIndex(t_index)
				--print(ability:GetAbilityName())
				hero:UpgradeAbility(ability)
			end
		end
	end
end

function AIGameMode:Colosseum()

	t1_good =  Entities:FindByName(nil, "dota_goodguys_tower1_mid")
	t1_bad =  Entities:FindByName(nil, "dota_badguys_tower1_mid")

	local radius = 700
	local centre = (t1_good:GetAbsOrigin()+t1_bad:GetAbsOrigin())/2
	for i=0,71 do

		local x = radius*math.cos(math.rad(5*i))
		local y = radius*math.sin(math.rad(5*i))
		print('x'..x)
		print('y'..y)
		local particle = ParticleManager:CreateParticle("particles/basic_projectile/basic_projectile_trail.vpcf", PATTACH_WORLDORIGIN, GameRules:GetGameModeEntity())
		ParticleManager:SetParticleControl(particle, 3, Vector(centre.x+x, centre.y+y, GetGroundHeight(Vector(centre.x+x, centre.y+y, 0),nil)+20))
	end
end

function AIGameMode:TEST()
	print('just test start')
	--goodSpawn = Entities:FindByName( nil, "npc_dota_spawner_good_mid_staging" )
	--goodWP = Entities:FindByName ( nil, "lane_mid_pathcorner_goodguys_1")
	--heroSpawn = Entities:FindByName (nil, "dota_goodguys_tower2_mid")
	hero = Entities:FindByName (nil, "npc_dota_hero_nevermore")
	
	
	--local fight_zone = (t1_good:GetAbsOrigin()+t1_bad:GetAbsOrigin())/2
	print(hero:GetAbsOrigin())
	print('omniknight_purification start!')
	--local particle = ParticleManager:CreateParticle("particles/omniknight_purification.vpcf", PATTACH_WORLDORIGIN, hero)
	--local particle = ParticleManager:CreateParticle("particles/basic_projectile/basic_projectile_trail.vpcf", PATTACH_WORLDORIGIN, hero)
	--ParticleManager:SetParticleControl(particle, 3, Vector(0,0,512))
	print('omniknight_purification finish!')
	--DebugDrawCircle(hero:GetAbsOrigin(), Vector(255,0,0), 25, 640, true, 1)
	--DebugDrawCircle(Vector(-500,-400,100), Vector(0,255,0), 25, 640, true, 1)
	--DebugDrawCircle(Vector(-500,-400,0), Vector(0,0,255), 25, 640, true, 1)
	return 1
end

--constraint hero action pos in circle zone, but in same angle
function AIGameMode:ActionFilter()
	print('')
end

function AIGameMode:OnGameStart( teamHeroes )
	--Call to BaseAIGameMode setting up starting gold/level
	self:InitHeroes( teamHeroes )

	--Save the only hero on each team for later
	self.team1Hero = teamHeroes[ DOTA_TEAM_GOODGUYS ][1]
	self.team2Hero = teamHeroes[ DOTA_TEAM_BADGUYS ][1]

	--Save the tower handles
	self.team1Tower = Entities:FindByName( nil, 'dota_goodguys_tower1_mid' )
	self.team2Tower = Entities:FindByName( nil, 'dota_badguys_tower1_mid' )

	--Listen to entity kills
	ListenToGameEvent( 'entity_killed', Dynamic_Wrap( AIGameMode, 'OnEntityKilled' ), self )
end

--entity_killed event handler
function AIGameMode:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )

	--Check for towers
	if killedUnit == self.team1Tower then
		--Call BaseAIGameMode functionality
		self:SetTeamWin( DOTA_TEAM_BADGUYS )
	elseif killedUnit == self.team2Tower then
		--Call BaseAIGameMode functionality
		self:SetTeamWin( DOTA_TEAM_GOODGUYS )
	end

	--Check hero kills
	if killedUnit == self.team1Hero or killedUnit == self.team2Hero then
		if PlayerResource:GetKills( self.team1Hero:GetPlayerOwnerID() ) >= 2 then
			--Call BaseAIGameMode functionality
			self:SetTeamWin( DOTA_TEAM_GOODGUYS )
		elseif PlayerResource:GetKills( self.team2Hero:GetPlayerOwnerID() ) >= 2 then
			--Call BaseAIGameMode functionality
			self:SetTeamWin( DOTA_TEAM_BADGUYS )
		end
	end
end

--Get extra data the AI can/needs to use for this challenge
function AIGameMode:GetExtraData( team )
	--No extra data
	return {}
end

return AIGameMode