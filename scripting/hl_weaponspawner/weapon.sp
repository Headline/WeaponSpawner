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
 
methodmap Weapon < KeyValues 
{

	/* Methods */
	public void GetVector(float[3] vec)
	{
		this.GetVector(NULL_STRING, vec);
	}
	
	public void GetClassname(char[] buffer, int maxlength)
	{
		this.GetSectionName(buffer, maxlength);
	}
	
	// DESCRIPTION: Spawns a weapon using it's vector and classname
	// POSTCONDITION: Returns true if sucessfully spawned
	public bool Spawn(bool csgoitems)
	{
		char classname[32];
		float vec[3];
		int entity;
		
		this.GetVector(vec);
		this.GetClassname(classname, sizeof(classname));
		
		entity = CreateEntityByName(classname);
		if (entity != -1)
		{
			TeleportEntity(entity, vec, NULL_VECTOR, NULL_VECTOR);
			if (csgoitems)
			{
				SetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex", CSGO_GetItemDefinitionIndexByName(classname));
			}
			DispatchSpawn(entity);
			return true;
		}
		else
		{
			return false;
		}
	}
	
	/* Constructor */
	public Weapon(const char[] classname, const float vec[3])
	{
		KeyValues kv = new KeyValues(classname);
		kv.SetVector(NULL_STRING, vec); 
		return view_as<Weapon>(kv);
	}
	
	/* Static Methods */
	public static void SpawnWeapons(ArrayList array, bool csgoItems)
	{
		Weapon weapon;
		for (int i = 0; i < array.Length; i++)
		{
			weapon = array.Get(i);
			weapon.Spawn(csgoItems);
		}
	}
	
	public static Weapon EntityToWeapon(int entity)
	{
		if (!IsValidEntity(entity))
		{
			return null;
		}
		else
		{
			char classname[64];
			float vec[3];

			GetEntityClassname(entity, classname, sizeof(classname));
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", position);
			
			return (new Weapon(classname, vec));
		}
	}
}
