methodmap Weapon < KeyValues 
{
	/* Constructor */
	public Weapon(const char[] classname, const float vec[3])
	{
		KeyValues kv = new KeyValues(classname);
		kv.SetVector(NULL_STRING, vec); 
		return view_as<Weapon>(kv);
	}
	
	/* Methods */
	public float[3] GetVec()
	{
		float vec[3];
		this.GetVector(NULL_STRING, vec);
		return vec;
	}
	
	public void GetClassname(char[] buffer, int maxlength)
	{
		this.GetSectionName(buffer, maxlength);
	}
	
	// DESCRIPTION: Spawns a weapon using it's vector and classname
	// POSTCONDITION: Returns true if sucessfully spawned
	public bool Spawn()
	{
		char classname[32];
		flat vec[3];
		int entity;
		
		vec = this.GetVec();
		this.GetClassname(classname, sizeof(classname));
		
		entity = CreateEntityByName(classname);
		if (entity != -1)
		{
			TeleportEntity(entity, vec, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(entity);
			return true;
		}
		else
		{
			return false;
		}
	}
	
	/* Static Methods */
	
	public static void SpawnWeapons(ArrayList array)
	{
		Weapon weapon;
		for (int i = 0; i < array.Length; i++)
		{
			weapon = array.Get(i);
			weapon.Spawn();
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
