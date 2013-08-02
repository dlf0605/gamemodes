#include <a_samp>
#include <ZCMD>
#include <sscanf2>
#include <dini>
native WP_Hash(buffer[], len, const str[]);

#include "../race/main.pwn"
#include "../race/func.pwn"
#include "../race/cmd.pwn"

main(){}
public OnGameModeInit()
{
  DisableInteriorEnterExits();
	UsePlayerPedAnims();
	EnableStuntBonusForAll(0);
	SetGameModeText("Race");
	InitializeDatabase();

	for(new skinid = 0; skinid < 300; skinid++)
		AddPlayerClass(skinid, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);

	for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
	{
		PlayerLeaveRace(playerid, true);
		ResetPlayerVariables(playerid);
	}

	SetRaceState(STATE_STARTING);
	SetTimer("UpdateCommandInfo", 5000, true);
	SetTimer("UpdateRaceHUD", 50, true);
	SetTimer("TimeCycle", 300, true);
	return 1;
}

public OnGameModeExit()
{
	db_close(db);
	SetRaceState(STATE_FINISHED);
	for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
	{
		if(!IsPlayerConnected(playerid)) continue;

		ResetPlayerVariables(playerid);
		DisablePlayerRaceCheckpoint(playerid);
	}
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	pClass[playerid] = true;
	if(pSkipClass[playerid] == true)
	{
		SetTimerEx("SpawnPlayerFix", 10, false, "i", playerid);
		pSkipClass[playerid] = false;
		return 1;
	}
	pSkin[playerid] = GetPlayerSkin(playerid);

	SetPlayerInterior(playerid, 1);
	SetPlayerPos(playerid, -2042.5791, 161.8492, 28.8359);
	SetPlayerFacingAngle(playerid, 14.3434);
	SetPlayerCameraPos(playerid, -2043.3851, 165.2296, 28.8359);
	SetPlayerCameraLookAt(playerid, -2042.5791, 161.8492, 28.8359);
	return 1;
}

public OnPlayerConnect(playerid)
{
	new rand, str[20];
	rand = random(14) + 1;
	format(str, sizeof(str), "loadsc%i:loadsc%i", rand, rand);

	td_intro[playerid] =
	CreatePlayerTextDraw			(playerid, -0.500, -0.500, str);
	PlayerTextDrawFont				(playerid, td_intro[playerid], 4);
	PlayerTextDrawTextSize			(playerid, td_intro[playerid], 641.500, 449.500);
	PlayerTextDrawColor				(playerid, td_intro[playerid], -1);

	td_back[playerid] =
	CreatePlayerTextDraw			(playerid, 553.000000, 357.000000, "~~");
	PlayerTextDrawAlignment			(playerid, td_back[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, td_back[playerid], 255);
	PlayerTextDrawFont				(playerid, td_back[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, td_back[playerid], 0.500000, 6.899998);
	PlayerTextDrawColor				(playerid, td_back[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, td_back[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, td_back[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, td_back[playerid], 1);
	PlayerTextDrawUseBox			(playerid, td_back[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, td_back[playerid], 75);
	PlayerTextDrawTextSize			(playerid, td_back[playerid], 0.000000, 111.000000);
	PlayerTextDrawSetSelectable		(playerid, td_back[playerid], 0);

	td_time[playerid][0] =
	CreatePlayerTextDraw			(playerid, 553.000000, 361.000000, "time");
	PlayerTextDrawAlignment			(playerid, td_time[playerid][0], 2);
	PlayerTextDrawBackgroundColor	(playerid, td_time[playerid][0], 255);
	PlayerTextDrawFont				(playerid, td_time[playerid][0], 2);
	PlayerTextDrawLetterSize		(playerid, td_time[playerid][0], 0.310000, 2.299998);
	PlayerTextDrawColor				(playerid, td_time[playerid][0], -1);
	PlayerTextDrawSetOutline		(playerid, td_time[playerid][0], 0);
	PlayerTextDrawSetProportional	(playerid, td_time[playerid][0], 0);
	PlayerTextDrawSetShadow			(playerid, td_time[playerid][0], 1);
	PlayerTextDrawSetSelectable		(playerid, td_time[playerid][0], 0);

	td_time[playerid][1] =
	CreatePlayerTextDraw			(playerid, 553.000000, 358.000000, "~~");
	PlayerTextDrawAlignment			(playerid, td_time[playerid][1], 2);
	PlayerTextDrawBackgroundColor	(playerid, td_time[playerid][1], 255);
	PlayerTextDrawFont				(playerid, td_time[playerid][1], 1);
	PlayerTextDrawLetterSize		(playerid, td_time[playerid][1], 0.500000, 3.099999);
	PlayerTextDrawColor				(playerid, td_time[playerid][1], -1);
	PlayerTextDrawSetOutline		(playerid, td_time[playerid][1], 0);
	PlayerTextDrawSetProportional	(playerid, td_time[playerid][1], 1);
	PlayerTextDrawSetShadow			(playerid, td_time[playerid][1], 1);
	PlayerTextDrawUseBox			(playerid, td_time[playerid][1], 1);
	PlayerTextDrawBoxColor			(playerid, td_time[playerid][1], 75);
	PlayerTextDrawTextSize			(playerid, td_time[playerid][1], 0.000000, 109.000000);
	PlayerTextDrawSetSelectable		(playerid, td_time[playerid][1], 0);

	td_pos[playerid][0] =
	CreatePlayerTextDraw			(playerid, 507.000000, 383.000000, "pos");
	PlayerTextDrawAlignment			(playerid, td_pos[playerid][0], 2);
	PlayerTextDrawBackgroundColor	(playerid, td_pos[playerid][0], 255);
	PlayerTextDrawFont				(playerid, td_pos[playerid][0], 2);
	PlayerTextDrawLetterSize		(playerid, td_pos[playerid][0], 0.320000, 2.999998);
	PlayerTextDrawColor				(playerid, td_pos[playerid][0], -1);
	PlayerTextDrawSetOutline		(playerid, td_pos[playerid][0], 0);
	PlayerTextDrawSetProportional	(playerid, td_pos[playerid][0], 0);
	PlayerTextDrawSetShadow			(playerid, td_pos[playerid][0], 1);
	PlayerTextDrawSetSelectable		(playerid, td_pos[playerid][0], 0);

	td_pos[playerid][1] =
	CreatePlayerTextDraw			(playerid, 525.000000, 386.000000, "suffix");
	PlayerTextDrawAlignment			(playerid, td_pos[playerid][1], 2);
	PlayerTextDrawBackgroundColor	(playerid, td_pos[playerid][1], 255);
	PlayerTextDrawFont				(playerid, td_pos[playerid][1], 2);
	PlayerTextDrawLetterSize		(playerid, td_pos[playerid][1], 0.239998, 1.599997);
	PlayerTextDrawColor				(playerid, td_pos[playerid][1], -1);
	PlayerTextDrawSetOutline		(playerid, td_pos[playerid][1], 0);
	PlayerTextDrawSetProportional	(playerid, td_pos[playerid][1], 0);
	PlayerTextDrawSetShadow			(playerid, td_pos[playerid][1], 1);
	PlayerTextDrawSetSelectable		(playerid, td_pos[playerid][1], 0);

	td_pos[playerid][2] =
	CreatePlayerTextDraw			(playerid, 526.000000, 403.000000, "outof");
	PlayerTextDrawAlignment			(playerid, td_pos[playerid][2], 2);
	PlayerTextDrawBackgroundColor	(playerid, td_pos[playerid][2], 255);
	PlayerTextDrawFont				(playerid, td_pos[playerid][2], 2);
	PlayerTextDrawLetterSize		(playerid, td_pos[playerid][2], 0.230000, 1.899997);
	PlayerTextDrawColor				(playerid, td_pos[playerid][2], -1);
	PlayerTextDrawSetOutline		(playerid, td_pos[playerid][2], 0);
	PlayerTextDrawSetProportional	(playerid, td_pos[playerid][2], 0);
	PlayerTextDrawSetShadow			(playerid, td_pos[playerid][2], 1);
	PlayerTextDrawSetSelectable		(playerid, td_pos[playerid][2], 0);

	td_pos[playerid][3] =
	CreatePlayerTextDraw			(playerid, 520.000000, 395.000000, "/");
	PlayerTextDrawAlignment			(playerid, td_pos[playerid][3], 2);
	PlayerTextDrawBackgroundColor	(playerid, td_pos[playerid][3], 255);
	PlayerTextDrawFont				(playerid, td_pos[playerid][3], 2);
	PlayerTextDrawLetterSize		(playerid, td_pos[playerid][3], 0.580000, 2.899998);
	PlayerTextDrawColor				(playerid, td_pos[playerid][3], -1);
	PlayerTextDrawSetOutline		(playerid, td_pos[playerid][3], 0);
	PlayerTextDrawSetProportional	(playerid, td_pos[playerid][3], 0);
	PlayerTextDrawSetShadow			(playerid, td_pos[playerid][3], 1);
	PlayerTextDrawSetSelectable		(playerid, td_pos[playerid][3], 0);

	td_pos[playerid][4] =
	CreatePlayerTextDraw			(playerid, 515.000000, 390.000000, "~~");
	PlayerTextDrawAlignment			(playerid, td_pos[playerid][4], 2);
	PlayerTextDrawBackgroundColor	(playerid, td_pos[playerid][4], 255);
	PlayerTextDrawFont				(playerid, td_pos[playerid][4], 1);
	PlayerTextDrawLetterSize		(playerid, td_pos[playerid][4], 0.500000, 3.099999);
	PlayerTextDrawColor				(playerid, td_pos[playerid][4], -1);
	PlayerTextDrawSetOutline		(playerid, td_pos[playerid][4], 0);
	PlayerTextDrawSetProportional	(playerid, td_pos[playerid][4], 1);
	PlayerTextDrawSetShadow			(playerid, td_pos[playerid][4], 1);
	PlayerTextDrawUseBox			(playerid, td_pos[playerid][4], 1);
	PlayerTextDrawBoxColor			(playerid, td_pos[playerid][4], 75);
	PlayerTextDrawTextSize			(playerid, td_pos[playerid][4], 0.000000, 33.000000);
	PlayerTextDrawSetSelectable		(playerid, td_pos[playerid][4], 0);

	td_speed[playerid][0] =
	CreatePlayerTextDraw			(playerid, 547.000000, 383.000000, "speed");
	PlayerTextDrawAlignment			(playerid, td_speed[playerid][0], 2);
	PlayerTextDrawBackgroundColor	(playerid, td_speed[playerid][0], 255);
	PlayerTextDrawFont				(playerid, td_speed[playerid][0], 2);
	PlayerTextDrawLetterSize		(playerid, td_speed[playerid][0], 0.319999, 2.999998);
	PlayerTextDrawColor				(playerid, td_speed[playerid][0], -1);
	PlayerTextDrawSetOutline		(playerid, td_speed[playerid][0], 0);
	PlayerTextDrawSetProportional	(playerid, td_speed[playerid][0], 0);
	PlayerTextDrawSetShadow			(playerid, td_speed[playerid][0], 1);
	PlayerTextDrawSetSelectable		(playerid, td_speed[playerid][0], 0);

	td_speed[playerid][1] =
	CreatePlayerTextDraw			(playerid, 559.000000, 405.000000, "km/h");
	PlayerTextDrawAlignment			(playerid, td_speed[playerid][1], 2);
	PlayerTextDrawBackgroundColor	(playerid, td_speed[playerid][1], 255);
	PlayerTextDrawFont				(playerid, td_speed[playerid][1], 2);
	PlayerTextDrawLetterSize		(playerid, td_speed[playerid][1], 0.239999, 1.599997);
	PlayerTextDrawColor				(playerid, td_speed[playerid][1], -1);
	PlayerTextDrawSetOutline		(playerid, td_speed[playerid][1], 0);
	PlayerTextDrawSetProportional	(playerid, td_speed[playerid][1], 1);
	PlayerTextDrawSetShadow			(playerid, td_speed[playerid][1], 1);
	PlayerTextDrawSetSelectable		(playerid, td_speed[playerid][1], 0);

	td_speed[playerid][2] =
	CreatePlayerTextDraw			(playerid, 553.000000, 390.000000, "~~");
	PlayerTextDrawAlignment			(playerid, td_speed[playerid][2], 2);
	PlayerTextDrawBackgroundColor	(playerid, td_speed[playerid][2], 255);
	PlayerTextDrawFont				(playerid, td_speed[playerid][2], 1);
	PlayerTextDrawLetterSize		(playerid, td_speed[playerid][2], 0.500000, 3.099999);
	PlayerTextDrawColor				(playerid, td_speed[playerid][2], -1);
	PlayerTextDrawSetOutline		(playerid, td_speed[playerid][2], 0);
	PlayerTextDrawSetProportional	(playerid, td_speed[playerid][2], 1);
	PlayerTextDrawSetShadow			(playerid, td_speed[playerid][2], 1);
	PlayerTextDrawUseBox			(playerid, td_speed[playerid][2], 1);
	PlayerTextDrawBoxColor			(playerid, td_speed[playerid][2], 75);
	PlayerTextDrawTextSize			(playerid, td_speed[playerid][2], 0.000000, 37.000000);
	PlayerTextDrawSetSelectable		(playerid, td_speed[playerid][2], 0);

	td_progress[playerid][0] =
	CreatePlayerTextDraw			(playerid, 587.000000, 383.000000, "progress");
	PlayerTextDrawAlignment			(playerid, td_progress[playerid][0], 2);
	PlayerTextDrawBackgroundColor	(playerid, td_progress[playerid][0], 255);
	PlayerTextDrawFont				(playerid, td_progress[playerid][0], 2);
	PlayerTextDrawLetterSize		(playerid, td_progress[playerid][0], 0.319999, 2.999998);
	PlayerTextDrawColor				(playerid, td_progress[playerid][0], -1);
	PlayerTextDrawSetOutline		(playerid, td_progress[playerid][0], 0);
	PlayerTextDrawSetProportional	(playerid, td_progress[playerid][0], 0);
	PlayerTextDrawSetShadow			(playerid, td_progress[playerid][0], 1);
	PlayerTextDrawSetSelectable		(playerid, td_progress[playerid][0], 0);

	td_progress[playerid][1] =
	CreatePlayerTextDraw			(playerid, 604.000000, 405.000000, "%");
	PlayerTextDrawAlignment			(playerid, td_progress[playerid][1], 2);
	PlayerTextDrawBackgroundColor	(playerid, td_progress[playerid][1], 255);
	PlayerTextDrawFont				(playerid, td_progress[playerid][1], 2);
	PlayerTextDrawLetterSize		(playerid, td_progress[playerid][1], 0.239999, 1.599997);
	PlayerTextDrawColor				(playerid, td_progress[playerid][1], -1);
	PlayerTextDrawSetOutline		(playerid, td_progress[playerid][1], 0);
	PlayerTextDrawSetProportional	(playerid, td_progress[playerid][1], 1);
	PlayerTextDrawSetShadow			(playerid, td_progress[playerid][1], 1);
	PlayerTextDrawSetSelectable		(playerid, td_progress[playerid][1], 0);

	td_progress[playerid][2] =
	CreatePlayerTextDraw			(playerid, 591.000000, 390.000000, "~~");
	PlayerTextDrawAlignment			(playerid, td_progress[playerid][2], 2);
	PlayerTextDrawBackgroundColor	(playerid, td_progress[playerid][2], 255);
	PlayerTextDrawFont				(playerid, td_progress[playerid][2], 1);
	PlayerTextDrawLetterSize		(playerid, td_progress[playerid][2], 0.500000, 3.099999);
	PlayerTextDrawColor				(playerid, td_progress[playerid][2], -1);
	PlayerTextDrawSetOutline		(playerid, td_progress[playerid][2], 0);
	PlayerTextDrawSetProportional	(playerid, td_progress[playerid][2], 1);
	PlayerTextDrawSetShadow			(playerid, td_progress[playerid][2], 1);
	PlayerTextDrawUseBox			(playerid, td_progress[playerid][2], 1);
	PlayerTextDrawBoxColor			(playerid, td_progress[playerid][2], 75);
	PlayerTextDrawTextSize			(playerid, td_progress[playerid][2], 0.000000, 33.000000);
	PlayerTextDrawSetSelectable		(playerid, td_progress[playerid][2], 0);

	td_border[playerid] =
	CreatePlayerTextDraw			(playerid, 320.000000, 438.000000, "~~");
	PlayerTextDrawAlignment			(playerid, td_border[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, td_border[playerid], 255);
	PlayerTextDrawFont				(playerid, td_border[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, td_border[playerid], 0.500000, 0.999998);
	PlayerTextDrawColor				(playerid, td_border[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, td_border[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, td_border[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, td_border[playerid], 1);
	PlayerTextDrawUseBox			(playerid, td_border[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, td_border[playerid], 150);
	PlayerTextDrawTextSize			(playerid, td_border[playerid], 0.000000, 638.000000);
	PlayerTextDrawSetSelectable		(playerid, td_border[playerid], 0);

	td_info[playerid] =
	CreatePlayerTextDraw			(playerid, 638.000000, 437.000000, "~~");
	PlayerTextDrawAlignment			(playerid, td_info[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, td_info[playerid], 255);
	PlayerTextDrawFont				(playerid, td_info[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, td_info[playerid], 0.180000, 1.000000);
	PlayerTextDrawColor				(playerid, td_info[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, td_info[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, td_info[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, td_info[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid, td_info[playerid], 0);

	td_cmds[playerid] =
	CreatePlayerTextDraw			(playerid, 1.000000, 437.000000, "~~");
	PlayerTextDrawBackgroundColor	(playerid, td_cmds[playerid], 255);
	PlayerTextDrawFont				(playerid, td_cmds[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, td_cmds[playerid], 0.180000, 1.000000);
	PlayerTextDrawColor				(playerid, td_cmds[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, td_cmds[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, td_cmds[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, td_cmds[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid, td_cmds[playerid], 0);

	td_timeleft[playerid] =
	CreatePlayerTextDraw			(playerid, 320.000000, 401.000000, "time");
	PlayerTextDrawAlignment			(playerid, td_timeleft[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, td_timeleft[playerid], 255);
	PlayerTextDrawFont				(playerid, td_timeleft[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, td_timeleft[playerid], 0.360000, 2.099999);
	PlayerTextDrawColor				(playerid, td_timeleft[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, td_timeleft[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, td_timeleft[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid, td_timeleft[playerid], 0);

	PlayerTextDrawShow(playerid, td_intro[playerid]);
	PlayerTextDrawShow(playerid, td_border[playerid]);
	PlayerTextDrawShow(playerid, td_info[playerid]);
	PlayerTextDrawShow(playerid, td_cmds[playerid]);

	new string[128], name[MAX_PLAYER_NAME+1];
	GetPlayerName(playerid, name, sizeof(name));
	format(string, sizeof(string), "%s has joined the server!", name);
	SendClientMessageToAll(COLOR_GREY, string);
	TogglePlayerSpectating(playerid, true);

	if(IsPlayerRegistered(playerid))
	{
		new query[500], DBResult:result, ip[16];
		GetPlayerIp(playerid, ip, sizeof(ip));
		format(query, sizeof(query), "SELECT `name` AND `ip` FROM `players` WHERE `name` = '%s' AND `ip` = '%s'",
	    	DBEscape(name), DBEscape(ip));
		result = db_query(db, query);
		if(db_num_rows(result) > 0) LoginPlayer(playerid, true);
		else
		{
			ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""C_WHITE"Login",
				""C_WHITE"This name is registered\nEnter your password below to login.", "Login", "");
		}
		db_free_result(result);
	}
	else
		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, ""C_WHITE"Register",
			""C_WHITE"This name is not registered\nEnter your new password below to register.", "Register", "");
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new string[128], name[MAX_PLAYER_NAME+1];
	GetPlayerName(playerid, name, sizeof(name));
	switch(reason)
	{
		case 0:	format(string, sizeof(string), "%s has left the server. (Timeout)", name);
		case 1: format(string, sizeof(string), "%s has left the server. (Leaving)", name);
		case 2:
		{
			if(pBan[playerid] == true) format(string, sizeof(string), "%s has left the server. (Banned) (%s)", name, pReason[playerid]);
			else format(string, sizeof(string), "%s has left the server. (Kicked) (%s)", name, pReason[playerid]);
		}
	}
	SendClientMessageToAll(COLOR_GREY, string);

	SavePlayer(playerid);
	ResetPlayerVariables(playerid);
	for(new spectatorid = 0; spectatorid < MAX_PLAYERS; spectatorid++)
	{
		if(!IsPlayerConnected(spectatorid)) continue;
		if(pSpec[spectatorid] == playerid)
		{
			TogglePlayerSpectating(spectatorid, false);
			pSpec[spectatorid] = -1;
			PlayerTextDrawSetString(spectatorid, td_info[spectatorid], "~~");
		}
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	pClass[playerid] = false;
	SetPlayerSkin(playerid, pSkin[playerid]);
	if(rState == STATE_STARTING) return 1;

	new Float:x, Float:y, Float:z, Float:x2, Float:y2, Float:angle, cp, nextcp;
	cp = pCp[playerid] - 1;
	if(cp < 0)
	{
		if(pLap[playerid] > 0 && rCircuit == true)
		{
			cp = GetRaceCps();
			nextcp = 0;
		}
		else
		{
			cp = 0;
			nextcp = cp + 1;
		}
	}
	else nextcp = cp + 1;

	x = rCp[cp][0]; y = rCp[cp][1]; z = rCp[cp][2];
	x2 = rCp[nextcp][0]; y2 = rCp[nextcp][1];
	angle = atan2((y2 - y), (x2 - x)) + 270.0;

	switch(rState)
	{
		case STATE_COUNTDOWN:
		{
			SetPlayerLowestSlot(playerid);
			GetGridPosition(pSlot[playerid], angle, x, y);
			TogglePlayerControllable(playerid, false);
		}
		case STATE_STARTED:
			PlayerJoinRace(playerid);
	}

	if(pVeh[playerid] != -1) DestroyVehicle(pVeh[playerid]);
	new model = rVehicle + 400;
	pVeh[playerid] = CreateVehicle(model, 0.0, 0.0, 0.0, 0.0, -1, -1, -1);

	AddVehicleComponent(pVeh[playerid], 1008);
	PutPlayerInVehicle(playerid, pVeh[playerid], 0);
	SetVehiclePos(pVeh[playerid], x, y, z);
	SetVehicleZAngle(pVeh[playerid], angle);
	LinkVehicleToInterior(pVeh[playerid], 0);

	SetPlayerInterior(playerid, 0);
	SetCameraBehindPlayer(playerid);
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
	{
		if(!IsPlayerConnected(playerid)) continue;
		if(vehicleid == pVeh[playerid])
	    {
			RemovePlayerFromVehicle(playerid);
			SetPlayerHealth(playerid, 0.0);
			return 1;
		}
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	new seat, Float:x, Float:y, Float:z;
	seat = GetPlayerVehicleSeat(playerid);
	GetPlayerPos(playerid, x, y, z);
	SetPlayerPos(playerid, x, y, z);
	PutPlayerInVehicle(playerid, vehicleid, seat);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(oldstate == PLAYER_STATE_DRIVER && newstate == PLAYER_STATE_ONFOOT && pVeh[playerid] != -1)
		PutPlayerInVehicle(playerid, pVeh[playerid], 0);

	if(!IsPlayerSpawned(playerid))
	{
		for(new spectatorid = 0; spectatorid < MAX_PLAYERS; spectatorid++)
		{
			if(!IsPlayerConnected(spectatorid)) continue;
			if(pSpec[spectatorid] == playerid)
			{
				TogglePlayerSpectating(spectatorid, false);
				pSpec[spectatorid] = -1;
				PlayerTextDrawSetString(spectatorid, td_info[spectatorid], "~~");
			}
		}
	}
	else
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
			for(new spectatorid = 0; spectatorid < MAX_PLAYERS; spectatorid++)
			{
				if(!IsPlayerConnected(spectatorid)) continue;
				if(pSpec[spectatorid] == playerid)
				{
					new vehicleid = GetPlayerVehicleID(playerid);
					PlayerSpectateVehicle(spectatorid, vehicleid);
				}
			}
		}
		else
		{
			for(new spectatorid = 0; spectatorid < MAX_PLAYERS; spectatorid++)
			{
				if(!IsPlayerConnected(spectatorid)) continue;
				if(pSpec[spectatorid] == playerid)
				{
					PlayerSpectatePlayer(spectatorid, playerid);
				}
			}
		}
	}
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	if(!IsPlayerSpawned(playerid) || rState != STATE_STARTED) return 1;
	PlayerPlaySound(playerid, 1139, 0, 0, 0);

	new cps, type;
	cps = GetRaceCps();
	if(rAir == true) type = 3;
	else type = 0;

	if(pCp[playerid] == 0 && rCircuit == true)
	{
		if(pLap[playerid] > 0) AttemptRaceRecord(playerid);
		if(pLap[playerid] == rLaps)
		{
			PlayerLeaveRace(playerid, false);
			return 1;
		}
		else pTime[playerid] = GetTickCount();
	}

	if(pCp[playerid] == cps)
	{
		if(rCircuit == true)
		{
			pCp[playerid] = 0;
			pLap[playerid] ++;
			if(pLap[playerid] >= rLaps) type ++;

			SetPlayerRaceCheckpoint(playerid, type, rCp[0][0], rCp[0][1], rCp[0][2],
				rCp[1][0], rCp[1][1], rCp[1][2], 15.0);
		}
		else
		{
			AttemptRaceRecord(playerid);
			PlayerLeaveRace(playerid, false);
			return 1;
		}
	}
	else if(pCp[playerid] == cps-1)
	{
		pCp[playerid] ++;
		if(rCircuit == false) type ++;

		SetPlayerRaceCheckpoint(playerid, type, rCp[cps][0], rCp[cps][1], rCp[cps][2],
			rCp[0][0], rCp[0][1], rCp[0][2], 15.0);
	}
	else
	{
		pCp[playerid] ++;

		SetPlayerRaceCheckpoint(playerid, type, rCp[pCp[playerid]][0], rCp[pCp[playerid]][1], rCp[pCp[playerid]][2],
			rCp[pCp[playerid]+1][0], rCp[pCp[playerid]+1][1], rCp[pCp[playerid]+1][2], 15.0);
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(pEdit[playerid] == true && (newkeys & KEY_SPRINT))
	{
		if(GetTickCount() - pEditTick[playerid] < 2000 && pEditTick[playerid] != 0)
		{
		    PlayerPlaySound(playerid, 4203, 0.0, 0.0, 0.0);
		    return 1;
		}

		new Float:x, Float:y, Float:z, id;
		id = pEditCurrent[playerid];

		GetPlayerPos(playerid, x, y, z);
		pEditCp[playerid][id][0] = x;
		pEditCp[playerid][id][1] = y;
		pEditCp[playerid][id][2] = z;

		new type;
		if(pEditAir[playerid] == true) type = 3;
		else type = 2;

		SetPlayerRaceCheckpoint(playerid, type, pEditCp[playerid][id][0], pEditCp[playerid][id][1], pEditCp[playerid][id][2],
			pEditCp[playerid][id][0], pEditCp[playerid][id][1], pEditCp[playerid][id][2], 15.0);

		PlayerPlaySound(playerid, 4202, 0.0, 0.0, 0.0);
		GameTextForPlayer(playerid, "~w~Checkpoint saved", 1000, 6);
		pEditTick[playerid] = GetTickCount();

		if(id < MAX_CHECKPOINTS-1) pEditCurrent[playerid]++;
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(pEdit[playerid] == true)
	{
		new keys,ud,lr;
		GetPlayerKeys(playerid,keys,ud,lr);

		if(pEditMode[playerid] > 0 && (GetTickCount() - pEditLastMove[playerid] > 100))
		{
		    MoveCamera(playerid);
		}

		if(pEditUD[playerid] != ud || pEditLR[playerid] != lr)
		{
			if((pEditUD[playerid] != 0 || pEditLR[playerid] != 0) && ud == 0 && lr == 0)
			{
				StopPlayerObject(playerid, pEditObj[playerid]);
				pEditMode	[playerid] = 0;
				pEditSpeed	[playerid] = 0.0;
			}
			else
			{
				pEditMode[playerid] = GetMoveDirectionFromKeys(ud, lr);
				MoveCamera(playerid);
			}
		}
		pEditUD[playerid] = ud;
		pEditLR[playerid] = lr;
	}
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
	{
		if(!IsPlayerConnected(playerid)) continue;
		if(pVeh[playerid] == vehicleid)
		{
			if(playerid == forplayerid) SetVehicleParamsForPlayer(vehicleid, playerid, 0, 0);
			else SetVehicleParamsForPlayer(vehicleid, playerid, 0, 1);
		}
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_REGISTER:
		{
			if(!response)
			{
				KickEx(playerid, "Skipped Registration");
				return 1;
			}

			if(strlen(inputtext) < 3 || strlen(inputtext) > 25)
			{
				ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, ""C_WHITE"Register",
					""C_WHITE"Invalid Password Length!", "Register", "");
				return 1;
			}
			
			RegisterPlayer(playerid, inputtext);
			return 1;
		}
		case DIALOG_LOGIN:
		{
			if(!response)
			{
				KickEx(playerid, "Skipped login");
				return 1;
			}

			if(strlen(inputtext) == 0)
			{
				ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""C_WHITE"Login",
					""C_WHITE"Enter your password below to login.", "Login", "");
				return 1;
			}

			new query[500], DBResult:result, name[MAX_PLAYER_NAME+1], hash[129];
			GetPlayerName(playerid, name, sizeof(name));
			WP_Hash(hash, sizeof(hash), inputtext);

			format(query, sizeof(query), "SELECT `name` AND `password` FROM `players` WHERE `name` = '%s' AND `password` = '%s'",
				DBEscape(name), DBEscape(hash));
			result = db_query(db, query);
			if(db_num_rows(result) > 0)
			{
				LoginPlayer(playerid, false);
			}
			else
			{
				ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""C_WHITE"Login",
					""C_WHITE"Invalid Password!", "Login", "");
			}
			db_free_result(result);
			return 1;
		}
		case DIALOG_MAIN:
		{
			if(!response) return 1;

			switch(listitem)
			{
				case 0:// Circuit
				{
					if(pEditCircuit[playerid] == true) pEditCircuit[playerid] = false;
					else pEditCircuit[playerid] = true;
					ShowPlayerRaceEditDialog(playerid, 0);
					return 1;
				}
				case 1:// Air
				{
					if(pEditAir[playerid] == true) pEditAir[playerid] = false;
					else pEditAir[playerid] = true;
					ShowPlayerRaceEditDialog(playerid, 0);
					return 1;
				}
				case 2:// Vehicles
				{
					ShowPlayerRaceEditDialog(playerid, 1);
					return 1;
				}
				case 3:// Select CP
				{
					ShowPlayerRaceEditDialog(playerid, 2);
					return 1;
				}
				case 4:// Finish Editing
				{
					ShowPlayerRaceEditDialog(playerid, 4);
					return 1;
				}
				default: return 1;
			}
		}
		case DIALOG_VEHICLE:
		{
			if(!response)
			{
				ShowPlayerRaceEditDialog(playerid, 0);
				return 1;
			}

			pEditVehicle[playerid] = RaceVehicles[listitem] - 400;
			ShowPlayerRaceEditDialog(playerid, 0);
			return 1;
		}
		case DIALOG_CPLIST:
		{
			if(!response)
			{
				ShowPlayerRaceEditDialog(playerid, 0);
				return 1;
			}

			new Float:x, Float:y, Float:z;
			x = pEditCp[playerid][listitem][0];
			y = pEditCp[playerid][listitem][1];
			z = pEditCp[playerid][listitem][2];
			if(x != 0.0 || y != 0.0 || z != 0.0)
			{
				new type;
				if(pEditAir[playerid] == true) type = 3;
				else type = 2;

				SetPlayerRaceCheckpoint(playerid, type, pEditCp[playerid][listitem][0], pEditCp[playerid][listitem][1], pEditCp[playerid][listitem][2],
					pEditCp[playerid][listitem][0], pEditCp[playerid][listitem][1], pEditCp[playerid][listitem][2], 15.0);
			}
			pEditCurrent[playerid] = listitem;
			ShowPlayerRaceEditDialog(playerid, 3);
		}
		case DIALOG_CP:
		{
			if(!response)
			{
				ShowPlayerRaceEditDialog(playerid, 2);
				return 1;
			}

			new id = pEditCurrent[playerid];
			pEditCp[playerid][id][0] = 0.0;
		    pEditCp[playerid][id][1] = 0.0;
		    pEditCp[playerid][id][2] = 0.0;

		    new string[128];
		    format(string, sizeof(string), "Checkpoint %i removed.", id + 1);
			SendClientMessage(playerid, COLOR_WHITE, string);

			ShowPlayerRaceEditDialog(playerid, 2);
			DisablePlayerRaceCheckpoint(playerid);
			return 1;
		}
		case DIALOG_CLOSE:
		{
			new string[128], action[10];
			if(!response) action = "NOT SAVE";
			else
			{
				SaveRace(pEditName[playerid], playerid);
				action = "SAVE";
			}

			format(string, sizeof(string), "You have chosen to %s the changes made to the Race %s", action, pEditName[playerid]);
			SendClientMessage(playerid, COLOR_WHITE, string);
			PlayerTextDrawSetString(playerid, td_info[playerid], "~~");
			TogglePlayerSpectating(playerid, false);
			DisablePlayerRaceCheckpoint(playerid);
			ResetPlayerEditVariables(playerid);

			SpawnPlayerFix(playerid);
			return 1;
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	new string[500], line[100], name[MAX_PLAYER_NAME+1];

	GetPlayerName(clickedplayerid, name, sizeof(name));
	format(line, sizeof(line), "Name: %s\n", name);
	strcat(string, line);

	format(line, sizeof(line), "Playerid: %i\n", clickedplayerid);
	strcat(string, line);

	if(pAdmin[playerid] > LEVEL_PLAYER)
	{
		new ip[16]; GetPlayerIp(clickedplayerid, ip, sizeof(ip));
		format(line, sizeof(line), "IP: %s\n", ip); strcat(string, line);
	}

	format(line, sizeof(line), "Level: %s\n", GetLevelName(pAdmin[clickedplayerid]));
	strcat(string, line);

	format(line, sizeof(line), "Races won: %i\n", pWin[clickedplayerid]);
	strcat(string, line);

	format(line, sizeof(line), "Races lost: %i\n", pLoss[clickedplayerid]);
	strcat(string, line);

	format(line, sizeof(line), "Win/Lose Ratio: %.02f\n", floatdiv(pWin[clickedplayerid], pLoss[clickedplayerid]));
	strcat(string, line);

	ShowPlayerDialog(playerid, DIALOG_STATS, DIALOG_STYLE_MSGBOX, "Player Information", string, "Close", "");
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}
