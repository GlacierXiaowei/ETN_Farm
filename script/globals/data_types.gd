class_name DataType

enum Tools { 
	None,
	AxeWood, 
	TillGround, 
	WaterCrops, 
	PlantCorn, 
	PlantTomato 
}

## 种子 发芽 生长期 成熟期
enum GrowthState {
	Seed,
	Germination,
	Vegetative,
	Reproduction,
	Maturity,
	Harvesting
}
