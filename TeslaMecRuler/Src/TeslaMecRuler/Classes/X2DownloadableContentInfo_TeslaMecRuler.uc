class X2DownloadableContentInfo_TeslaMecRuler extends X2DownloadableContentInfo;

// =============
// DLC HOOKS
// =============

static event OnLoadedSavedGame()
{
	local XComGameState NewGameState;
	
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("TeslaMecRuler: Initializing for existing campaign");
	InitRulerForExistingCampaign(NewGameState, 'MecRuler');

	`XCOMHISTORY.AddGameStateToHistory(NewGameState);
}

static event OnPostTemplatesCreated()
{
	// local array<name> Chars;

	TryAddToExistingRulerEncounterBuckets('MecRuler');
	AddNewUnitsAsSupportedFollowers('TR_AdventSpark', 'AdvMEC_M2');

	// Unfortunately too buggy as modmakers are not consistent with flags in X2CharacterTemplate
	// Chars.AddItem('MecRuler');
	// Chars.AddItem('TR_AdventSpark');
	// AddRoboticUnitsAsSupportedFollowersTo(Chars);
}

// =============
// HELPERS
// =============

// Note: Copied from Children of the King 2.0
// On a BEST-EFFORT BASIS, attempt to add the ruler `RulerTemplateName` to existing encounter buckets.
// EncounterListName will be used to add to the bucket, defaulting to `LIST_RULER_<RulerTemplateName>`.
// It is recommended that this be called once for your custom ruler in `OnPostTemplatesCreated`.
static function TryAddToExistingRulerEncounterBuckets(name RulerTemplateName, optional name EncounterListName = '')
{
	local int i, pos;
	local ConditionalEncounter Encounter;
	local XComTacticalMissionManager MissionManager;

	i = class'XComGameState_AlienRulerManager'.default.AlienRulerTemplates.Find('AlienRulerTemplateName', RulerTemplateName);

	if (i == INDEX_NONE)
	{
		`log("Skipping " $ RulerTemplateName $ " as it is not a known ruler.",, 'TryAddToExistingRulerEncounterBuckets');
		return;
	}

	if (EncounterListName == '')
	{
		EncounterListName = name("LIST_RULER_" $ RulerTemplateName);
	}

	Encounter.EncounterID = EncounterListName;
	Encounter.IncludeTacticalTag = class'XComGameState_AlienRulerManager'.default.AlienRulerTemplates[i].ActiveTacticalTag;
	Encounter.ExcludeTacticalTag = class'XComGameState_AlienRulerManager'.default.AlienRulerTemplates[i].DeadTacticalTag;

	MissionManager = `TACTICALMISSIONMGR;
	for (i = 0; i < MissionManager.EncounterBuckets.Length; i++)
	{
		pos = MatchAlienRulerBucket(MissionManager.EncounterBuckets[i]);

		if (pos != INDEX_NONE)
		{
			MissionManager.EncounterBuckets[i].EncounterIDs.InsertItem(pos, Encounter);
			`log("Inserted "$ Encounter.EncounterID $ " at position " $ pos $ " into bucket " $ MissionManager.EncounterBuckets[i].EncounterBucketID,, 'TryAddToExistingRulerEncounterBuckets');
		}
	}
}

// Identify an alien ruler bucket. This function recognizes an alien ruler bucket by
// matching a positive number of ruler list encounters (with an IncludeTacticalTag and an ExcludeTacticalTag)
// and any number of arbitrary encounters after that. Returns INDEX_NONE if this bucket is not an alien ruler
// bucket, otherwise returns the desired insertion position.
static function int MatchAlienRulerBucket(const EncounterBucket Bucket)
{
	local int idx, j;

	for (idx = 0; idx < Bucket.EncounterIDs.Length; idx++)
	{
		// Test whether this bucket references an Alien Ruler with its Dead/Alive tags.
		j = class'XComGameState_AlienRulerManager'.default.AlienRulerTemplates.Find('ActiveTacticalTag', Bucket.EncounterIDs[idx].IncludeTacticalTag);
		if (j == INDEX_NONE ||  class'XComGameState_AlienRulerManager'.default.AlienRulerTemplates[j].DeadTacticalTag != Bucket.EncounterIDs[idx].ExcludeTacticalTag)
		{
			// If not, break, we're done here.
			break;
		}
	}

	// idx now is the index where the encounters stopped referencing rulers.
	// If idx == 0, there were no rulers
	return (idx == 0) ? INDEX_NONE : idx;
}

static protected function InitRulerForExistingCampaign (XComGameState NewGameState, name RulerTemplateName)
{
	local XComGameState_AlienRulerManager RulerManager;
	local X2CharacterTemplateManager CharMgr;
	local X2CharacterTemplate CharTemplate;
	local XComGameState_Unit UnitState;

	RulerManager = XComGameState_AlienRulerManager(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_AlienRulerManager'));
	if (RulerManager == none) return; // Either DLC2 not loaded, or added to this campaign together with this mod. In latter case, XComGameState_AlienRulerManager will do everything for us
	if (RulerManager.GetAlienRulerReference(RulerTemplateName).ObjectID > 0) return; // DLC2 was added to this campaign together with this mod, so XComGameState_AlienRulerManager did everything for us

	// We are ready to create the ruler
	RulerManager = XComGameState_AlienRulerManager(NewGameState.ModifyStateObject(class'XComGameState_AlienRulerManager', RulerManager.ObjectID));

	// Copied from XComGameState_AlienRulerManager::CreateAlienRulers
	CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
	CharTemplate = CharMgr.FindCharacterTemplate(RulerTemplateName);
	UnitState = CharTemplate.CreateInstanceFromTemplate(NewGameState);
	UnitState.SetUnitFloatValue('NumEscapes', 0.0f, eCleanup_Never);
	UnitState.SetUnitFloatValue('NumAppearances', 0.0f, eCleanup_Never);
	UnitState.bIsSpecial = true;
	UnitState.RemoveStateFromPlay(); // Do not process the ruler states in tactical
	UnitState.ApplyFirstTimeStatModifiers(); // Update the Ruler HP values to work with Beta Strike
	RulerManager.AllAlienRulers.AddItem(UnitState.GetReference());
	class'X2Helpers_DLC_Day60'.static.UpdateRulerEscapeHealth(UnitState);
}

// Add units from this mod (`CharToAdd`) to other units where `SimilarChar` is also a supported follower
// Serves as a way to add a unit from this mod to other mod added units as supported follower
static function AddNewUnitsAsSupportedFollowers(name CharToAdd, name SimilarChar)
{
	local X2CharacterTemplateManager CharMan;
	local X2CharacterTemplate CharTemplate;
	local array<X2DataTemplate> DataTemplates;
	local X2DataTemplate DataTemplate, DataTemplateDiff;

	CharMan = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	foreach CharMan.IterateTemplates(DataTemplate)
	{
		CharMan.FindDataTemplateAllDifficulties(DataTemplate.DataName, DataTemplates);

		foreach DataTemplates(DataTemplateDiff)
		{
			CharTemplate = X2CharacterTemplate(DataTemplateDiff);
			if (CharTemplate == none) continue;

			if (CharTemplate.SupportedFollowers.Find(SimilarChar) == INDEX_NONE)
				continue;

			CharTemplate.SupportedFollowers.AddItem(CharToAdd);
			// `LOG("Added " $CharToAdd @"as supported followers to " $CharTemplate, true, 'TMRDEBUG');
		}
	}
}

// Adds robotic units to `CharsNeedSupportedFollowers` as supported followers
// Serves as a way to add robotic units in the game (including mod added ones) to units in this mod as
// supported followers
static function AddRoboticUnitsAsSupportedFollowersTo(array<name> CharsNeedSupportedFollowers)
{
	local X2CharacterTemplateManager CharMan;
	local X2CharacterTemplate CharTemplate, CharLacksSupportedFollowers;
	local array<X2DataTemplate> DataTemplates;
	local X2DataTemplate DataTemplate, DataTemplateDiff;
	local array<X2CharacterTemplate> CharsLackSupportedFollowers;
	local name CharName;

	CharMan = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

	foreach CharsNeedSupportedFollowers(CharName)
	{
		CharMan.FindDataTemplateAllDifficulties(CharName, DataTemplates);

		foreach DataTemplates(DataTemplateDiff)
		{
			CharTemplate = X2CharacterTemplate(DataTemplateDiff);
			if (CharTemplate != none)
			{
				CharsLackSupportedFollowers.AddItem(CharTemplate);
			}
		}
	}

	foreach CharMan.IterateTemplates(DataTemplate)
	{
		CharTemplate = X2CharacterTemplate(DataTemplate);
		if (CharTemplate == none) continue;

		if (CharTemplate.bIsRobotic && !CharTemplate.bIsTurret && CharTemplate.bAllowSpawnFromATT && !CharTemplate.bIsSoldier
			&& !CharTemplate.bIsCivilian
			&& CharTemplate.Abilities.Find('ChallengeMode_Hack') == INDEX_NONE
			&& CharTemplate.TemplateAvailability == class'X2DataTemplate'.const.BITFIELD_GAMEAREA_Singleplayer)
		{
			foreach CharsLackSupportedFollowers(CharLacksSupportedFollowers)
			{
				CharLacksSupportedFollowers.SupportedFollowers.AddItem(CharTemplate.DataName);
				`LOG("Added " $CharTemplate.DataName @"as a supported follower to " $CharLacksSupportedFollowers.DataName, true, 'TMRDEBUG');
			}
		}
	}
}

// =============
// CONSOLE COMMANDS
// =============

exec function TMR_PrintRulerHP(name RulerTemplateName)
{
	local XComGameStateHistory History;
	local XComGameState_AlienRulerManager RulerMgr;
	local XComGameState_Unit UnitState;
	local StateObjectReference RulerRef;

	History = `XCOMHISTORY;
	RulerMgr = XComGameState_AlienRulerManager(History.GetSingleGameStateObjectForClass(class'XComGameState_AlienRulerManager'));
	RulerRef = RulerMgr.GetAlienRulerReference(RulerTemplateName);

	if(RulerRef.ObjectID != 0)
	{
		UnitState = XComGameState_Unit(History.GetGameStateForObjectID(RulerRef.ObjectID));
		class'Helpers'.static.OutputMsg(UnitState.GetMyTemplateName() @"current HP:" @UnitState.GetCurrentStat(eStat_HP));
	}
	else
	{
		class'Helpers'.static.OutputMsg("RulerTemplateName is invalid.\nValid Entries: ViperKing, BerserkerQueen, ArchonKing");
	}
}