class X2Item_TeslaMecRuler extends X2Item config(GameData_WeaponData);

var config WeaponDamageValue MECRULERRIFLE_BASEDAMAGE;
var config int MECRULERRIFLE_ICLIPSIZE;
var config WeaponDamageValue MECRULERSHOULDERWEAPON_BASEDAMAGE;
var config int MECRULERSHOULDERWEAPON_CLIPSIZE;
var config int CTDROUNDS_DMGMOD;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Items;

	Items.AddItem(CreateTemplate_MecRuler_Rifle());
	Items.AddItem(CreateTemplate_MecRuler_ShoulderWeapon());
	Items.AddItem(CreateTemplate_CTDRounds());

	Items.AddItem(CreateTemplate_MecRuler_Armor_XCOM());

	return Items;
}

static function X2DataTemplate CreateTemplate_MecRuler_Rifle()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'MecRuler_Rifle');
	
	Template.WeaponPanelImage = "_BeamRifle";
	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'sparkrifle';
	Template.WeaponTech = 'magnetic';
	Template.strImage = "img:///UILibrary_Common.AlienWeapons.AdventMecGun";

	Template.RangeAccuracy = class'X2Item_DefaultWeapons'.default.FLAT_CONVENTIONAL_RANGE;
	Template.BaseDamage = default.MECRULERRIFLE_BASEDAMAGE;
	Template.iClipSize = default.MECRULERRIFLE_ICLIPSIZE;
	Template.iSoundRange = class'X2Item_DefaultWeapons'.default.ASSAULTRIFLE_MAGNETIC_ISOUNDRANGE;
	Template.iEnvironmentDamage = class'X2Item_DefaultWeapons'.default.ASSAULTRIFLE_MAGNETIC_IENVIRONMENTDAMAGE;
	Template.iIdealRange = class'X2Item_DefaultWeapons'.default.ADVMEC_M2_IDEALRANGE;

	Template.InventorySlot = eInvSlot_PrimaryWeapon;
	Template.Abilities.AddItem('StandardShot');
	Template.Abilities.AddItem('Overwatch');
	Template.Abilities.AddItem('OverwatchShot');
	Template.Abilities.AddItem('Reload');
	Template.Abilities.AddItem('HotLoadAmmo');
	Template.Abilities.AddItem('Suppression');

	Template.GameArchetype = "DLC_3_WP_SparkRifle_MG.WP_SparkRifle_MG";

	Template.iPhysicsImpulse = 5;

	Template.CanBeBuilt = false;
	Template.TradingPostValue = 30;

	Template.DamageTypeTemplateName = 'Projectile_MagAdvent';

	return Template;
}

static function X2DataTemplate CreateTemplate_MecRuler_ShoulderWeapon()
{
	local X2WeaponTemplate Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate', Template, 'MecRuler_ShoulderWeapon');
	
	Template.WeaponPanelImage = "_ConventionalRifle";
	Template.ItemCat = 'weapon';
	Template.WeaponCat = 'shoulder_launcher';
	Template.WeaponTech = 'conventional';
	Template.strImage = "img:///UILibrary_Common.AlienWeapons.AdventMecGun";
	Template.RemoveTemplateAvailablility(Template.BITFIELD_GAMEAREA_Multiplayer); //invalidates multiplayer availability

	Template.RangeAccuracy = class'X2Item_DefaultWeapons'.default.FLAT_CONVENTIONAL_RANGE;
	Template.BaseDamage = default.MECRULERSHOULDERWEAPON_BASEDAMAGE;
	Template.iClipSize = default.MECRULERSHOULDERWEAPON_CLIPSIZE;
	Template.iSoundRange = class'X2Item_DefaultWeapons'.default.ASSAULTRIFLE_MAGNETIC_ISOUNDRANGE;
	Template.iEnvironmentDamage = class'X2Item_DefaultWeapons'.default.ASSAULTRIFLE_MAGNETIC_IENVIRONMENTDAMAGE;
	Template.iIdealRange = class'X2Item_DefaultWeapons'.default.ADVMEC_M2_IDEALRANGE;
	
	Template.InventorySlot = eInvSlot_SecondaryWeapon;
	Template.Abilities.AddItem('MecRulerMicroMissiles');
	
	// This all the resources; sounds, animations, models, physics, the works.
	Template.GameArchetype = "WP_AdvMec_Launcher.WP_AdvMecLauncher";

	Template.iPhysicsImpulse = 5;

	Template.CanBeBuilt = false;
	Template.TradingPostValue = 30;
	Template.iRange = 20;

	// This controls how much arc this projectile may have and how many times it may bounce
	Template.WeaponPrecomputedPathData.InitialPathTime = 1.5;
	Template.WeaponPrecomputedPathData.MaxPathTime = 2.5;
	Template.WeaponPrecomputedPathData.MaxNumberOfBounces = 0;

	Template.DamageTypeTemplateName = 'Explosion';

	return Template;
}

static function X2DataTemplate CreateTemplate_MecRuler_Armor_XCOM()
{
	local X2SparkArmorTemplate_DLC_3 Template;

	`CREATE_X2TEMPLATE(class'X2SparkArmorTemplate_DLC_3', Template, 'MecRulerArmor_XCOM');
	Template.strImage = "img:///UILibrary_DLC3Images.Inv_Spark_Plated_A";
	Template.ItemCat = 'armor';
	Template.StartingItem = false;
	Template.CanBeBuilt = false;
	Template.bInfiniteItem = false;
	Template.bAlwaysRecovered = true;
	Template.TradingPostValue = 20;
	Template.PointsToComplete = 0;
	Template.Abilities.AddItem('MecRulerArmorStats');
	Template.Abilities.AddItem('MecRulerArmorRepairModule');
	Template.Abilities.AddItem('MecRulerMeleeResistanceModule');
	Template.ArmorTechCat = 'plated';
	Template.ArmorCat = 'spark';
	Template.Tier = 2;
	Template.AkAudioSoldierArmorSwitch = 'Predator';
	Template.EquipSound = "StrategyUI_Armor_Equip_Plated_Spark";

	Template.IntimidateStrength = class'X2Item_DLC_Day90Armors'.default.TIER2_INTIMIDATE_STRENGTH;
	Template.StrikeDamage = class'X2Item_DLC_Day90Armors'.default.TIER2_STRIKE_DMG;

	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, class'X2Ability_TeslaMecRuler'.default.MECRULER_ARMOR_HEALTH_BONUS, true);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, class'X2Ability_TeslaMecRuler'.default.MECRULER_ARMOR_MITIGATION_AMOUNT);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, class'X2Ability_TeslaMecRuler'.default.MECRULER_ARMOR_MOBILITY_BONUS);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.DodgeLabel, eStat_Dodge, class'X2Ability_TeslaMecRuler'.default.MECRULER_ARMOR_DODGE_BONUS);

	return Template;
}

static function X2DataTemplate CreateTemplate_CTDRounds()
{
	local X2AmmoTemplate Template;
	local X2Condition_UnitProperty Condition_UnitProperty;
	local WeaponDamageValue DamageValue;
	local X2Effect_RemoveEffects RemoveEffects;

	`CREATE_X2TEMPLATE(class'X2AmmoTemplate', Template, 'CTDRounds');
	Template.strImage = "img:///TMR_Spark.Inv_CTD_Rounds";

	DamageValue.DamageType = 'Electrical';
	Condition_UnitProperty = new class'X2Condition_UnitProperty';
	Condition_UnitProperty.ExcludeOrganic = true;
	Condition_UnitProperty.IncludeWeakAgainstTechLikeRobot = true;
	Condition_UnitProperty.TreatMindControlledSquadmateAsHostile = true;
	Condition_UnitProperty.FailOnNonUnits = true;
	DamageValue.Damage = default.CTDROUNDS_DMGMOD;
	Template.AddAmmoDamageModifier(Condition_UnitProperty, DamageValue);

	Template.CanBeBuilt = false;
	Template.bAlwaysRecovered = true;
	Template.TradingPostValue = 20;
	Template.PointsToComplete = 0;
	Template.Tier = 1;
	Template.EquipSound = "StrategyUI_Ammo_Equip";
	Template.bBypassShields = true;

	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem(class'X2Effect_EnergyShield'.default.EffectName);
	Template.TargetEffects.AddItem(RemoveEffects);

	Template.SetUIStatMarkup(class'XLocalizedData'.default.RoboticDamageBonusLabel, , default.CTDROUNDS_DMGMOD);
		
	//FX Reference
	Template.GameArchetype = "Ammo_Bluescreen.PJ_Bluescreen";
	
	return Template;
}
