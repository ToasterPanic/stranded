extends Node

var items = {
	"planks": {
		"name": "Planks",
		"description": "Used mostly for crafting.",
	},
	"fish": {
		"name": "Fish",
		"description": "Quite delicious.",
	},
	"worm_bait": {
		"name": "Worm Bait",
		"description": "Attracts fishies.",
	},
	"wood_bait": {
		"name": "Wood Bait",
		"description": "Attracts gear. Somehow. Don't question it.",
	}
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
		{
			"id": "fish",
			"amount": 0,
			"chance": 2
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
		}
	]
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
