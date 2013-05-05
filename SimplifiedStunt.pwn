#define BUD_USE_WHIRLPOOL true
#define BUD_MAX_COLUMNS  (23)
#define BUD_MULTIGET_MAX_ENTRIES  (19)
#define BUD_MULTISET_MAX_ENTRIES  (19)
  
#include <a_samp>
#include <sscanf2>
#include <ZCMD>
#include <BUD>

#include "../include/settings.pwn"
#include "../include/variables.pwn"
#include "../include/functions.pwn"
#include "../include/commands.pwn"

main()
{
	return 1;
}

public OnGameModeInit()
{
	SetGameModeText("Freeroam Stunt");
	SendRconCommand("hostname Simplified Stunting");

	SetTeamCount(1);
	EnableVehicleFriendlyFire( );
	DisableInteriorEnterExits( );
    	ShowPlayerMarkers(1);
	UsePlayerPedAnims( );

	BUD::Initialize( );
	BUD::VerifyColumn("vehmodel", 	BUD::TYPE_NUMBER);
	BUD::VerifyColumn("vehcolour1", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("vehcolour2", BUD::TYPE_NUMBER);

	BUD::VerifyColumn("admin", 	BUD::TYPE_NUMBER);
	BUD::VerifyColumn("skin", 	BUD::TYPE_NUMBER);
	BUD::VerifyColumn("weather", 	BUD::TYPE_NUMBER);
	BUD::VerifyColumn("world", 	BUD::TYPE_NUMBER);
	BUD::VerifyColumn("practice", 	BUD::TYPE_NUMBER);
	BUD::VerifyColumn("hour", 	BUD::TYPE_NUMBER);
	BUD::VerifyColumn("minute", 	BUD::TYPE_NUMBER);

	BUD::VerifyColumn("savepoint", BUD::TYPE_NUMBER);
	BUD::VerifyColumn("saveveh",	BUD::TYPE_NUMBER);
	BUD::VerifyColumn("saveposx", 	BUD::TYPE_FLOAT);
	BUD::VerifyColumn("saveposy", 	BUD::TYPE_FLOAT);
	BUD::VerifyColumn("saveposz", 	BUD::TYPE_FLOAT);
	BUD::VerifyColumn("saveposa", 	BUD::TYPE_FLOAT);
	BUD::VerifyColumn("savevelx", 	BUD::TYPE_FLOAT);
	BUD::VerifyColumn("savevely", 	BUD::TYPE_FLOAT);
	BUD::VerifyColumn("savevelz", 	BUD::TYPE_FLOAT);

	for(new skinid = 0; skinid < 300; skinid++)
	{
		switch(skinid) { case 74: continue; }
		AddPlayerClass(skinid, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
	}

	for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
	{
		ResetVariables(playerid);
	}
	return 1;
}

public OnGameModeExit()
{
	BUD::Exit( );
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	if(pSkipClass[playerid] == true)
	{
		pSkipClass[playerid] = false;
		SetPlayerSkin(playerid, pSkin[playerid]);
		SetTimerEx("ForceSpawn", 1, false, "i", playerid);
		return 1;
	}

	SetPlayerPos(playerid, -1956.1710,-859.1072,35.8909);
	SetPlayerFacingAngle(playerid, 270.00);
	SetPlayerCameraPos(playerid, -1952.1710,-859.1072,36.8909);
	SetPlayerCameraLookAt(playerid, -1956.1710,-859.1072,35.8909);
	return 1;
}

public OnPlayerConnect(playerid)
{
    	new string[128], name[MAX_PLAYER_NAME+1];
    	GetPlayerName(playerid, name, sizeof(name));
    	format(string,sizeof(string),"%s has joined the server.",name);
   	SendClientMessageToAll(COLOR_GREY,string);

	SetPlayerTeam(playerid, 0);
	TogglePlayerSpectating(playerid, true);

	CreateHUD(playerid);
	CreateBrowseMenu(playerid);
	ShowHUD(playerid,false);
	
	new userid;
	userid = BUD::GetNameUID(name);
	if(userid == BUD::INVALID_UID )
    	{
		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD,
		""C_WHITE"Register a new account", ""C_WHITE"Enter a password", "Register", "");
	}
	else
	{
		ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD,
		""C_WHITE"Login to your account", ""C_WHITE"Enter your password", "Login", "");
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new string[128], name[MAX_PLAYER_NAME+1], reasonstr[20];
	GetPlayerName(playerid, name, sizeof(name));
	switch(reason)
	{
		case 0: reasonstr = "Lost Connection";
		case 1: reasonstr = "Leaving";
		case 2: reasonstr = "Kicked";
		default: reasonstr =  "Unknown";
	}
	format(string,sizeof(string),"%s has left the server. (%s)", name, reasonstr);
	SendClientMessageToAll(COLOR_GREY,string);

	new userid;
	userid = BUD::GetNameUID(name);
	if(userid != BUD::INVALID_UID && pLoggedIn[playerid] == true)
	{
		BUD::MultiSet(userid, "iiiiiiiiiiiifffffff",
			"vehmodel", 	pVehModel[playerid],
			"vehcolour1", 	pVehColour[playerid][0],
			"vehcolour2", 	pVehColour[playerid][1],
			"admin", 		pAdmin[playerid],
			"skin", 		pSkin[playerid],
			"weather", 		pWeather[playerid],
			"world", 		pWorld[playerid],
			"practice", 	pPractice[playerid],
			"hour", 		pTime[playerid][0],
			"minute", 		pTime[playerid][1],
			"savepoint", 	pSavedPoint[playerid],
			"saveveh", 		pSavedVeh[playerid],
			"saveposx", 	pSavedPos[playerid][0],
			"saveposy", 	pSavedPos[playerid][1],
			"saveposz", 	pSavedPos[playerid][2],
			"saveposa", 	pSavedAng[playerid],
			"savevelx", 	pSavedVel[playerid][0],
			"savevely", 	pSavedVel[playerid][1],
			"savevelz", 	pSavedVel[playerid][2]
		);
	}
			
	ResetVariables(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	new Float:x, Float:y, Float:z, skin, world, weather, hour, minute;
	
	skin = GetPlayerSkin(playerid);
	world = pWorld[playerid];
	weather = pWeather[playerid];
	hour = pTime[playerid][0];
	minute = pTime[playerid][1];

	pSkin[playerid] = skin;
	if(world == 0) SetPlayerVirtualWorld(playerid, 0);
	else SetPlayerVirtualWorld(playerid, playerid + 1);
	SetPlayerWeather(playerid, weather);
	SetPlayerTime(playerid, hour, minute);

	if(IsValidPlayerObject(playerid, pFlyObj[playerid]))
	{
		GetPlayerObjectPos(playerid, pFlyObj[playerid], x, y, z);
		StopPlayerObject(playerid, pFlyObj[playerid]);
		DestroyPlayerObject(playerid, pFlyObj[playerid]);
	}
	else
	{
		if(pSavedPoint[playerid] == true)
		{
			PlayerPointInteraction(playerid,1);
			return 1;
		}

		new Float:angle;

		x = -195.6658 + random(30);
		y = -31.5831 + random(30);
		z = 3.1172;

		angle = random(360);
		SetPlayerFacingAngle(playerid, angle);
	}
	SetPlayerInterior(playerid, 0);
	SetCameraBehindPlayer(playerid);
	SetPlayerPos(playerid, x, y, z);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_ONFOOT && oldstate == PLAYER_STATE_DRIVER)
	{
		KillTimer(pNosTimer[playerid]);
	}

	switch(newstate)
	{
		case PLAYER_STATE_DRIVER, PLAYER_STATE_PASSENGER, PLAYER_STATE_ONFOOT:
		{
			UpdateHUD(playerid);
		}
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(pHUD[playerid] == false)
	{
		if(PRESSED(KEY_WALK | KEY_JUMP) && !IsPlayerInAnyVehicle(playerid))
		{
		    	ShowHUD(playerid,true);
			ClearAnimations(playerid);
			return 1;
		}
		if(PRESSED(KEY_CROUCH) && IsPlayerInAnyVehicle(playerid))
		{
		    ShowHUD(playerid,true);
		}
	}

	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		new vehicleid;
		vehicleid = GetPlayerVehicleID(playerid);

		if(PRESSED(KEY_FIRE))
		{
			AddVehicleComponent(vehicleid, 1010);

			KillTimer(pNosTimer[playerid]);
			pNosTimer[playerid] = SetTimerEx("CheckPlayerNos", 2000, true, "i", playerid);
		}
		if(RELEASED(KEY_FIRE))
		{
			RemoveVehicleComponent(vehicleid, 1010);
			KillTimer(pNosTimer[playerid]);
		}
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	new playerip[16];
	for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
	{
		if(!IsPlayerConnected(playerid)) continue;

		GetPlayerIp(playerid, playerip, sizeof(playerip));
		if(!strcmp(ip,playerip))
		{
			switch(success)
			{
				case 0: Kick(playerid);
				case 1:
				{
					if(pAdmin[playerid] == true) continue;

					new name[MAX_PLAYER_NAME+1];
					GetPlayerName(playerid, name, sizeof(name));

					SendClientMessage(playerid, COLOR_WHITE,">> You have been promoted to admin!");
					printf(">> %s was promoted to admin (RCON Login)",name);

					pAdmin[playerid] = true;
				}
			}
			return 1;
		}
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(pPractice[playerid] == true)
	{
		new Float:health;
		GetPlayerHealth(playerid, health);
		if(health < 100.0) SetPlayerHealth(playerid, 100);

		if(IsPlayerInAnyVehicle(playerid))
		{
			new vehicleid;
			vehicleid = GetPlayerVehicleID(playerid);
			GetVehicleHealth(vehicleid, health);

			if(health < 1000.0)
			{
				RepairVehicle(vehicleid);
			}
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
				Kick(playerid);
				return 1;
			}
			if(strlen(inputtext) < 3)
			{
				ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, ""C_WHITE"Register a new account",
				""C_WHITE"Enter a password\n"C_RED"This password is too short!", "Register", "");
				return 1;
			}

			new name[MAX_PLAYER_NAME+1];
			GetPlayerName(playerid, name, sizeof(name));
			BUD::RegisterName(name, inputtext);

			TogglePlayerSpectating(playerid, false);
			return 1;
		}
		case DIALOG_LOGIN:
		{
			if(!response)
			{
				Kick(playerid);
				return 1;
			}
			new name[MAX_PLAYER_NAME+1];
			GetPlayerName(playerid, name, sizeof(name));

			if(BUD::CheckAuth(name, inputtext))
			{
				new userid, string[128];
				userid = BUD::GetNameUID(name);

				BUD::MultiGet(userid, "iiiiiiiiiiiifffffff",
					"vehmodel", 	pVehModel[playerid],
					"vehcolour1", 	pVehColour[playerid][0],
					"vehcolour2", 	pVehColour[playerid][1],
					"admin", 		pAdmin[playerid],
					"skin", 		pSkin[playerid],
					"weather", 		pWeather[playerid],
					"world", 		pWorld[playerid],
					"practice", 	pPractice[playerid],
					"hour", 		pTime[playerid][0],
					"minute", 		pTime[playerid][1],
					"savepoint", 	pSavedPoint[playerid],
					"saveveh", 		pSavedVeh[playerid],
					"saveposx", 	pSavedPos[playerid][0],
					"saveposy", 	pSavedPos[playerid][1],
					"saveposz", 	pSavedPos[playerid][2],
					"saveposa", 	pSavedAng[playerid],
					"savevelx", 	pSavedVel[playerid][0],
					"savevely", 	pSavedVel[playerid][1],
					"savevelz", 	pSavedVel[playerid][2]
				);

				format(string, sizeof(string), "Account Logged In! (User: %s | User ID: %i)", name, userid);
				SendClientMessage(playerid, COLOR_WHITE, string);

				TogglePlayerSpectating(playerid, false);

				pSkipClass[playerid] = true;
				pLoggedIn[playerid] = true;
				return 1;
			}
			else
			{
				ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""C_WHITE"Login to your account",
				""C_WHITE"Enter your password\n"C_RED"Incorrect Password!", "Login", "");
				return 1;
			}
		}
	}
	return 0;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:(INVALID_TEXT_DRAW) && pHUD[playerid] == true)
	{
		ShowHUD(playerid,false);
	}
	return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == hud_Button[playerid][0]) // Change Vehicle
	{
		SetCameraBehindPlayer(playerid);
		ShowBrowseMenu(playerid, 3, true);

		UpdatePlayerVehicleBrowserMode(playerid, true);
		SpawnPlayerVehicle(playerid);

		pBrowsing[playerid] = 1;
	}
	if(playertextid == hud_Button[playerid][1]) // Get Vehicle
	{
		SpawnPlayerVehicle(playerid);
	}
	if(playertextid == hud_Button[playerid][2]) // Set Retry Point
	{
		PlayerPointInteraction(playerid,0);
	}
	if(playertextid == hud_Button[playerid][3]) // Get Retry Point
	{
		PlayerPointInteraction(playerid,1);
	}
	if(playertextid == hud_Button[playerid][4]) // Clear Retry Point
	{
		PlayerPointInteraction(playerid,2);
	}
	if(playertextid == hud_Button[playerid][5]) // Change Difficulty
	{
		if(pPractice[playerid] == true)
		{
			pPractice[playerid] = false;
			SendClientMessage(playerid, COLOR_WHITE, ">> You stopped using practice mode.");
		}
		else
		{
			pPractice[playerid] = true;
			SendClientMessage(playerid, COLOR_WHITE, ">> You are now using practice mode!");
		}
	}
	if(playertextid == hud_Button[playerid][6]) // Change View
	{
		if(IsValidPlayerObject(playerid, pFlyObj[playerid]))
		{
			SetPlayerFlyMode(playerid,false);
			SendClientMessage(playerid, COLOR_WHITE, ">> You have stopped using the flight mode.");
		}
		else
		{
			SetPlayerFlyMode(playerid,true);
			SendClientMessage(playerid, COLOR_WHITE, ">> You are now using the flight mode!");
			SendClientMessage(playerid, COLOR_WHITE, "Keys: ~k~~GO_FORWARD~ ~k~~GO_BACK~ MOUSE to navigate. ~k~~PED_JUMPING~ to move faster.");
		}
		return 1;
	}
	if(playertextid == hud_Button[playerid][7]) // Change World
	{
		new world;
		world = pWorld[playerid];

		if(world == 0)
		{
			SetPlayerVirtualWorld(playerid, playerid + 1);
			SendClientMessage(playerid, COLOR_WHITE, ">> You have entered your private world");

			pWorld[playerid] = true;
		}
		else
		{
			SetPlayerVirtualWorld(playerid, 0);
			SendClientMessage(playerid, COLOR_WHITE, ">> You have left your private world");

			pWorld[playerid] = false;
		}
	}
	if(playertextid == hud_Button[playerid][8]) // Change Time
	{
		UpdatePlayerTime(playerid);
		ShowBrowseMenu(playerid, 2, true);

		pBrowsing[playerid] = 2;
	}
	if(playertextid == hud_Button[playerid][9]) // Change Weather
	{
		UpdatePlayerWeather(playerid);
		ShowBrowseMenu(playerid, 1, true);

		pBrowsing[playerid] = 3;
	}
	for(new row = 0; row < 3; row++)
	{
		for(new response = 0; response < 2; response++)
		{
			if(playertextid == browse_Arrow[playerid][row][response])
			{
				switch(row)
				{
					case 0:
					{
						switch(pBrowsing[playerid])
						{
							case 0: return 1;
							case 1:
							{
								if(!response) pVehModel[playerid] -= 1;
								else pVehModel[playerid] += 1;

								UpdatePlayerVehicleBrowserMode(playerid,true);
								SpawnPlayerVehicle(playerid);
							}
							case 2:
							{
								if(!response) pTime[playerid][0] -= 1;
								else pTime[playerid][0] += 1;

								UpdatePlayerTime(playerid);
							}
							case 3:
							{
								if(!response) pWeather[playerid] -= 1;
								else pWeather[playerid] += 1;

								UpdatePlayerWeather(playerid);
							}
						}
					}
					case 1:
					{
						switch(pBrowsing[playerid])
						{
							case 0: return 1;
							case 1:
							{
								if(!response) pVehColour[playerid][0] -= 1;
								else pVehColour[playerid][0] += 1;

								UpdatePlayerVehicleBrowserMode(playerid,true);

								new colour[2];
								colour[0] = pVehColour[playerid][0];
								colour[1] = pVehColour[playerid][1];

								ChangeVehicleColor(pVehID[playerid], colour[0], colour[1]);
							}
							case 2:
							{
								if(!response) pTime[playerid][1] -= 1;
								else pTime[playerid][1] += 1;

								UpdatePlayerTime(playerid);
							}
						}
					}
					case 2:
					{
						switch(pBrowsing[playerid])
						{
							case 0: return 1;
							case 1:
							{
								if(!response) pVehColour[playerid][1] -= 1;
								else pVehColour[playerid][1] += 1;

								UpdatePlayerVehicleBrowserMode(playerid,true);

								new colour[2];
								colour[0] = pVehColour[playerid][0];
								colour[1] = pVehColour[playerid][1];

								ChangeVehicleColor(pVehID[playerid], colour[0], colour[1]);
							}
						}
					}
				}
			}
		}
	}
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

public OnPlayerDeath(playerid, killerid, reason)
{
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
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

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}
