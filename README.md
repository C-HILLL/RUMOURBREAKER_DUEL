# DOTA2 CUSTOM GAME: BOT DUEL
`KEYWORDS: DOTA2, bot, duel, reinforcement learning`

Compared to hardcode bot, Dota2 bot created in machine learning way is proved to be much stronger[[OpenAi blog](https://blog.openai.com/more-on-dota-2/)]. The challenge of Dota2 ML-bot is vast amount of information available at every frame, and the continuous set of actions possible. In this case, Dota2 ML-bot is usually simplified. For example:
* [OpenAi bot](https://blog.openai.com/more-on-dota-2/) is restricted on sf mid solo.
* [BeyondGodlikeBot bot](https://github.com/BeyondGodlikeBot/CreepBlockAI) is restricted on mid creep block.
* `IN THIS PROJECT` we focus on training a high performance bots(custom items and abilitys, fixed area) on duel, which is useful to break rumours like `Better Duel Hero` or `The Best Duel Hero`.

## About

## How to install
1. Install Dota Workshop Tools (`inaccessible in Mac OS`)
2. Create an empty addon (name whatever you want, `eg. rumourbreaker_duel`)
3. Copy `content/../panorama/` `content/../particles/` `game/../scripts/` into the corresponding path (overwrite the file, and addons path is easy to find in steam cilent `dota2 properties->local file->brower local file`)
4. Launch Dota Workshop Tools with your created addon
5. Open vConsole and execute `dota_launch_custom_game <name of your addon> dota`

## More details
[my wiki](https://github.com/C-HILLL/RUMOURBREAKER_DUEL/wiki)

## Related
#### Github
https://github.com/ModDota/Dota2AIFramework
https://github.com/BeyondGodlikeBot/CreepBlockAI
#### Forum
https://moddota.com/forums/
#### Offical community
https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools
