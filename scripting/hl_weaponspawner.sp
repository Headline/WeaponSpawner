#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

ArrayList list;
Database g_hDatabase;

char weapons[36][32] = {
	"weapon_ak47", "weapon_aug", "weapon_bizon", "weapon_deagle", "weapon_decoy", "weapon_elite", "weapon_famas", "weapon_fiveseven", "weapon_flashbang",
	"weapon_g3sg1", "weapon_galilar", "weapon_glock", "weapon_hegrenade", "weapon_hkp2000", "weapon_incgrenade", "weapon_knife", "weapon_m249", "weapon_m4a1",
	"weapon_mac10", "weapon_mag7", "weapon_molotov", "weapon_mp7", "weapon_mp9", "weapon_negev", "weapon_nova", "weapon_p250", "weapon_p90", "weapon_sawedoff",
	"weapon_scar20", "weapon_sg556", "weapon_smokegrenade", "weapon_ssg08", "weapon_taser", "weapon_tec9", "weapon_ump45", "weapon_xm1014"
};

#include "hl_weaponspawner/weapon.sp"
#include "hl_weaponspawner/sql.sp"

public void OnPluginStart()
{
	SetDB();
	
	HookEvent("round_start", Event_RoundStart);
	
	RegAdminCmd("sm_addweapons", Command_AddWeapons, ADMFLAG_SLAY, "A command to add map weapons");
	RegAdminCmd("sm_addweapon", Command_AddWeapons, ADMFLAG_SLAY, "A command to add map weapons");
}

public void OnMapStart()
{
	if (list == null)
	{
		list = new ArrayList();
	}
	else
	{
		DisposeListElements(list);
		list.Clear();
	}
	
	SetDB();
	
	CreateTimer(0.5, Timer_WaitToLoad, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_WaitToLoad(Handle timer)
{
	if (g_hDatabase != null)
	{
		LoadSQL(g_hDatabase, list);
		return Plugin_Stop;
	}
	else
	{
		return Plugin_Continue;
	}
}

public Action Command_AddWeapons(int client, int args)
{
	if (!IsClientInGame(client))
	{
		ReplyToCommand(client, "[SM] You must be in game to use this command!");
		return Plugin_Handled;
	}
	if (args != 0)
	{
		ReplyToCommand(client, "[SM] Usage: sm_addweapons");
		return Plugin_Handled;
	}
	
	OpenWeaponMenu(client);
	return Plugin_Handled;
}

void OpenWeaponMenu(int client)
{
	Menu menu = CreateMenu(WeaponMenu_Callback, MenuAction_Select | MenuAction_End | MenuAction_DisplayItem | MenuAction_Cancel);
	SetMenuTitle(menu, "Select Weapon: ");

	for (int i = 0; i < sizeof(weapons); i++)
	{
		menu.AddItem(weapons[i], weapons[i]);
	}

	menu.ExitBackButton = false;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int WeaponMenu_Callback(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char classname[32];
			float vec[3];
			GetMenuItem(menu, param2, classname, sizeof(classname));
			vec = GetClientAimPosition(param1);
			
			Weapon weapon = new Weapon(classname, vec);
			AddWeaponToSQL(weapon, g_hDatabase);
			SpawnWeapon(weapon);
			list.Push(weapon);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	SpawnWeapons(list);
}

float[3] GetClientAimPosition(int client) 
{ 
	float start[3], angle[3], end[3]; 
	
	GetClientEyePosition(client, start); 
	GetClientEyeAngles(client, angle); 
	
	TR_TraceRayFilter(start, angle, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer); 
	
	if (TR_DidHit(null)) 
	{ 
		TR_GetEndPosition(end, null); 
	}
	
	return end;
} 

public bool TraceEntityFilterPlayer(int entity, int contentsMask)  
{ 
	return entity > MaxClients; 
} 

void SpawnWeapons(ArrayList array)
{
	for (int i = 0; i < array.Length; i++)
	{
		SpawnWeapon(array.Get(i));
	}
}

void SpawnWeapon(Weapon weapon)
{
	char classname[32];
	float vec[3];
	int entity;
	
	weapon.GetSectionName(classname, sizeof(classname));
	weapon.GetVector(NULL_STRING, vec);
	
	entity = CreateEntityByName(classname);
	if (entity != -1)
	{
		TeleportEntity(entity, vec, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(entity);
	}
	
}

char[] GetMapName()
{
	char currentMap[32];
	GetCurrentMap(currentMap, sizeof(currentMap));
	return currentMap;
}

void DisposeListElements(ArrayList array)
{
	Weapon weap;
	for (int i = 0; i < array.Length; i++)
	{
		weap = array.Get(i);
		delete weap;
	}
}
