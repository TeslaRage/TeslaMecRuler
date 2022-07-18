class X2Ability_TeslaMecRuler extends X2Ability config(GameData_SoldierSkills);

var config float MECRULERMICROMISSILE_DAMAGE_RADIUS;
var config int ARMORREPAIRMODULE_REGEN_AMOUNT;
var config int ARMORREPAIRMODULE_MAX_REGEN_AMOUNT;
var config float BSLIKEEFFECT_DAMAGEREDUCTION;
var config float MELEE_DAMAGEREDUCTION;
var config WeaponDamageValue STRIKEDAMAGE;

var config int MECRULER_ARMOR_HEALTH_BONUS;
var config int MECRULER_ARMOR_MOBILITY_BONUS;
var config int MECRULER_ARMOR_DODGE_BONUS;
var config int MECRULER_ARMOR_MITIGATION_CHANCE;
var config int MECRULER_ARMOR_MITIGATION_AMOUNT;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateMecRulerMicroMissilesAbility());
	Templates.AddItem(CreateArmorRepairModule());
	Templates.AddItem(CreateBSDamaReductionModule());
	Templates.AddItem(CreateMeleeResistanceModule());
	Templates.AddItem(CreateMeleeStrike());
	Templates.AddItem(CreateMecRulerArmorStats());

	return Templates;
}

static function X2DataTemplate CreateMecRulerMicroMissilesAbility()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_Ammo AmmoCost;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2Effect_ApplyWeaponDamage WeaponEffect;
	local X2AbilityTarget_Cursor CursorTarget;
	local X2AbilityMultiTarget_Radius RadiusMultiTarget;
	local X2AbilityCooldown Cooldown;
	local X2AbilityToHitCalc_StandardAim StandardAim;
	local X2Effect_Knockback KnockbackEffect;
	local X2Effect_PersistentStatChange DisorientEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'MecRulerMicroMissiles');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_fanfire";
	Template.Hostility = eHostility_Offensive;

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.bUseAmmoAsChargesForHUD = true;

	Template.TargetingMethod = class'X2TargetingMethod_MECMicroMissile';
 
	// Cooldown on the ability
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 6;
	Template.AbilityCooldown = Cooldown;

	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.bGuaranteedHit = true;
	Template.AbilityToHitCalc = StandardAim;
	
	CursorTarget = new class'X2AbilityTarget_Cursor';
	CursorTarget.bRestrictToWeaponRange = true;
	Template.AbilityTargetStyle = CursorTarget;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = default.MECRULERMICROMISSILE_DAMAGE_RADIUS;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	WeaponEffect = new class'X2Effect_ApplyWeaponDamage';
	Template.AddMultiTargetEffect(WeaponEffect);

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	KnockbackEffect.OverrideRagdollFinishTimerSec = 2.0f;
	KnockbackEffect.OnlyOnDeath = false;
	Template.AddMultiTargetEffect(KnockbackEffect);

	DisorientEffect = class'X2StatusEffects'.static.CreateDisorientedStatusEffect(, 2.0f, false);
	DisorientEffect.iNumTurns = 2;
	Template.AddMultiTargetEffect(DisorientEffect);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "MEC_MicroMissiles";

	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.GrenadeLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;

	return Template;
}

static function X2AbilityTemplate CreateArmorRepairModule()
{
	local X2AbilityTemplate Template;
	local X2Effect_TeslaMecRuler RegenerationEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'MecRulerArmorRepairModule');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_repair";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	// Build the regeneration effect
	RegenerationEffect = new class'X2Effect_TeslaMecRuler';
	RegenerationEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
	RegenerationEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true, , Template.AbilitySourceName);
	RegenerationEffect.ArmorRepairAmount = default.ARMORREPAIRMODULE_REGEN_AMOUNT;
	RegenerationEffect.MaxArmorRepairAmount = default.ARMORREPAIRMODULE_MAX_REGEN_AMOUNT;
	RegenerationEffect.ArmorRepairedName = 'ModuleArmorRepaired';
	Template.AddTargetEffect(RegenerationEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate CreateBSDamaReductionModule()
{
	local X2AbilityTemplate Template;
	local X2Effect_TeslaMecRuler DamageReductionEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'MecRulerBSDamageReductionModule');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_damage_control";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	// Build the damage reduction effect
	DamageReductionEffect = new class'X2Effect_TeslaMecRuler';
	DamageReductionEffect.BuildPersistentEffect(1, true, true);
	DamageReductionEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true, , Template.AbilitySourceName);
	DamageReductionEffect.BSDamageReductionPrcnt = default.BSLIKEEFFECT_DAMAGEREDUCTION;
	Template.AddTargetEffect(DamageReductionEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate CreateMeleeResistanceModule()
{
	local X2AbilityTemplate Template;
	local X2Effect_TeslaMecRuler DamageReductionEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'MecRulerMeleeResistanceModule');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_sectoid_meleevulnerability";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	// Build the damage reduction effect
	DamageReductionEffect = new class'X2Effect_TeslaMecRuler';
	DamageReductionEffect.BuildPersistentEffect(1, true, true);
	DamageReductionEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true, , Template.AbilitySourceName);
	DamageReductionEffect.MeleeDamageReductionPrcnt = default.MELEE_DAMAGEREDUCTION;
	Template.AddTargetEffect(DamageReductionEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate CreateMeleeStrike()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityToHitCalc_StandardMelee StandardMelee;
	local X2Effect_ApplyWeaponDamage_TeslaMecRuler WeaponDamageEffect;
	local array<name> SkipExclusions;
	local X2AbilityCooldown Cooldown;
	local X2Effect_Knockback KnockbackEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'MecRulerStrike');
	Template.RemoveTemplateAvailablility(Template.BITFIELD_GAMEAREA_Multiplayer);

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;		
	Template.IconImage = "img:///UILibrary_DLC3Images.UIPerk_spark_strike";
	Template.bHideOnClassUnlock = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.AbilityConfirmSound = "TacticalUI_SwordConfirm";
	Template.MeleePuckMeshPath = "Materials_DLC3.MovePuck_Strike";

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 6;
	Template.AbilityCooldown = Cooldown;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.bMoveCost = true;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
	StandardMelee.BuiltInHitMod = 20; //default.STRIKE_HITMOD;
	Template.AbilityToHitCalc = StandardMelee;

	Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');

	// Target Conditions
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	// Shooter Conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	// Damage Effect
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage_TeslaMecRuler';
	WeaponDamageEffect.StrikeDamage = default.STRIKEDAMAGE;
	Template.AddTargetEffect(WeaponDamageEffect);

	Template.bAllowBonusWeaponEffects = true;
	Template.bSkipMoveStop = true;
	Template.CustomFireAnim = 'FF_Melee';
	Template.CustomMovingFireAnim = 'MV_Melee';	

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	Template.AddTargetEffect(KnockbackEffect);
	Template.bOverrideMeleeDeath = true;

	Template.SourceMissSpeech = 'SwordMiss';

	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Spark_Strike";

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.MeleeLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;

	return Template;
}

static function X2AbilityTemplate CreateMecRulerArmorStats()
{
	local X2AbilityTemplate Template;
	local X2AbilityTrigger Trigger;
	local X2AbilityTarget_Self TargetStyle;
	local X2Effect_PersistentStatChange PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'MecRulerArmorStats');
	Template.RemoveTemplateAvailablility(Template.BITFIELD_GAMEAREA_Multiplayer);

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;

	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);

	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_HP, default.MECRULER_ARMOR_HEALTH_BONUS);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Mobility, default.MECRULER_ARMOR_MOBILITY_BONUS);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Dodge, default.MECRULER_ARMOR_DODGE_BONUS);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorChance, default.MECRULER_ARMOR_MITIGATION_CHANCE);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorMitigation, default.MECRULER_ARMOR_MITIGATION_AMOUNT);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}
