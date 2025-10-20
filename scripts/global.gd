extends Node

var items = {
	"planks": {
		"name": "Planks",
		"description": "Used mostly for crafting.",
	},
	"cloth": {
		"name": "Cloth",
		"description": "Used for crafting.",
	},
	"fish": {
		"name": "Fish",
		"description": "Quite delicious.",
	},
	"worm_bait": {
		"name": "Worm Bait",
		"description": "Attracts fishies.",
	},
	"fish_bait": {
		"name": "Fish Bait",
		"description": "Attracts things that eat fishies.",
	},
	"wood_bait": {
		"name": "Wood Bait",
		"description": "Attracts materials. Somehow. Don't question it.",
	},
	"metal_bait": {
		"name": "Metal Bait",
		"description": "Attracts metal materials... what the hell is in this?",
	},
	"medkit": {
		"name": "Medkit",
		"description": "Heals 50% health.",
	},
	"bug_net": {
		"name": "Bug Net",
		"description": "Catches bugs.",
	},
	"wooden_spikes": {
		"name": "Wooden Spikes",
		"description": "A trap for unsuspecting intruders.\n\n[Left Click] to place.",
	},
	"shovel": {
		"name": "Shovel",
		"description": "Use it to get worms.",
	},
	"axe": {
		"name": "Axe",
		"description": "Although you don't have trees, this CAN be used to chop your enemies.",
	},
	"scrap_metal": {
		"name": "Scrap Metal",
		"description": "Some rusty metal. Used for crafting.",
	},
	"battery": {
		"name": "Battery",
		"description": "An old, rusty battery. No acid leaking out. Might be usable...",
	},
	"makeshift_laser_pointer": {
		"name": "Makeshift Laser Pointer",
		"description": "Shoot it at an airplane, and they might see you!",
	},
	"computer_chip": {
		"name": "Computer Chip",
		"description": "You can use this in electronics. If it even works.",
	},
	"plastic": {
		"name": "Plastic",
		"description": "Scrap plastic. Used in crafting",
	},
	"smoke_starter": {
		"name": "Smoke Starter",
		"description": "Makes your fire extremely smoky for a short period of time. One-time use.",
	},
	"unpurified_water": {
		"name": "Water (Unpurified)",
		"description": "Wouldn't recommend drinking this.",
	},
	"purified_water": {
		"name": "Water (Safe)",
		"description": "Some nice, clean water.",
	},
	"umbrella": {
		"name": "Umbrella",
		"description": "Provides shelter from the rain.",
	}
}

var recipes = {
	"unpurified_water": {
		"ingredients": [
			{}
		]
	},
	"purified_water": {
		"ingredients": [
			{
				"id": "unpurified_water",
				"amount": 1
			},
			{
				"id": "cloth",
				"amount": 1
			}
		]
	},
	"fish_bait": {
		"ingredients": [
			{
				"id": "fish",
				"amount": 1
			}
		]
	},
	"wood_bait": {
		"amount": 2,
		"ingredients": [
			{
				"id": "planks",
				"amount": 1
			}
		]
	},
	"metal_bait": {
		"amount": 2,
		"ingredients": [
			{
				"id": "scrap_metal",
				"amount": 1
			}
		]
	},
	"bug_net": {
		"amount": 1,
		"ingredients": [
			{
				"id": "planks",
				"amount": 1
			},
			{
				"id": "cloth",
				"amount": 2
			},
		]
	},
	"shovel": {
		"amount": 1,
		"ingredients": [
			{
				"id": "planks",
				"amount": 1
			},
			{
				"id": "scrap_metal",
				"amount": 2
			},
			{
				"id": "cloth",
				"amount": 1
			},
		]
	},
	"axe": {
		"amount": 1,
		"ingredients": [
			{
				"id": "planks",
				"amount": 1
			},
			{
				"id": "scrap_metal",
				"amount": 2
			},
			{
				"id": "cloth",
				"amount": 1
			},
		]
	},
	"wooden_spikes": {
		"amount": 1,
		"ingredients": [
			{
				"id": "planks",
				"amount": 5
			}
		]
	},
	"makeshift_laser_pointer": {
		"amount": 1,
		"ingredients": [
			{
				"id": "scrap_metal",
				"amount": 5
			},
			{
				"id": "battery",
				"amount": 1
			}
		]
	},
	"smoke_starter": {
		"amount": 1,
		"ingredients": [
			{
				"id": "scrap_metal",
				"amount": 1
			},
			{
				"id": "plastic",
				"amount": 3
			},
			{
				"id": "planks",
				"amount": 1
			}
		]
	}
}

var hazards = {
	"rain": {
		"name": "Rain",
		"description": """It rains on you. Being cold and wet isn't good for your health, I believe.
		
Counters: Umbrellas"""
	}
}

var enemies = {
	"mosquito": {
		"name": "Mosquitos",
		"scene": preload("res://scenes/mosquito.tscn"),
		"description": """Nasty jerk. Spreads diseases. Hurts you.
		
Counters: Bug nets"""
	},
	"shark": {
		"name": "Sharks",
		"scene": preload("res://scenes/shark.tscn"),
		"description": """Don't usually attack people, but these guys will go up on the surface to getcha.
		
Counters: Spikes, walls"""
	},
	"zombie": {
		"name": "Zombies",
		"scene": preload("res://scenes/zombie.tscn"),
		"description": """Where they came from is beyond me. What you need to know is that they want your brains...
		
Counters: Walls"""
	},
	"ufo": {
		"name": "Flying Saucers",
		"scene": preload("res://scenes/zombie.tscn"),
		"description": """These guys want to experiment on you. Or something. I don't know, I'm just a description.
		
Counters: Tinfoil hats"""
	},
}

var nights = {
	-1: {
		"hazards": [],
		"enemies": [],
		"length": 0,
	},
	0: {
		"hazards": [],
		"enemies": [
			"mosquito"
		],
		"length": 30,
	},
	1: {
		"hazards": [
			"rain"
		],
		"enemies": [
			"shark",
			"mosquito"
		],
		"length": 30,
	},
	2: {
		"hazards": [],
		"enemies": [
			"mosquito",
			"shark"
		],
	},
	3: {
		"hazards": [
			"rain",
			"thunder"
		],
		"enemies": [
			"mosquito",
			"shark",
			"ufo"
		],
	},
	4: {
		"hazards": [],
		"enemies": [
			"shark",
			"ufo",
			"zombie"
		],
	},
	5: {
		"hazards": [
			"rain",
			"thunder"
		],
		"enemies": [
			"shark",
			"ufo",
			"zombie",
			"mosquito"
		],
	},
}

var loot_tables = {
	"fish_fishing": [
		{
			"id": "fish",
			"amount": 2,
			"chance": 2
		},
		{
			"id": "fish",
			"chance": 4
		},
		{
			"id": "fish_bait",
			"chance": 1
		},
	],
	"gear_fishing": [
		{
			"id": "planks",
			"chance": 14
		},
		{
			"id": "cloth",
			"chance": 10
		},
		{
			"id": "cloth",
			"amount": 2,
			"chance": 3
		},
		{
			"id": "scrap_metal",
			"amount": 2,
			"chance": 5
		}
	],
	"metal_fishing": [
		{
			"id": "battery",
			"amount": 1,
			"chance": 2
		},
		{
			"id": "computer_chip",
			"chance": 2
		},
		{
			"id": "scrap_metal",
			"chance": 12
		},
		{
			"id": "scrap_metal",
			"amount": 2,
			"chance": 3
		}
	],
}

func _ready() -> void:
	for n in loot_tables.values():
		for o in n:
			if o.has("done_processed"):
				break
			
			o.done_processed = true
			if o.chance > 1:
				var i = 0
				while i < o.chance:
					n.push_back(o)
					i += 1
