class X2Item_TeslaMecRuler extends X2Item config(GameData_WeaponData);

var config WeaponDamageValue MECRULERRIFLE_BASEDAMAGE;
var config int MECRULERRIFLE_ICLIPSIZE;
var config WeaponDamageValue MECRULERSHOULDERWEAPON_BASEDAMAGE;
var config int MECRULERSHOULDERWEAPON_CLIPSIZE;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Weapons;

	Weapons.AddItem(CreateTemplate_MecRuler_Rifle());
	Weapons.AddItem(CreateTemplate_MecRuler_ShoulderWeapon());
	// Weapons.AddItem(CreateTemplate_MecRuler_Bit());

	return Weapons;
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

	// Template.GameArchetype = "WP_AdvMec_Gun.WP_AdvMecGun";
	// Template.GameArchetype = "DLC_3_WP_SparkRifle_BM.WP_SparkRifle_BM";
	Template.GameArchetype = "DLC_3_WP_SparkRifle_MG.WP_SparkRifle_MG";

	Template.iPhysicsImpulse = 5;

	Template.CanBeBuilt = false;
	Template.TradingPostValue = 30;

	Template.DamageTypeTemplateName = 'Projectile_MagAdvent';

	// Template.OnAcquiredFn = ApplyUpgrades;

	return Template;
}

// static function bool ApplyUpgrades(XComGameState NewGameState, XComGameState_Item ItemState)
// {
// 	local X2ItemTemplateManager ItemMan;

// 	ItemMan = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

// 	ItemState.ApplyWeaponUpgradeTemplate(X2WeaponUpgradeTemplate(ItemMan.FindItemTemplate('AimUpgrade_Adv')));
// 	ItemState.ApplyWeaponUpgradeTemplate(X2WeaponUpgradeTemplate(ItemMan.FindItemTemplate('MissDamageUpgrade_Adv')));
// 	ItemState.ApplyWeaponUpgradeTemplate(X2WeaponUpgradeTemplate(ItemMan.FindItemTemplate('ClipSizeUpgrade_Sup')));

// 	return true;
// }

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