/*  [CS:GO/CS:S] Weapon Spawner
 *
 *  Copyright (C) 2017 Michael Flaherty // michaelwflaherty.com // michaelwflaherty@me.com
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */
 
#include <sourcemod>
#include <sdktools>
#include <csgo_items>

#pragma semicolon 1
#pragma newdecls required

ArrayList list;
Database g_hDatabase;

char weapons[37][32] = {
	"weapon_ak47", "weapon_aug", "weapon_bizon", "weapon_deagle", "weapon_decoy", "weapon_elite", "weapon_famas", "weapon_fiveseven", "weapon_flashbang",
	"weapon_g3sg1", "weapon_galilar", "weapon_glock", "weapon_hegrenade", "weapon_hkp2000", "weapon_incgrenade", "weapon_knife", "weapon_m249", "weapon_m4a1",
	"weapon_mac10", "weapon_mag7", "weapon_molotov", "weapon_mp7", "weapon_mp9", "weapon_negev", "weapon_nova", "weapon_p250", "weapon_p90", "weapon_sawedoff",
	"weapon_scar20", "weapon_sg556", "weapon_smokegrenade", "weapon_ssg08", "weapon_taser", "weapon_tec9", "weapon_ump45", "weapon_xm1014", "weapon_mp5sd"
};

#include "hl_weaponspawner/weapon.sp"
#include "hl_weaponspawner/sql.sp"

public Plugin myinfo =
{
	name = "[CS:GO/CS:S] Weapon Spawner",
	author = "Headline",
	description = "Allow server operators to add weapons to maps who have none",
	version = "1.0",
	url = "http://michaelwflaherty.com"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	MarkNativeAsOptional("CSGO_GetItemDefinitionIndexByName");

	return APLRes_Success;
}

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

void OpenWeaponMenu(int client, int item = 0)
{
	Menu menu = CreateMenu(WeaponMenu_Callback, MenuAction_Select | MenuAction_End | MenuAction_DisplayItem | MenuAction_Cancel);
	SetMenuTitle(menu, "Select Weapon: ");

	for (int i = 0; i < sizeof(weapons); i++)
	{
		menu.AddItem(weapons[i], weapons[i]);
	}

	menu.ExitBackButton = false;
	menu.DisplayAt(client, item, MENU_TIME_FOREVER);
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
			
			bool csgoItemsExists = GetFeatureStatus(FeatureType_Native, "CSGO_GetItemDefinitionIndexByName") == FeatureStatus_Available;
			weapon.Spawn(csgoItemsExists);
			list.Push(weapon);
			OpenWeaponMenu(param1, menu.Selection);
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	bool csgoItemsExists = GetFeatureStatus(FeatureType_Native, "CSGO_GetItemDefinitionIndexByName") == FeatureStatus_Available;
	Weapon.SpawnWeapons(list, csgoItemsExists);
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
