#pragma semicolon 1
#include <sourcemod>

#define VERSION 		"0.0.1"


new bool:g_bEnabled;

public Plugin:myinfo =
{
	name 		= "CounterFortress - Allow headshots for certain weapons",
	author 		= "Thrawn, XHunter",
	description = "",
	version 	= VERSION,
};

public OnPluginStart() {
	CreateConVar("sm_cf_headshots_version", VERSION, "", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
}

public OnConfigsExecuted() {
	g_bEnabled = true;
}

