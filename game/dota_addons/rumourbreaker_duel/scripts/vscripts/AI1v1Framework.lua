--[[
	1v1 AI Competition framework
	Code: Yaofeng, based on Perry
	Date: 2018
	-------------
	1. 1v1 GameRule: Player slot
	2. Control UI according to config
	3. Listener UI mode select: create fake client, init gamemode
	3. GameStateListener
		DOTA_GAMERULES_STATE_HERO_SELECTION: create hero for AI
		DOTA_GAMERULES_STATE_PRE_GAME

]]

--Include AI
--require( 'AI.AIManager' )
--Require game mode logic
require( 'AIGameModes.BaseAIGameMode' )

if AI1v1Framework == nil then
	AI1v1Framework = class({})
end

--Initialisation
function AI1v1Framework:Init()
	print( 'Initialising AI lv1 framework.' )

	--Fixed Rules in 1v1
	GameRules:SetCustomGameTeamMaxPlayers( 1, 	5 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 	1 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 	1 )
	
	--there are unfixed Rules according to game model

	--Initialise the AI manager
	--AIManager:Init()

	--Register event listeners
	ListenToGameEvent( 'game_rules_state_change', Dynamic_Wrap( AI1v1Framework, 'OnGameStateChange' ), self )
	CustomGameEventManager:RegisterListener( 'spawn_ai', function(...) self:SpawnAI(...) end )

	--Read in gamemode config
	self.config = LoadKeyValues("scripts/config/gamemode_ai.kv")
	
	--Send gamemode info to nettable for UI
	local nettable = {}
	for i, gamemode in pairs(self.config) do
		nettable[i] = {name = gamemode.Name, name, type = gamemode.Type ,name, hero = gamemode.Hero}
	end
	CustomNetTables:SetTableValue("config", "gamemodes", nettable)
end

--game_rules_state_changed event handler
function AI1v1Framework:OnGameStateChange( event )
	local state = GameRules:State_Get()
	if state == DOTA_GAMERULES_STATE_PRE_GAME then
		
		--self:OnGameLoaded()	
	elseif state == DOTA_GAMERULES_STATE_HERO_SELECTION then
		self.gameMode:HeroSelect()
	elseif state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		print('USE PARTICLE')
		--local particle = ParticleManager:CreateParticle("particles/test_sprite.vpcf", PATTACH_WORLDORIGIN, nil)
        --ParticleManager:SetParticleControl(particle, 0, Vector(0,0,0))
        --DebugDrawCircle(Vector(0,0,0), Vector(255,0,0), 25, 640, true, 100)
		self.gameMode:HeroInit()
		--self.gameMode.TEST()
		self.gameMode:Colosseum()
		--GameRules:GetGameModeEntity():SetThink("TEST", self.gameMode, 5)
	end 
end
--[[
--Called once the game gets to the PRE_GAME state
function AI1v1Framework:OnGameLoaded()
	local t = 1
	Timers:CreateTimer( 1, function()
		if t < 4 then
			--Count down
			ShowCenterMessage( 4 - t, 1 )
		else
			ShowCenterMessage( 'Start!', 2 )
			--Initialise Radiant AI
			--AIManager:InitAllAI( self.gameMode )

			--Initialise gamemode
			--self.gameMode:OnGameStart( AIManager:GetAllHeroes() )

			return nil
		end
		t = t + 1
		return 1
	end)
end
]]

function AI1v1Framework:PlayerAssign(mode_type, hero_list)
	--assign&set playerInfo
	
	playerInfo = {}

	Timers:CreateTimer( 1, function()
		local player_count = PlayerResource:GetPlayerCount()
		for i=0,player_count-1 do
			playerInfo[i] = {}
			if PlayerResource:IsFakeClient(i) then
				playerInfo[i]['isFake'] = 1 
				if playerInfo['fake'] == nil then
					playerInfo['fake'] = {}
				end
				table.insert(playerInfo['fake'],i)
			else
				playerInfo[i]['isFake'] = 0
				if playerInfo['human'] == nil then
					playerInfo['human'] = {}
				end
				table.insert(playerInfo['human'],i)
			end
		end
		
		if mode_type == "HUMAN-BOT" then
			PlayerResource:SetCustomTeamAssignment( playerInfo['human'][1], DOTA_TEAM_GOODGUYS )
			playerInfo[playerInfo['human'][1]]['team'] = DOTA_TEAM_GOODGUYS
			PlayerResource:SetCustomTeamAssignment( playerInfo['fake'][1],  DOTA_TEAM_BADGUYS)
			playerInfo[playerInfo['fake'][1]]['team'] = DOTA_TEAM_BADGUYS
		elseif mode_type == "BOT-HUMAN" then
			PlayerResource:SetCustomTeamAssignment( playerInfo['human'][1], DOTA_TEAM_BADGUYS )
			playerInfo[playerInfo['human'][1]]['team'] = DOTA_TEAM_BADGUYS
			PlayerResource:SetCustomTeamAssignment( playerInfo['fake'][1], DOTA_TEAM_GOODGUYS )
			playerInfo[playerInfo['fake'][1]]['team'] = DOTA_TEAM_GOODGUYS
		else
			PlayerResource:SetCustomTeamAssignment( playerInfo['human'][1], 1 )
			playerInfo[playerInfo['human'][1]]['team'] = 1
			PlayerResource:SetCustomTeamAssignment( playerInfo['fake'][1], DOTA_TEAM_GOODGUYS )
			playerInfo[playerInfo['fake'][1]]['team'] = DOTA_TEAM_GOODGUYS
			PlayerResource:SetCustomTeamAssignment( playerInfo['fake'][2], DOTA_TEAM_BADGUYS )
			playerInfo[playerInfo['fake'][2]]['team'] = DOTA_TEAM_BADGUYS
		end

		for i=0,player_count-1 do
			local team = playerInfo[i]['team']
			if team>1 then
				playerInfo[i]['hero'] = hero_list[team]
			else
				playerInfo[i]['hero'] = 'SPECTOR'
			end
		end

	end)	
end


function AI1v1Framework:SpawnAI( source, args )
	DeepPrintTable(args)
	--Load gamemode
	local modeConfig = self.config[args.game_mode]
	local gameMode = require( 'AIGameModes.'..modeConfig.Path )

	--Set up the game mode
	gameMode:Setup()

	local mode_type = modeConfig.Type[args.mode_type]
	SendToServerConsole( 'sv_cheats 1' )
	--create fake client
	if mode_type == "HUMAN-BOT" then
		SendToServerConsole( 'dota_create_fake_clients 2' )
	elseif mode_type == "BOT-HUMAN" then
		SendToServerConsole( 'dota_create_fake_clients 2' )
	else
		SendToServerConsole( 'dota_create_fake_clients 3' )
	end
	local heroList = {}
	heroList[DOTA_TEAM_GOODGUYS] = modeConfig.Hero[args.hero1]
	heroList[DOTA_TEAM_BADGUYS] = modeConfig.Hero[args.hero2]
	DeepPrintTable(heroList)
	self:PlayerAssign(mode_type,heroList)

	--gameMode.PlayerHeroPairs = {modeConfig.Hero[args.hero1], modeConfig.Hero[args.hero2]}

	
	--Load in AI
	--[[
	if args.ai1 ~= "0" and args.ai1 ~= 0 then
		AIManager:AddAI( modeConfig.AI[args.ai1], DOTA_TEAM_GOODGUYS, heroes )
	end
	if args.ai2 ~= "0" and args.ai2 ~= 0 then
		AIManager:AddAI( modeConfig.AI[args.ai2], DOTA_TEAM_BADGUYS, heroes )
	end
	]]
	--Save gamemode for later
	self.gameMode = gameMode
	self.gameMode.playerInfo = playerInfo
end

--Show a center message for some duration
function ShowCenterMessage( msg, dur )
	local centerMessage = {
		message = msg,
		duration = dur or 3
	}
	FireGameEvent( "show_center_message", centerMessage )
end
