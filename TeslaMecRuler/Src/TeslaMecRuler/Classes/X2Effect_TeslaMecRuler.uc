class X2Effect_TeslaMecRuler extends X2Effect_Persistent;

var int ArmorRepairAmount;
var int MaxArmorRepairAmount;
var name ArmorRepairedName;
var float BSDamageReductionPrcnt;
var float MeleeDamageReductionPrcnt;

var localized string ArmorRepairedMessage;

function bool RegenerationTicked(X2Effect_Persistent PersistentEffect, const out EffectAppliedData ApplyEffectParameters, XComGameState_Effect kNewEffectState, XComGameState NewGameState, bool FirstApplication)
{
	local XComGameState_Unit OldTargetState, NewTargetState;
	local UnitValue ArmorRepaired;
	local int AmountToRepair, Healed;
	
	OldTargetState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	if (OldTargetState.Shredded < 1) return false;

	if (ArmorRepairedName != '' && MaxArmorRepairAmount > 0)
	{
		OldTargetState.GetUnitValue(ArmorRepairedName, ArmorRepaired);

		// If the unit has already been healed the maximum number of times, do not regen
		if (ArmorRepaired.fValue >= MaxArmorRepairAmount)
		{
			return false;
		}
		else
		{
			// Ensure the unit is not healed for more than the maximum allowed amount
			AmountToRepair = min(ArmorRepairAmount, (MaxArmorRepairAmount - ArmorRepaired.fValue));
		}
	}
	else
	{
		// If no value tracking for health regenerated is set, heal for the default amount
		AmountToRepair = ArmorRepairAmount;
	}	

	// Perform the heal
	NewTargetState = XComGameState_Unit(NewGameState.ModifyStateObject(OldTargetState.Class, OldTargetState.ObjectID));
	NewTargetState.Shredded -= min(AmountToRepair, OldTargetState.Shredded);

	// if (EventToTriggerOnHeal != '')
	// {
	// 	`XEVENTMGR.TriggerEvent(EventToTriggerOnHeal, NewTargetState, NewTargetState, NewGameState);
	// }

	// If this health regen is being tracked, save how much the unit was healed
	if (ArmorRepairedName != '')
	{
		Healed = NewTargetState.Shredded - OldTargetState.Shredded;
		if (Healed > 0)
		{
			NewTargetState.SetUnitFloatValue(ArmorRepairedName, ArmorRepaired.fValue + Healed, eCleanup_BeginTactical);
		}
	}

	return false;
}

simulated function AddX2ActionsForVisualization_Tick(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const int TickIndex, XComGameState_Effect EffectState)
{
	local XComGameState_Unit OldUnit, NewUnit;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local int Healed;
	local string Msg;

	OldUnit = XComGameState_Unit(ActionMetadata.StateObject_OldState);
	NewUnit = XComGameState_Unit(ActionMetadata.StateObject_NewState);

	Healed = NewUnit.Shredded - OldUnit.Shredded;
	
	if( Healed > 0 )
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		Msg = Repl(default.ArmorRepairedMessage, "<Heal/>", Healed);
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, Msg, '', eColor_Good);
	}
}

function int GetDefendingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, X2Effect_ApplyWeaponDamage WeaponDamageEffect, optional XComGameState NewGameState)
{ 
	local XComGameState_Item Weapon;
	local XComGameStateHistory History;
	local X2AmmoTemplate AmmoTemplate;
	local AmmoDamageModifier DamageModifier;
	local int DamageMod;

	if (BSDamageReductionPrcnt > 0)
	{
		if (AppliedData.AbilityResultContext.HitResult == eHit_Success || AppliedData.AbilityResultContext.HitResult == eHit_Crit)
		{
			History = `XCOMHISTORY;

			Weapon = AbilityState.GetSourceWeapon();
			AmmoTemplate = X2AmmoTemplate(XComGameState_Item(History.GetGameStateForObjectID(Weapon.LoadedAmmo.ObjectID)).GetMyTemplate());

			if (AmmoTemplate != none)
			{
				foreach AmmoTemplate.DamageModifiers(DamageModifier)
				{
					if (X2Condition_UnitProperty(DamageModifier.TargetCondition).ExcludeOrganic
						&& X2Condition_UnitProperty(DamageModifier.TargetCondition).IncludeWeakAgainstTechLikeRobot)
					{
						DamageMod -= round(float(DamageModifier.DamageValue.Damage) * BSDamageReductionPrcnt);
					}
				}

				DamageMod = min(DamageMod, 0);
			}
		}
	}

	if(MeleeDamageReductionPrcnt > 0)
	{
		if (AppliedData.AbilityResultContext.HitResult == eHit_Success || AppliedData.AbilityResultContext.HitResult == eHit_Crit)
		{
			Weapon = AbilityState.GetSourceWeapon();
			if (Weapon != none && X2WeaponTemplate(Weapon.GetMyTemplate()).BaseDamage.DamageType == 'Melee')
			{
				DamageMod -= round(float(CurrentDamage) * MeleeDamageReductionPrcnt);
			}
		}
	}

	return DamageMod;
}

defaultproperties
{
	EffectName="MecRulerArmorRepair"
	EffectTickedFn=RegenerationTicked
}
