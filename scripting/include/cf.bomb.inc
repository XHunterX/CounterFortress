#if defined _tads_included_
#endinput
#endif
#define _tads_included_

#define STRING_SIZE 128

enum BombStatus
{
	STATUS_NONE		= -1,
	STATUS_CARRIED	= 0,
	STATUS_DROPPED	= 1,
	STATUS_PLANTED	= 2,
	STATUS_DEFUSED	= 3,
	STATUS_EXPLODED	= 4,
}

enum BombProcess
{
	PROCESS_NONE		= -1,
	PROCESS_PLANTING	= 0,
	PROCESS_DEFUSING	= 1,
}

forward Action:CF_OnBombExplodePre();
forward Action:CF_OnBombExplodePost();

native BombStatus:CF_GetBombStatus();