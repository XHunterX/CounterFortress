#include <sourcemod>

public Plugin:myinfo = 
{
	name = "CF.Weapons",
	author = "XHunter",
	description = "CounterFortress weapons core",
	version = "1.0",
	url = "<- URL ->"
}

#define STRING_SIZE		128
#define MAX_WEAPONS		32
#define MAX_ATTRIBUTES	16

enum Attribute
{
	id,
	fValue
}

enum Weapon
{
	id,
	String:name[STRING_SIZE],
	prize,
	nAttributes
}

new g_Weapons[MAX_WEAPONS][Weapon];
new g_Attributes[MAX_WEAPONS][MAX_ATTRIBUTES][Attribute];

public GetWeaponAttributeId(weapId, attrId)
{
	if (weapId < MAX_WEAPONS && attrId < MAX_ATTRIBUTES)
		return g_Attributes[weapId][attrId][id];
	return -1;
}

public GetWeaponAttributeValue(weapId, attrId)
{
	if (weapId < MAX_WEAPONS && attrId < MAX_ATTRIBUTES)
		return g_Attributes[weapId][attrId][fValue];
	return -1;
}

public SetWeaponAttributeId(weapId, attrId, newId)
{
	if (weapId < MAX_WEAPONS && attrId < MAX_ATTRIBUTES)
		g_Attributes[weapId][attrId][id] = newId;
}

public SetWeaponAttributeValue(weapId, attrId, newValue)
{
	if (weapId < MAX_WEAPONS && attrId < MAX_ATTRIBUTES)
		g_Attributes[weapId][attrId][fValue] = newValue;
}

public GetWeaponId(weapId)
{
	if (weapId < MAX_WEAPONS)
		return g_Weapons[weapId][id];
	return -1;
}

public SetWeaponId(weapId, newId)
{
	if (weapId < MAX_WEAPONS)
		g_Weapons[weapId][id] = newId;
}

public GetWeaponName(weapId)
{
	if (weapId < MAX_WEAPONS)
		return g_Weapons[weapId][name];
	return -1;
}

public SetWeaponName(weapId, const String:newName[])
{
	if (weapId < MAX_WEAPONS)
		strcopy(g_Weapons[weapId][name], STRING_SIZE, newName)	
}

public GetWeaponPrize(weapId)
{
	if (weapId < MAX_WEAPONS)
		return g_Weapons[weapId][prize];
	return -1;
}

public SetWeaponPrize(weapId, newPrize)
{
	if (weapId < MAX_WEAPONS)
		g_Weapons[weapId][prize] = newPrize;
}


public GetWeaponNumAttributes(weapId)
{
	if (weapId < MAX_WEAPONS)
		return g_Weapons[weapId][nAttributes];
	return -1;
}

public SetWeaponNumAttributes(weapId, newNumAttr)
{
	if (weapId < MAX_WEAPONS)
		g_Weapons[weapId][nAttributes] = newNumAttr;
}
