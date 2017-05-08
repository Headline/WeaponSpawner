methodmap Weapon < KeyValues 
{
	public Weapon(const char[] classname, const float vec[3])
	{
		KeyValues kv = new KeyValues(classname);
		kv.SetVector(NULL_STRING, vec); 
		return view_as<Weapon>(kv);
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
