--Libraries
require( 'Libraries.Timers' )
--Core files
require( 'AI1v1Framework' )

--Precache, not using this atm
function Precache( context ) 
	--PrecacheResource( "particle", "*.vpcf", context )
	print('Precache Load')
	PrecacheResource( "particle", "particles/basic_projectile/basic_projectile_trail.vpcf", context )
	PrecacheResource( "particle", "particles/test_sprite.vpcf", context )
	PrecacheResource( "particle", "particles/falling_cherry_blossom.vpcf", context )
	PrecacheResource( "particle", "particles/omniknight_purification.vpcf", context )
end

--Activate the game mode
function Activate()
	--Initialise AI framework
	GameRules.Addon = AI1v1Framework()
	GameRules.Addon:Init()
end
