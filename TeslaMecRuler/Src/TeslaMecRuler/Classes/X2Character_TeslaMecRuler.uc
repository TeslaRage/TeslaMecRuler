class X2Character_TeslaMecRuler extends X2Character;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateTemplate_MecRuler());
	Templates.AddItem(CreateTemplate_AdventSpark());

	return Templates;
}

static function X2CharacterTemplate CreateTemplate_MecRuler()
{
	local X2SparkCharacterTemplate_DLC_3 CharTemplate;
	local LootReference Loot;

	`CREATE_X2TEMPLATE(class'X2SparkCharacterTemplate_DLC_3', CharTemplate, 'MecRuler');
	CharTemplate.CharacterGroupName = 'MecRuler';
	CharTemplate.DefaultLoadout='MecRuler_Loadout';
	CharTemplate.BehaviorClass=class'XGAIBehavior';
	CharTemplate.strBehaviorTree = "RulerBehavior"; //"MecRuler::CharacterRoot";
	Loot.ForceLevel=0;
	Loot.LootTableName='MecRuler_BaseLoot';
	CharTemplate.Loot.LootReferences.AddItem(Loot);

	CharTemplate.strMatineePackages.AddItem("CIN_AdventMEC");
	CharTemplate.strTargetingMatineePrefix = "CIN_AdventMEC_FF_StartPos";

	CharTemplate.UnitSize = 1;
	CharTemplate.UnitHeight = 3; //One unit taller than normal
	
	CharTemplate.KillContribution = 3.0;

	// Traversal Rules
	CharTemplate.bCanUse_eTraversal_Normal = true;
	CharTemplate.bCanUse_eTraversal_ClimbOver = true;
	CharTemplate.bCanUse_eTraversal_ClimbOnto = true;
	CharTemplate.bCanUse_eTraversal_ClimbLadder = false;
	CharTemplate.bCanUse_eTraversal_DropDown = true;
	CharTemplate.bCanUse_eTraversal_Grapple = false;
	CharTemplate.bCanUse_eTraversal_Landing = true;
	CharTemplate.bCanUse_eTraversal_BreakWindow = true;
	CharTemplate.bCanUse_eTraversal_KickDoor = true;
	CharTemplate.bCanUse_eTraversal_JumpUp = true;
	CharTemplate.bCanUse_eTraversal_WallClimb = false;
	CharTemplate.bCanUse_eTraversal_BreakWall = false;
	CharTemplate.bAppearanceDefinesPawn = true;
	CharTemplate.bCanTakeCover = false;

	CharTemplate.bIsAlien = false;
	CharTemplate.bIsAdvent = true;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsPsionic = false;
	CharTemplate.bIsRobotic = true;
	CharTemplate.bIsSoldier = false;
	
	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bCanBeCriticallyWounded = false;
	CharTemplate.bIsAfraidOfFire = false;
	CharTemplate.bFacesAwayFromPod = true;

	CharTemplate.bAllowSpawnFromATT = false;
	CharTemplate.bAllowRushCam = false;
	CharTemplate.bCanTickEffectsEveryAction = true;
	CharTemplate.bManualCooldownTick = true;
	CharTemplate.AcquiredPhobiaTemplate = 'FearOfMecs';

	CharTemplate.strScamperBT = "ScamperRoot_Overwatch";

	CharTemplate.Abilities.AddItem('RobotImmunities');
	CharTemplate.Abilities.AddItem('DarkEventAbility_Barrier');
	CharTemplate.Abilities.AddItem('Evac');
	CharTemplate.Abilities.AddItem('AlienRulerPassive');
	CharTemplate.Abilities.AddItem('AlienRulerCallForEscape');
	CharTemplate.Abilities.AddItem('AlienRulerActionSystem');
	CharTemplate.Abilities.AddItem('AlienRulerInitialState');
	CharTemplate.Abilities.AddItem('MecRulerArmorRepairModule');
	CharTemplate.Abilities.AddItem('MecRulerBSDamageReductionModule');
	CharTemplate.Abilities.AddItem('MecRulerMeleeResistanceModule');	
	CharTemplate.Abilities.AddItem('MecRulerStrike');

	CharTemplate.ImmuneTypes.AddItem('Mental');

	CharTemplate.strHackIconImage = "UILibrary_Common.TargetIcons.Hack_robot_icon";
	CharTemplate.strTargetIconImage = class'UIUtilities_Image'.const.TargetIcon_Advent;

	CharTemplate.OnStatAssignmentCompleteFn = class'X2Character_DLC_Day60Characters'.static.SetAlienRulerHealthAndArmor;
	CharTemplate.bIgnoreEndTacticalHealthMod = true;
	CharTemplate.bIgnoreEndTacticalRestoreArmor = true;
	CharTemplate.bHideInShadowChamber = true;
	CharTemplate.bDontClearRemovedFromPlay = true;

	// Appearance
	CharTemplate.bForceAppearance = true;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdventSpark()
{
	local X2SparkCharacterTemplate_DLC_3 CharTemplate;
	local LootReference Loot;

	`CREATE_X2TEMPLATE(class'X2SparkCharacterTemplate_DLC_3', CharTemplate, 'TR_AdventSpark');
	CharTemplate.CharacterGroupName = 'AdventMEC';
	CharTemplate.DefaultLoadout='TRAdvSpark_Loadout';
	CharTemplate.BehaviorClass=class'XGAIBehavior';
	Loot.ForceLevel=0;
	Loot.LootTableName='AdvMEC_M2_BaseLoot';
	CharTemplate.Loot.LootReferences.AddItem(Loot);

	// Timed Loot
	Loot.ForceLevel = 0;
	Loot.LootTableName = 'AdvMEC_M2_TimedLoot';
	CharTemplate.TimedLoot.LootReferences.AddItem(Loot);
	Loot.LootTableName = 'AdvMEC_M2_VultureLoot';
	CharTemplate.VultureLoot.LootReferences.AddItem(Loot);

	CharTemplate.strMatineePackages.AddItem("CIN_AdventMEC");
	CharTemplate.strTargetingMatineePrefix = "CIN_AdventMEC_FF_StartPos";

	CharTemplate.UnitSize = 1;

	// Traversal Rules
	CharTemplate.bCanUse_eTraversal_Normal = true;
	CharTemplate.bCanUse_eTraversal_ClimbOver = true;
	CharTemplate.bCanUse_eTraversal_ClimbOnto = true;
	CharTemplate.bCanUse_eTraversal_ClimbLadder = false;
	CharTemplate.bCanUse_eTraversal_DropDown = true;
	CharTemplate.bCanUse_eTraversal_Grapple = false;
	CharTemplate.bCanUse_eTraversal_Landing = true;
	CharTemplate.bCanUse_eTraversal_BreakWindow = true;
	CharTemplate.bCanUse_eTraversal_KickDoor = true;
	CharTemplate.bCanUse_eTraversal_JumpUp = true;
	CharTemplate.bCanUse_eTraversal_WallClimb = false;
	CharTemplate.bCanUse_eTraversal_BreakWall = false;
	CharTemplate.bAppearanceDefinesPawn = true;
	CharTemplate.bCanTakeCover = false;
	CharTemplate.bAllowRushCam = false;

	CharTemplate.bIsAlien = false;
	CharTemplate.bIsAdvent = true;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsPsionic = false;
	CharTemplate.bIsRobotic = true;
	CharTemplate.bIsSoldier = false;

	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bCanBeCriticallyWounded = false;
	CharTemplate.bIsAfraidOfFire = true;
	CharTemplate.bFacesAwayFromPod = true;
	CharTemplate.AcquiredPhobiaTemplate = 'FearOfMecs';

	CharTemplate.strScamperBT = "ScamperRoot_Overwatch";

	CharTemplate.Abilities.AddItem('RobotImmunities');
	CharTemplate.Abilities.AddItem('DarkEventAbility_Barrier');
	CharTemplate.Abilities.AddItem('MecRulerBSDamageReductionModule');
	CharTemplate.Abilities.AddItem('MecRulerMeleeResistanceModule');

	CharTemplate.strHackIconImage = "UILibrary_Common.TargetIcons.Hack_robot_icon";
	CharTemplate.strTargetIconImage = class'UIUtilities_Image'.const.TargetIcon_Advent;

	// Appearance
	CharTemplate.bForceAppearance = true;

	return CharTemplate;
}
