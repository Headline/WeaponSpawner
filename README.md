# WeaponSpawner
A simple SourceMod plugin to spawn weapons. Now dependency free!

### Installation
1) Add a database entry under "hl_weaponspawner" (View sample databases.cfg below.)
2) Move the plugin into your sourcemod/plugins/ folder

### Usage
Type !addweapons or sm_addweapons to open up the menu and aim where you'd like to place
the weapon!

### Sample Databases.cfg
```
"Databases"
{
	"driver_default"		"mysql"
	
	"hl_weaponspawner"
	{
		"driver"			"default"
		"host"				"your_host_here"
		"database"			"your_database_here"
		"user"				"your_username_here"
		"pass"				"your_password_here"
		//"timeout"			"0"
		"port"				"3306"
	}
	
	"storage-local"
	{
		"driver"			"sqlite"
		"database"			"sourcemod-local"
	}

	"clientprefs"
	{
		"driver"			"sqlite"
		"host"				"localhost"
		"database"			"clientprefs-sqlite"
		"user"				"root"
		"pass"				""
		//"timeout"			"0"
		//"port"			"0"
	}
}
```
