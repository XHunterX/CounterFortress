#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define VERSION 	"0.0.1"
#define MDL_HEAD	"models/items/medkit_small.mdl"
//#define MDL_HEAD	"models/props_spytech/siren.mdl"

//#define MDL_HEAD	"models/props_gameplay/ball001.mdl"
new g_iPlayerHeadEntity[MAXPLAYERS+1];
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

	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath);
}

public OnConfigsExecuted() {
	g_bEnabled = true;
}

public OnMapStart() {
	PrecacheModel(MDL_HEAD, true);

	for(new iClient = 1; iClient <= MaxClients; iClient++) {
		g_iPlayerHeadEntity[iClient] = -1;
	}
}

public Event_PlayerSpawn(Handle:hEvent, String:strName[], bool:bDontBroadcast) {
	if(!g_bEnabled)return;
	new iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	AttachHead(iClient);
}

public Event_PlayerDeath(Handle:hEvent, String:strName[], bool:bDontBroadcast) {
	if(!g_bEnabled)return;
	new iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	RemoveHead(iClient);
}

public RemoveHead(iClient) {
	if(g_iPlayerHeadEntity[iClient] != -1 && IsValidEntity(g_iPlayerHeadEntity[iClient])) {
		RemoveEdict(g_iPlayerHeadEntity[iClient]);
		g_iPlayerHeadEntity[iClient] = -1;
	}
}

public AttachHead(iClient) {
	//if(IsValidEntity(g_iPlayerHeadEntity[iClient]))return;

	g_iPlayerHeadEntity[iClient] = CreateEntityByName("prop_physics_multiplayer");

	if(IsValidEntity(g_iPlayerHeadEntity[iClient])) {
		SetEntityModel(g_iPlayerHeadEntity[iClient], MDL_HEAD);
		SetEntProp(g_iPlayerHeadEntity[iClient], Prop_Data, "m_takedamage", 2);
		DispatchSpawn(g_iPlayerHeadEntity[iClient]);


		SetEntPropEnt(g_iPlayerHeadEntity[iClient], Prop_Send, "m_hOwnerEntity", iClient);
		SetEntProp(g_iPlayerHeadEntity[iClient], Prop_Data, "m_takedamage", 2);
		//SetEntPropEnt(g_iBall, Prop_Data, "m_hLastAttacker", iCreator);

		//Use the balls VPhysics for collisions
		SetEntProp(g_iPlayerHeadEntity[iClient], Prop_Data, "m_nSolidType", 6 );
		SetEntProp(g_iPlayerHeadEntity[iClient], Prop_Send, "m_nSolidType", 6 );

		//Only detect bullet/damage collisions
		SetEntProp(g_iPlayerHeadEntity[iClient], Prop_Data, "m_CollisionGroup", 2);
		SetEntProp(g_iPlayerHeadEntity[iClient], Prop_Send, "m_CollisionGroup", 2);

		//Set the shield's health
		SetEntProp(g_iPlayerHeadEntity[iClient], Prop_Data, "m_iMaxHealth", 150);
		SetEntProp(g_iPlayerHeadEntity[iClient], Prop_Data, "m_iHealth", 150);

		AcceptEntityInput(g_iPlayerHeadEntity[iClient], "DisableCollision" );
		AcceptEntityInput(g_iPlayerHeadEntity[iClient], "EnableCollision" );

		DispatchKeyValue(g_iPlayerHeadEntity[iClient], "disableshadows", "1");
		DispatchKeyValue(g_iPlayerHeadEntity[iClient], "physicsmode", "1");
		DispatchKeyValue(g_iPlayerHeadEntity[iClient], "spawnflags", "256");

		new String:playerName[128];
		Format(playerName, sizeof(playerName), "target%i", iClient);
		DispatchKeyValue(iClient, "targetname", playerName);

		//Parent the shield to the player
		SetVariantString(playerName);
		AcceptEntityInput(g_iPlayerHeadEntity[iClient], "SetParent");

		//Attach the shield to the 'flag'
		SetVariantString("head");
		AcceptEntityInput(g_iPlayerHeadEntity[iClient], "SetParentAttachment");

		new Float:vPos[3];
		GetEntPropVector(g_iPlayerHeadEntity[iClient], Prop_Send, "m_vecOrigin", vPos);
		vPos[2] -= 20.0;
		TeleportEntity(g_iPlayerHeadEntity[iClient], vPos, NULL_VECTOR, NULL_VECTOR);

		SDKHook(g_iPlayerHeadEntity[iClient], SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype) {
	if(attacker == 0)return Plugin_Continue;
	new iVictim = GetEntPropEnt(victim, Prop_Send, "m_hOwnerEntity");

	//You cant shoot yourself in the head in our game :[
	if(attacker == iVictim)return Plugin_Continue;

	//Check if player got hit by a bullet, inflictor class must be 'player'
	new String:sWeapon[32];
	GetEdictClassname(inflictor, sWeapon, sizeof(sWeapon));

	if(inflictor > 0 && inflictor <= MaxClients+1 && IsClientInGame(inflictor)) {
		//we are taking bullet damage
		PrintToChat(attacker, "HEADSHOT! %.2f Damage to %N", damage, iVictim);
	}

	//dont really do damage so the prop wont be destroyed
	damage *= 0.0;
	return Plugin_Changed;
}