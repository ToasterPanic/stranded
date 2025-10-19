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
	}
}

var recipes = {
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
	}
}

var enemies = {
	"mosquito": preload("res://scenes/mosquito.tscn"),
	"shark": preload("res://scenes/shark.tscn"), 
	"zombie": preload("res://scenes/zombie.tscn")
}

var nights = {
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
			"mosquito"
		],
		"length": 30,
	},
	2: {
		"hazards": [
			"rain"
		],
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
			"shark"
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
			"id": "medkit",
			"amount": 1,
			"chance": 2
		},
		{
			"id": "planks",
			"chance": 10
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
			"chance": 3
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
