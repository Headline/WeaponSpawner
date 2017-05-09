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
	public bool Spawn()
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
