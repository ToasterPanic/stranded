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
		"description": "Attracts things that eat fishes.",
	},
	"wood_bait": {
		"name": "Wood Bait",
		"description": "Attracts gear. Somehow. Don't question it.",
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
	"wooden_spikes": {
		"amount": 1,
		"ingredients": [
			{
				"id": "planks",
				"amount": 5
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
