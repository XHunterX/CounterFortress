#include <sourcemod>
#include "cf.bomb.inc"

public Plugin:myinfo = 
{
	name = "CF.Bomb",
	author = "XHunter",
	description = "CounterFortress Bomb core",
	version = "1.0",
	url = "<- URL ->"
}

#define INVALID_CLIENT -1
#define INVALID any:-1

enum Bomb
{
	index,
	carrier,
	owner,
	BombStatus:status,
	BombProcess:process,
	Float:explodeTime,
	Float:defuseTime,
	Float:plantTime,
	Float:nextExplode,
	Float:explodeTicks,
	Float:processTicks,
	Float:nextProcess
}

new g_Bomb[Bomb];

new Handle:g_hForwardBombExplodePre;
new Handle:g_hForwardBombExplodePost;

OnPluginStart()
{
	g_hForwardBombExplodePre = CreateGlobalForward("CF_OnBombExplodePre", ET_Event);
	g_hForwardBombExplodePost = CreateGlobalForward("CF_OnBombExplodePost", ET_Ignore);
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	RegPluginLibrary("cf.bomb");

	CreateNative("CF_GetBombStatus", Native_GetBombStatus);
	
	return APLRes_Success;
}

public BombOnGameFrame()
{
	if (g_Bomb[status] != STATUS_NONE)
	{
		switch (g_Bomb[status])
		{
			case STATUS_PLANTED:
			{
				if (GetEngineTime() >= g_Bomb[nextExplode])
				{
					Call_StartForward(g_hForwardBombExplodePre);
					new result;
					Call_Finish(result);
					
					if (result > 1)
						return;
					
					ExplodeBomb();
					
					Call_StartForward(g_hForwardBombExplodePost);
					Call_Finish();
				}
			}
		}
		
		if (g_Bomb[process] != PROCESS_NONE)
		{
			if (GetEngineTime() >= g_Bomb[nextProcess])
			{
				switch (g_Bomb[process])
				{
					case PROCESS_PLANTING:
					{
						PlantBomb();
					}
					case PROCESS_DEFUSING:
					{
						DefuseBomb();
					}
				}
			}
		}
	}
}

public Native_GetBombStatus(Handle:hPlugin, iNumParams)
{
	return _:g_Bomb[status];
}

public SetBombStatus(BombStatus:newStatus)
{
	g_Bomb[status] = newStatus;
}

public BombProcess:GetBombProcess()
{
	return g_Bomb[process];
}

public SetBombProcess(BombProcess:newProcess)
{
	g_Bomb[process] = newProcess;
}

public Float:GetExplodeTime()
{
	return g_Bomb[explodeTime];
}

public SetExplodeTime(Float:newTime)
{
	g_Bomb[explodeTime] = newTime;
}

public Float:GetDefuseTime()
{
	return g_Bomb[defuseTime];
}

public SetDefuseTime(Float:newTime)
{
	g_Bomb[defuseTime] = newTime;
}

public Float:GetPlantTime()
{
	return g_Bomb[plantTime];//
}

public SetPlantTime(Float:newTime)
{
	g_Bomb[plantTime] = newTime;
}

public Float:GetExplodeTicks()
{
	return g_Bomb[explodeTicks];
}

public SetExplodeTicks(Float:newTime)
{
	g_Bomb[explodeTicks] = newTime;
}

public Float:GetProcessTicks()
{
	return g_Bomb[processTicks];
}

public SetProcessTicks(Float:newTime)
{
	g_Bomb[processTicks] = newTime;
}

public GiveBomb(client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && (g_Bomb[status] == STATUS_DROPPED || STATUS_CARRIED))
	{
		g_Bomb[carrier] = client;
		g_Bomb[status] = STATUS_CARRIED;
	}
}

public Action:ExplodeBomb()
{
	g_Bomb[owner] = g_Bomb[carrier];
	g_Bomb[status] = STATUS_EXPLODED;
	g_Bomb[process] = PROCESS_NONE;
}

public Action:DefuseBomb()
{
	g_Bomb[status] = STATUS_DEFUSED;
	g_Bomb[process] = PROCESS_NONE;
}

public Action:PlantBomb()
{
	g_Bomb[status] = STATUS_PLANTED;
	g_Bomb[process] = PROCESS_NONE;
	g_Bomb[nextExplode]  = GetEngineTime() + g_Bomb[explodeTime];
}

public Action:DropBomb()
{
	g_Bomb[carrier] = INVALID_CLIENT;
	g_Bomb[status] = STATUS_DROPPED;
}

public Action:StartDefusing(client)
{
	if (g_Bomb[status] == STATUS_PLANTED && g_Bomb[process] == PROCESS_NONE)//&& CanDefuse(client))
	{
		g_Bomb[process] = PROCESS_DEFUSING;
		g_Bomb[owner] = client;
		g_Bomb[nextProcess]  = GetEngineTime() + g_Bomb[defuseTime];
	}
}

public Action:StopDefusing()
{
	if (g_Bomb[process] == PROCESS_DEFUSING)
	{
		g_Bomb[process] = PROCESS_NONE;
		g_Bomb[owner] = INVALID_CLIENT;
	}
}

public Action:StartPlanting(client)
{
	if (g_Bomb[status] == STATUS_CARRIED && g_Bomb[process] == PROCESS_NONE)//&& IsClientOnBombspot(client))
	{
		g_Bomb[process] = PROCESS_PLANTING;
		g_Bomb[owner] = client;
		g_Bomb[nextProcess]  = GetEngineTime() + g_Bomb[plantTime];
	}
}

public Action:StopPlanting()
{
	if (g_Bomb[process] == PROCESS_PLANTING)
	{
		g_Bomb[process] = PROCESS_NONE;
		g_Bomb[owner] = INVALID_CLIENT;
	}
}

public RemoveBomb()
{
	g_Bomb[status] = STATUS_NONE;
	g_Bomb[process] = PROCESS_NONE;
	g_Bomb[carrier] = INVALID_CLIENT;
	g_Bomb[owner]	= INVALID_CLIENT;
	g_Bomb[nextExplode] = INVALID;
	g_Bomb[nextProcess] = INVALID;
}

public SetupBomb(Float:explTime, Float:defTime, Float:plntTime)
{
	g_Bomb[explodeTime] = explTime;
	g_Bomb[defuseTime] = defTime;
	g_Bomb[plantTime] = plntTime;
}