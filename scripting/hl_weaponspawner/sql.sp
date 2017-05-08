void LoadSQL(Database database, ArrayList array)
{
	char query[300];
	Format(query, sizeof(query), "SELECT * FROM hl_weaponspawner WHERE map = \"%s\"", GetMapName());
	database.Query(SQLCallback_LoadWeapons, query, array);
}

public void SQLCallback_LoadWeapons(Database db, DBResultSet results, const char[] error, ArrayList array)
{
	if (db == null)
	{
		SetDB();
	}
	
	if (results == null)
	{
		LogError(error);
		return;
	}
	
	while (results.FetchRow())
	{
		float vec[3];
		char className[32];
		
		vec[0] = results.FetchFloat(2);
		vec[1] = results.FetchFloat(3);
		vec[2] = results.FetchFloat(4);
	
		results.FetchString(5, className, sizeof(className));
		
		array.Push(new Weapon(className, vec));
	}
}


void AddWeaponToSQL(Weapon weapon, Database database)
{
	char classname[32];
	float vec[3];
	
	weapon.GetSectionName(classname, sizeof(classname));
	weapon.GetVector(NULL_STRING, vec);
	
	char query[300];
	Format(query, sizeof(query), "INSERT INTO hl_weaponspawner (map, classname, x, y, z) VALUES(\"%s\", \"%s\", %f, %f, %f)", GetMapName(), classname, vec[0], vec[1], vec[2]);

	database.Query(SQLCallback_Void, query);
}

void SetDB()
{
	if (g_hDatabase == null)
	{
		Database.Connect(SQLCallback_Connect, "hl_weaponspawner");
	}
}

public void SQLCallback_Connect(Database db, const char[] error, any data)
{
	if (db == null)
	{
		SetDB();
	}
	else
	{
		g_hDatabase = db;		

		g_hDatabase.Query(SQLCallback_Void, "CREATE TABLE IF NOT EXISTS `hl_weaponspawner` (`id` int(20) NOT NULL AUTO_INCREMENT, `map` varchar(32) NOT NULL, `x` float(32) NOT NULL, `y` float(32) NOT NULL, `z` float(32) NOT NULL, `classname` varchar(32) NOT NULL, PRIMARY KEY (`id`)) DEFAULT CHARSET=utf8 AUTO_INCREMENT=1", 1);
	}
}

public void SQLCallback_Void(Database db, DBResultSet results, const char[] error, int data)
{
	if (db == null)
	{
		LogError("Error (%i): %s", data, error);
	}
}
