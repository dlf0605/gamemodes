/******************************************************************************/
#include <a_samp>
#include <foreach>
#include <ZCMD>
#include <sscanf2>
#include <progress>
#include <camspecfix>
/******************************************************************************/
#include "../ripple/configuration.pwn"
#include "../ripple/variables.pwn"
#include "../ripple/functions.pwn"
#include "../ripple/commands.pwn"
/******************************************************************************/
main()
{
  return 1;
}

public OnGameModeInit()
{
	InitializeDatabase();

	SetTimer("GameCount", 1000, true);
	SetTimer("UpdateFirstPerson", 200, true);

	SendRconCommand("hostname Ripple TDM");
	DisableInteriorEnterExits( );
	UsePlayerPedAnims( );
	EnableStuntBonusForAll(0);
	AddPlayerClass(0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);

	for(new playerid = 0; playerid < MAX_PLAYERS; playerid++)
	{
		ResetPlayerVariables(playerid);
	}

	for(new vehicleid = 0; vehicleid < sizeof(vehInfo); vehicleid++)
	{
		new type, model, Float:x, Float:y, Float:z, Float:rz;
		type = vehInfo[vehicleid][vehType];
		x = vehInfo[vehicleid][vehX];
		y = vehInfo[vehicleid][vehY];
		z = vehInfo[vehicleid][vehZ];
		rz = vehInfo[vehicleid][vehRZ];

		switch(type)
		{
			case 0:// Car
			{
				z += 1;
				switch(random(2))
				{
				    case 0: model = 470;// Patriot
				    case 1: model = 568;// Bandito
				}
			}
			case 1:// Bike
			{
				switch(random(2))
				{
					case 0: model = 468;// Sanchez
					case 1: model = 471;// Quad
				}
			}
			case 2:// Helicopter
			{
				z += 2;
				switch(random(2))
				{
					case 0: model = 548;// Cargobob
					case 1: model = 425;// Hunter
					case 2: model = 520;// Hydra
				}
			}
			case 3:// Airplane
			{
				z += 1;
				switch(random(2))
				{
					case 0: model = 476;// Rustler
					case 1: model = 520;// Hydra
				}
			}
			case 4:// Boat
			{
				switch(random(3))
				{
					case 0: model = 473;// Dinghy
					case 1: model = 595;// Launch
					case 2: model = 447;// Sea Sparrow
				}
			}
			case 5:// Big vehicles
			{
				z += 1;
				switch(random(2))
				{
					case 0: model = 433;// Barracks
					case 1: model = 455;// Flatbed
				}
			}
		}
		CreateVehicle(model, x, y, z, rz, 110, 110, 120);
	}

	if(GetMaxPlayers() > MAX_PLAYERS) printf("WARNING: SERVERSLOTS MUST BE LOWERED FROM %i TO %i!",GetMaxPlayers(),MAX_PLAYERS);
	StartGame( random(sizeof(MapNames)), random(sizeof(ModeInfo)) );

	text_Time =
	TextDrawCreate			(578.000000, 22.000000, "00:00");
	TextDrawAlignment		(text_Time, 2);
	TextDrawBackgroundColor	(text_Time, 255);
	TextDrawFont			(text_Time, 3);
	TextDrawLetterSize		(text_Time, 0.569999, 2.300000);
	TextDrawColor			(text_Time, -1);
	TextDrawSetOutline		(text_Time, 1);
	TextDrawSetProportional	(text_Time, 0);
	TextDrawSetSelectable	(text_Time, 0);

	print("Ripple TDM Initialized");
	return 1;
}

public OnGameModeExit()
{
	db_close(database);
	//SetGameState(5);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	SetTimerEx("PublicSpawn", 1, false, "i", playerid);
	return 1;
}

public OnPlayerConnect(playerid)
{
	new name[MAX_PLAYER_NAME], string[128];
	GetPlayerName(playerid,name,sizeof(name));

	format(string,sizeof(string),"%s has joined!", name);
	SendClientMessageToAll(COLOR_GREY,string);

	if(IsPlayerRegistered(playerid))
	{
		format(string,sizeof(string),""C_WHITE"Welcome back %s!\nPlease enter your password to login to your account.",name);
		ShowPlayerDialog(playerid,DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""C_WHITE"Login", string, "Login", "");
	}
	else
	{
		format(string,sizeof(string),""C_WHITE"Welcome %s!\nPlease enter a password to register your new account.",name);
		ShowPlayerDialog(playerid,DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, ""C_WHITE"Register", string, "Register", "");
	}

	TogglePlayerGame(playerid, false);

	TD_Objective[playerid] =
	CreatePlayerTextDraw			(playerid,390.000000, 360.000000, "Objective");
	PlayerTextDrawAlignment			(playerid,TD_Objective[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid,TD_Objective[playerid], 255);
	PlayerTextDrawFont				(playerid,TD_Objective[playerid], 1);
	PlayerTextDrawLetterSize		(playerid,TD_Objective[playerid], 0.500000, 1.699999);
	PlayerTextDrawColor				(playerid,TD_Objective[playerid], -1);
	PlayerTextDrawSetOutline		(playerid,TD_Objective[playerid], 0);
	PlayerTextDrawSetProportional	(playerid,TD_Objective[playerid], 1);
	PlayerTextDrawSetShadow			(playerid,TD_Objective[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid,TD_Objective[playerid], 0);


	TD_Hitmarker[playerid] =
	CreatePlayerTextDraw			(playerid,340.000000, 167.000000, "X");
	PlayerTextDrawAlignment			(playerid,TD_Hitmarker[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid,TD_Hitmarker[playerid], 255);
	PlayerTextDrawFont				(playerid,TD_Hitmarker[playerid], 2);
	PlayerTextDrawLetterSize		(playerid,TD_Hitmarker[playerid], 0.509999, 2.299999);
	PlayerTextDrawColor				(playerid,TD_Hitmarker[playerid], -1);
	PlayerTextDrawSetOutline		(playerid,TD_Hitmarker[playerid], 0);
	PlayerTextDrawSetProportional	(playerid,TD_Hitmarker[playerid], 1);
	PlayerTextDrawSetShadow			(playerid,TD_Hitmarker[playerid], 0);
	PlayerTextDrawSetSelectable		(playerid,TD_Hitmarker[playerid], 0);


	TD_InfoBox[playerid] =
	CreatePlayerTextDraw			(playerid,570.000000, 1.000000, "~~");
	PlayerTextDrawAlignment			(playerid,TD_InfoBox[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid,TD_InfoBox[playerid], 255);
	PlayerTextDrawFont				(playerid,TD_InfoBox[playerid], 1);
	PlayerTextDrawLetterSize		(playerid,TD_InfoBox[playerid], 0.500000, 1.200000);
	PlayerTextDrawColor				(playerid,TD_InfoBox[playerid], -1);
	PlayerTextDrawSetOutline		(playerid,TD_InfoBox[playerid], 0);
	PlayerTextDrawSetProportional	(playerid,TD_InfoBox[playerid], 1);
	PlayerTextDrawSetShadow			(playerid,TD_InfoBox[playerid], 1);
	PlayerTextDrawUseBox			(playerid,TD_InfoBox[playerid], 1);
	PlayerTextDrawBoxColor			(playerid,TD_InfoBox[playerid], 150);
	PlayerTextDrawTextSize			(playerid,TD_InfoBox[playerid], 0.000000, -143.000000);
	PlayerTextDrawSetSelectable		(playerid,TD_InfoBox[playerid], 0);


	TD_InfoFPS[playerid] =
	CreatePlayerTextDraw			(playerid,502.000000, 2.000000, "FPS");
	PlayerTextDrawBackgroundColor	(playerid,TD_InfoFPS[playerid], 255);
	PlayerTextDrawFont				(playerid,TD_InfoFPS[playerid], 1);
	PlayerTextDrawLetterSize		(playerid,TD_InfoFPS[playerid], 0.200000, 1.000000);
	PlayerTextDrawColor				(playerid,TD_InfoFPS[playerid], -1);
	PlayerTextDrawSetOutline		(playerid,TD_InfoFPS[playerid], 1);
	PlayerTextDrawSetProportional	(playerid,TD_InfoFPS[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid,TD_InfoFPS[playerid], 0);


	TD_InfoPing[playerid] =
	CreatePlayerTextDraw			(playerid,538.000000, 2.000000, "Ping");
	PlayerTextDrawBackgroundColor	(playerid,TD_InfoPing[playerid], 255);
	PlayerTextDrawFont				(playerid,TD_InfoPing[playerid], 1);
	PlayerTextDrawLetterSize		(playerid,TD_InfoPing[playerid], 0.200000, 1.000000);
	PlayerTextDrawColor				(playerid,TD_InfoPing[playerid], -1);
	PlayerTextDrawSetOutline		(playerid,TD_InfoPing[playerid], 1);
	PlayerTextDrawSetProportional	(playerid,TD_InfoPing[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid,TD_InfoPing[playerid], 0);


	TD_InfoLoss[playerid] =
	CreatePlayerTextDraw			(playerid,577.000000, 2.000000, "Packetloss");
	PlayerTextDrawBackgroundColor	(playerid,TD_InfoLoss[playerid], 255);
	PlayerTextDrawFont				(playerid,TD_InfoLoss[playerid], 1);
	PlayerTextDrawLetterSize		(playerid,TD_InfoLoss[playerid], 0.200000, 1.000000);
	PlayerTextDrawColor				(playerid,TD_InfoLoss[playerid], -1);
	PlayerTextDrawSetOutline		(playerid,TD_InfoLoss[playerid], 1);
	PlayerTextDrawSetProportional	(playerid,TD_InfoLoss[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid,TD_InfoLoss[playerid], 0);


	TD_UserBackground[playerid] =
	CreatePlayerTextDraw			(playerid,59.000000, 314.000000, "~~");
	PlayerTextDrawAlignment			(playerid,TD_UserBackground[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid,TD_UserBackground[playerid], 255);
	PlayerTextDrawFont				(playerid,TD_UserBackground[playerid], 1);
	PlayerTextDrawLetterSize		(playerid,TD_UserBackground[playerid], 0.500000, 14.700005);
	PlayerTextDrawColor				(playerid,TD_UserBackground[playerid], -1);
	PlayerTextDrawSetOutline		(playerid,TD_UserBackground[playerid], 0);
	PlayerTextDrawSetProportional	(playerid,TD_UserBackground[playerid], 1);
	PlayerTextDrawSetShadow			(playerid,TD_UserBackground[playerid], 1);
	PlayerTextDrawUseBox			(playerid,TD_UserBackground[playerid], 1);
	PlayerTextDrawBoxColor			(playerid,TD_UserBackground[playerid], 150);
	PlayerTextDrawTextSize			(playerid,TD_UserBackground[playerid], 0.000000, 116.000000);
	PlayerTextDrawSetSelectable		(playerid,TD_UserBackground[playerid], 0);

	for(new text = 0; text < sizeof(TD_UserButton[]); text++)
	{
		new TextStr[30];
		switch(text)
		{
		    case 0: TextStr = "~g~> ~w~Choose Team";
		    case 1: TextStr = "~y~> ~w~Edit Loadout";
		    case 2: TextStr = "~y~> ~w~View Stats";
		    case 3: TextStr = "~r~> ~w~Reset Stats";
		    case 4: TextStr = "~r~> ~w~Edit Name";
			case 5: TextStr = "~r~> ~w~Edit Password";
		}

		TD_UserButton[playerid][text] =
		CreatePlayerTextDraw			(playerid,3.000000, 315.00 + (20.00 * text), TextStr);
		PlayerTextDrawBackgroundColor	(playerid,TD_UserButton[playerid][text], 255);
		PlayerTextDrawFont				(playerid,TD_UserButton[playerid][text], 1);
		PlayerTextDrawLetterSize		(playerid,TD_UserButton[playerid][text], 0.389999, 1.899999);
		PlayerTextDrawColor				(playerid,TD_UserButton[playerid][text], -1);
		PlayerTextDrawSetOutline		(playerid,TD_UserButton[playerid][text], 1);
		PlayerTextDrawSetProportional	(playerid,TD_UserButton[playerid][text], 1);
		PlayerTextDrawSetSelectable		(playerid,TD_UserButton[playerid][text], 1);
        PlayerTextDrawTextSize			(playerid,TD_UserButton[playerid][text], 120.0, 15.0);
	}


	TD_SpecUser[playerid] =
	CreatePlayerTextDraw			(playerid,320.000000, 400.000000, "User");
	PlayerTextDrawAlignment			(playerid,TD_SpecUser[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid,TD_SpecUser[playerid], 255);
	PlayerTextDrawFont				(playerid,TD_SpecUser[playerid], 1);
	PlayerTextDrawLetterSize		(playerid,TD_SpecUser[playerid], 0.430000, 1.799999);
	PlayerTextDrawColor				(playerid,TD_SpecUser[playerid], -16776961);
	PlayerTextDrawSetOutline		(playerid,TD_SpecUser[playerid], 1);
	PlayerTextDrawSetProportional	(playerid,TD_SpecUser[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid,TD_SpecUser[playerid], 0);


	TD_Zone[playerid][0] =
	CreatePlayerTextDraw			(playerid,320.00, 1.000000, "~~");
	PlayerTextDrawAlignment			(playerid,TD_Zone[playerid][0], 2);
	PlayerTextDrawBackgroundColor	(playerid,TD_Zone[playerid][0], 255);
	PlayerTextDrawFont				(playerid,TD_Zone[playerid][0], 1);
	PlayerTextDrawLetterSize		(playerid,TD_Zone[playerid][0], 0.500000, 49.499961);
	PlayerTextDrawColor				(playerid,TD_Zone[playerid][0], -1);
	PlayerTextDrawSetOutline		(playerid,TD_Zone[playerid][0], 0);
	PlayerTextDrawSetProportional	(playerid,TD_Zone[playerid][0], 1);
	PlayerTextDrawSetShadow			(playerid,TD_Zone[playerid][0], 1);
	PlayerTextDrawUseBox			(playerid,TD_Zone[playerid][0], 1);
	PlayerTextDrawBoxColor			(playerid,TD_Zone[playerid][0], 150);
	PlayerTextDrawTextSize			(playerid,TD_Zone[playerid][0], 0.000000, 638.000000);
	PlayerTextDrawSetSelectable		(playerid,TD_Zone[playerid][0], 0);

	TD_Zone[playerid][1] =
	CreatePlayerTextDraw			(playerid,320.00, 90.00, ""WARNING_MSG"");
	PlayerTextDrawAlignment			(playerid,TD_Zone[playerid][1], 2);
	PlayerTextDrawBackgroundColor	(playerid,TD_Zone[playerid][1], 255);
	PlayerTextDrawFont				(playerid,TD_Zone[playerid][1], 2);
	PlayerTextDrawLetterSize		(playerid,TD_Zone[playerid][1], 0.400000, 2.399999);
	PlayerTextDrawColor				(playerid,TD_Zone[playerid][1], -16776961);
	PlayerTextDrawSetOutline		(playerid,TD_Zone[playerid][1], 0);
	PlayerTextDrawSetProportional	(playerid,TD_Zone[playerid][1], 1);
	PlayerTextDrawSetShadow			(playerid,TD_Zone[playerid][1], 1);
	PlayerTextDrawSetSelectable		(playerid,TD_Zone[playerid][1], 0);

	TD_Zone[playerid][2] =
	CreatePlayerTextDraw			(playerid,320.00 - 115.00, 90.00 - 41.00, "(");
	PlayerTextDrawAlignment			(playerid,TD_Zone[playerid][2], 2);
	PlayerTextDrawBackgroundColor	(playerid,TD_Zone[playerid][2], 255);
	PlayerTextDrawFont				(playerid,TD_Zone[playerid][2], 2);
	PlayerTextDrawLetterSize		(playerid,TD_Zone[playerid][2], 1.800000, 14.399999);
	PlayerTextDrawColor				(playerid,TD_Zone[playerid][2], -16776961);
	PlayerTextDrawSetOutline		(playerid,TD_Zone[playerid][2], 0);
	PlayerTextDrawSetProportional	(playerid,TD_Zone[playerid][2], 1);
	PlayerTextDrawSetShadow			(playerid,TD_Zone[playerid][2], 1);
	PlayerTextDrawSetSelectable		(playerid,TD_Zone[playerid][2], 0);

	TD_Zone[playerid][3] =
	CreatePlayerTextDraw			(playerid,320.00 + 120.00, 90.00 - 41.00, ")");
	PlayerTextDrawAlignment			(playerid,TD_Zone[playerid][3], 2);
	PlayerTextDrawBackgroundColor	(playerid,TD_Zone[playerid][3], 255);
	PlayerTextDrawFont				(playerid,TD_Zone[playerid][3], 2);
	PlayerTextDrawLetterSize		(playerid,TD_Zone[playerid][3], 1.800000, 14.399999);
	PlayerTextDrawColor				(playerid,TD_Zone[playerid][3], -16776961);
	PlayerTextDrawSetOutline		(playerid,TD_Zone[playerid][3], 0);
	PlayerTextDrawSetProportional	(playerid,TD_Zone[playerid][3], 1);
	PlayerTextDrawSetShadow			(playerid,TD_Zone[playerid][3], 1);
	PlayerTextDrawSetSelectable		(playerid,TD_Zone[playerid][3], 0);


	TD_StatsTitle[playerid] =
	CreatePlayerTextDraw			(playerid,260.000000, 142.000000, "Stats");
	PlayerTextDrawBackgroundColor	(playerid,TD_StatsTitle[playerid], 255);
	PlayerTextDrawFont				(playerid,TD_StatsTitle[playerid], 1);
	PlayerTextDrawLetterSize		(playerid,TD_StatsTitle[playerid], 0.430000, 1.200000);
	PlayerTextDrawColor				(playerid,TD_StatsTitle[playerid], -1);
	PlayerTextDrawSetOutline		(playerid,TD_StatsTitle[playerid], 1);
	PlayerTextDrawSetProportional	(playerid,TD_StatsTitle[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid,TD_StatsTitle[playerid], 0);

	TD_StatsBackGround[playerid] =
	CreatePlayerTextDraw			(playerid,320.000000, 144.000000, "~~");
	PlayerTextDrawAlignment			(playerid,TD_StatsBackGround[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid,TD_StatsBackGround[playerid], 255);
	PlayerTextDrawFont				(playerid,TD_StatsBackGround[playerid], 1);
	PlayerTextDrawLetterSize		(playerid,TD_StatsBackGround[playerid], 0.500000, 14.299983);
	PlayerTextDrawColor				(playerid,TD_StatsBackGround[playerid], -1);
	PlayerTextDrawSetOutline		(playerid,TD_StatsBackGround[playerid], 0);
	PlayerTextDrawSetProportional	(playerid,TD_StatsBackGround[playerid], 1);
	PlayerTextDrawSetShadow			(playerid,TD_StatsBackGround[playerid], 1);
	PlayerTextDrawUseBox			(playerid,TD_StatsBackGround[playerid], 1);
	PlayerTextDrawBoxColor			(playerid,TD_StatsBackGround[playerid], 150);
	PlayerTextDrawTextSize			(playerid,TD_StatsBackGround[playerid], 0.000000, 120.000000);
	PlayerTextDrawSetSelectable		(playerid,TD_StatsBackGround[playerid], 0);

	TD_StatsClose[playerid] =
	CreatePlayerTextDraw			(playerid,375.000000, 142.000000, "X");
	PlayerTextDrawAlignment			(playerid,TD_StatsClose[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid,TD_StatsClose[playerid], 255);
	PlayerTextDrawFont				(playerid,TD_StatsClose[playerid], 1);
	PlayerTextDrawLetterSize		(playerid,TD_StatsClose[playerid], 0.500000, 1.000000);
	PlayerTextDrawColor				(playerid,TD_StatsClose[playerid], -1);
	PlayerTextDrawSetOutline		(playerid,TD_StatsClose[playerid], 1);
	PlayerTextDrawSetProportional	(playerid,TD_StatsClose[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid,TD_StatsClose[playerid], 1);
    PlayerTextDrawTextSize          (playerid,TD_StatsClose[playerid], 10.0, 10.0);

	for(new textid = 0; textid < sizeof(TD_StatsField[]); textid++)
	{
	    new str[20];
	    switch(textid)
		{
		    case 0: str = "Player";
		    case 1: str = "Level";
		    case 2: str = "Kills";
		    case 3: str = "Deaths";
			case 4: str = "K/D Ratio";
			case 5: str = "Won Games";
			case 6: str = "Lost Games";
			case 7: str = "W/L Ratio";
			default: str = "Unknown";
		}
		TD_StatsField[playerid][textid][0] =
		CreatePlayerTextDraw			(playerid,261.000000, 155.00 + (textid * 15.00), str);
		PlayerTextDrawBackgroundColor	(playerid,TD_StatsField[playerid][textid][0], 255);
		PlayerTextDrawFont				(playerid,TD_StatsField[playerid][textid][0], 1);
		PlayerTextDrawLetterSize		(playerid,TD_StatsField[playerid][textid][0], 0.250000, 1.399999);
		PlayerTextDrawColor				(playerid,TD_StatsField[playerid][textid][0], -1);
		PlayerTextDrawSetOutline		(playerid,TD_StatsField[playerid][textid][0], 1);
		PlayerTextDrawSetProportional	(playerid,TD_StatsField[playerid][textid][0], 1);
		PlayerTextDrawSetSelectable		(playerid,TD_StatsField[playerid][textid][0], 0);

		TD_StatsField[playerid][textid][1] =
		CreatePlayerTextDraw			(playerid,379.000000, 155.00 + (textid * 15.00), str);
		PlayerTextDrawAlignment			(playerid,TD_StatsField[playerid][textid][1], 3);
		PlayerTextDrawBackgroundColor	(playerid,TD_StatsField[playerid][textid][1], 255);
		PlayerTextDrawFont				(playerid,TD_StatsField[playerid][textid][1], 1);
		PlayerTextDrawLetterSize		(playerid,TD_StatsField[playerid][textid][1], 0.250000, 1.399999);
		PlayerTextDrawColor				(playerid,TD_StatsField[playerid][textid][1], -1);
		PlayerTextDrawSetOutline		(playerid,TD_StatsField[playerid][textid][1], 1);
		PlayerTextDrawSetProportional	(playerid,TD_StatsField[playerid][textid][1], 1);
		PlayerTextDrawSetSelectable		(playerid,TD_StatsField[playerid][textid][1], 0);
	}

	TD_BackGround[playerid] =
	CreatePlayerTextDraw			(playerid,320.000000, 144.000000, "~~");
	PlayerTextDrawAlignment			(playerid,TD_BackGround[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid,TD_BackGround[playerid], 255);
	PlayerTextDrawFont				(playerid,TD_BackGround[playerid], 1);
	PlayerTextDrawLetterSize		(playerid,TD_BackGround[playerid], 0.500000, 21.899986);
	PlayerTextDrawColor				(playerid,TD_BackGround[playerid], -1);
	PlayerTextDrawSetOutline		(playerid,TD_BackGround[playerid], 0);
	PlayerTextDrawSetProportional	(playerid,TD_BackGround[playerid], 1);
	PlayerTextDrawSetShadow			(playerid,TD_BackGround[playerid], 1);
	PlayerTextDrawUseBox			(playerid,TD_BackGround[playerid], 1);
	PlayerTextDrawBoxColor			(playerid,TD_BackGround[playerid], 150);
	PlayerTextDrawTextSize			(playerid,TD_BackGround[playerid], 0.000000, 270.000000);
	PlayerTextDrawSetSelectable		(playerid,TD_BackGround[playerid], 0);

	TD_Title[playerid] =
	CreatePlayerTextDraw			(playerid,184.000000, 141.000000, "Loadout Menu");
	PlayerTextDrawBackgroundColor	(playerid,TD_Title[playerid], 255);
	PlayerTextDrawFont				(playerid,TD_Title[playerid], 1);
	PlayerTextDrawLetterSize		(playerid,TD_Title[playerid], 0.430000, 1.200000);
	PlayerTextDrawColor				(playerid,TD_Title[playerid], -1);
	PlayerTextDrawSetOutline		(playerid,TD_Title[playerid], 1);
	PlayerTextDrawSetProportional	(playerid,TD_Title[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid,TD_Title[playerid], 0);


	TD_CloseButton[playerid] =
	CreatePlayerTextDraw			(playerid,450.000000, 142.000000, "X");
	PlayerTextDrawAlignment			(playerid,TD_CloseButton[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid,TD_CloseButton[playerid], 255);
	PlayerTextDrawFont				(playerid,TD_CloseButton[playerid], 1);
	PlayerTextDrawLetterSize		(playerid,TD_CloseButton[playerid], 0.500000, 1.000000);
	PlayerTextDrawColor				(playerid,TD_CloseButton[playerid], -1);
	PlayerTextDrawSetOutline		(playerid,TD_CloseButton[playerid], 1);
	PlayerTextDrawSetProportional	(playerid,TD_CloseButton[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid,TD_CloseButton[playerid], 1);
    PlayerTextDrawTextSize          (playerid,TD_CloseButton[playerid], 10.0, 10.0);

	for(new text = 0; text < 3; text++)
	{
		TD_ChoiceModel[playerid][text] =
		CreatePlayerTextDraw			(playerid,188.000000, 156.00 + (61.00 * text), "Model");
		PlayerTextDrawBackgroundColor	(playerid,TD_ChoiceModel[playerid][text], 0);
		PlayerTextDrawFont				(playerid,TD_ChoiceModel[playerid][text], 5);
		PlayerTextDrawLetterSize		(playerid,TD_ChoiceModel[playerid][text], 0.500000, 1.000000);
		PlayerTextDrawColor				(playerid,TD_ChoiceModel[playerid][text], -1);
		PlayerTextDrawSetOutline		(playerid,TD_ChoiceModel[playerid][text], 1);
		PlayerTextDrawSetProportional	(playerid,TD_ChoiceModel[playerid][text], 1);
		PlayerTextDrawUseBox			(playerid,TD_ChoiceModel[playerid][text], 1);
		PlayerTextDrawBoxColor			(playerid,TD_ChoiceModel[playerid][text], COLOR_TRANSPARENT);
		PlayerTextDrawTextSize			(playerid,TD_ChoiceModel[playerid][text], 50.000000, 60.000000);
		PlayerTextDrawSetSelectable		(playerid,TD_ChoiceModel[playerid][text], 0);

		new str[20];
		switch(text)
		{
		    case 0: str = "Primary";
		    case 1: str = "Secondary";
			case 2: str = "Explosives";
			default: str = "Unknown";
		}

		TD_ChoiceType[playerid][text] =
		CreatePlayerTextDraw			(playerid,349.000000, 156.00 + 15.00 + (61.00 * text), str);
		PlayerTextDrawAlignment			(playerid,TD_ChoiceType[playerid][text], 2);
		PlayerTextDrawBackgroundColor	(playerid,TD_ChoiceType[playerid][text], 255);
		PlayerTextDrawFont				(playerid,TD_ChoiceType[playerid][text], 3);
		PlayerTextDrawLetterSize		(playerid,TD_ChoiceType[playerid][text], 0.339999, 1.199999);
		PlayerTextDrawColor				(playerid,TD_ChoiceType[playerid][text], -1);
		PlayerTextDrawSetOutline		(playerid,TD_ChoiceType[playerid][text], 0);
		PlayerTextDrawSetProportional	(playerid,TD_ChoiceType[playerid][text], 1);
		PlayerTextDrawSetShadow			(playerid,TD_ChoiceType[playerid][text], 0);
		PlayerTextDrawSetSelectable		(playerid,TD_ChoiceType[playerid][text], 0);

		TD_ChoiceName[playerid][text] =
		CreatePlayerTextDraw			(playerid,349.000000, 156.00 + 25.00 + (61.00 * text), str);
		PlayerTextDrawAlignment			(playerid,TD_ChoiceName[playerid][text], 2);
		PlayerTextDrawBackgroundColor	(playerid,TD_ChoiceName[playerid][text], 255);
		PlayerTextDrawFont				(playerid,TD_ChoiceName[playerid][text], 1);
		PlayerTextDrawLetterSize		(playerid,TD_ChoiceName[playerid][text], 0.270000, 1.299998);
		PlayerTextDrawColor				(playerid,TD_ChoiceName[playerid][text], -1);
		PlayerTextDrawSetOutline		(playerid,TD_ChoiceName[playerid][text], 0);
		PlayerTextDrawSetProportional	(playerid,TD_ChoiceName[playerid][text], 1);
		PlayerTextDrawSetShadow			(playerid,TD_ChoiceName[playerid][text], 0);
		PlayerTextDrawSetSelectable		(playerid,TD_ChoiceName[playerid][text], 0);

		for(new ArrowID = 0; ArrowID < 2; ArrowID++)
		{
			new Float:pos;
			switch(ArrowID)
			{
			    case 0: str = "~<~", pos = 247.000000;
				case 1: str = "~>~", pos = 433.000000;
				default: str = "Unknown", pos = 0.0;
			}

			TD_SelectButton[playerid][text][ArrowID] =
			CreatePlayerTextDraw			(playerid,pos, 168.00 + (61.00 * text), str);
			PlayerTextDrawAlignment			(playerid,TD_SelectButton[playerid][text][ArrowID], 2);
			PlayerTextDrawBackgroundColor	(playerid,TD_SelectButton[playerid][text][ArrowID], 255);
			PlayerTextDrawFont				(playerid,TD_SelectButton[playerid][text][ArrowID], 1);
			PlayerTextDrawLetterSize		(playerid,TD_SelectButton[playerid][text][ArrowID], 0.409999, 2.699999);
			PlayerTextDrawColor				(playerid,TD_SelectButton[playerid][text][ArrowID], -1);
			PlayerTextDrawSetOutline		(playerid,TD_SelectButton[playerid][text][ArrowID], 0);
			PlayerTextDrawSetProportional	(playerid,TD_SelectButton[playerid][text][ArrowID], 1);
			PlayerTextDrawSetShadow			(playerid,TD_SelectButton[playerid][text][ArrowID], 0);
			PlayerTextDrawSetSelectable		(playerid,TD_SelectButton[playerid][text][ArrowID], 1);
    		PlayerTextDrawTextSize          (playerid,TD_SelectButton[playerid][text][ArrowID], 30.0, 30.0);
		}
	}

	TD_PlantBar[playerid] =
	CreatePlayerProgressBar			(playerid,290.00, 150.00, 60.00, 5.0, -1, PLANTING_TIME.0);

	TD_XPBar[playerid] =
	CreatePlayerProgressBar			(playerid,1.00, 440.00, 639.00, 7.19, -1, 100.0);
	
	TD_XPText[playerid] =
	CreatePlayerTextDraw			(playerid,320.000000, 439.000000, "XP");
	PlayerTextDrawAlignment			(playerid,TD_XPText[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid,TD_XPText[playerid], 255);
	PlayerTextDrawFont				(playerid,TD_XPText[playerid], 2);
	PlayerTextDrawLetterSize		(playerid,TD_XPText[playerid], 0.170000, 1.000000);
	PlayerTextDrawColor				(playerid,TD_XPText[playerid], 255);
	PlayerTextDrawSetOutline		(playerid,TD_XPText[playerid], 0);
	PlayerTextDrawSetProportional	(playerid,TD_XPText[playerid], 1);
	PlayerTextDrawSetShadow			(playerid,TD_XPText[playerid], 0);
	PlayerTextDrawSetSelectable		(playerid,TD_XPText[playerid], 0);


	TD_XPTempText[playerid] =
	CreatePlayerTextDraw			(playerid,320.000000, 140.000000, "+1");
	PlayerTextDrawAlignment			(playerid,TD_XPTempText[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid,TD_XPTempText[playerid], 255);
	PlayerTextDrawFont				(playerid,TD_XPTempText[playerid], 3);
	PlayerTextDrawLetterSize		(playerid,TD_XPTempText[playerid], 0.529999, 2.399998);
	PlayerTextDrawColor				(playerid,TD_XPTempText[playerid], -1);
	PlayerTextDrawSetOutline		(playerid,TD_XPTempText[playerid], 1);
	PlayerTextDrawSetProportional	(playerid,TD_XPTempText[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid,TD_XPTempText[playerid], 0);
	

	TD_UserTip[playerid] =
	CreatePlayerTextDraw			(playerid,3.000000, 439.000000, "KEYSTROKE");
	PlayerTextDrawBackgroundColor	(playerid,TD_UserTip[playerid], 255);
	PlayerTextDrawFont				(playerid,TD_UserTip[playerid], 2);
	PlayerTextDrawLetterSize		(playerid,TD_UserTip[playerid], 0.170000, 1.000000);
	PlayerTextDrawColor				(playerid,TD_UserTip[playerid], 255);
	PlayerTextDrawSetOutline		(playerid,TD_UserTip[playerid], 0);
	PlayerTextDrawSetProportional	(playerid,TD_UserTip[playerid], 1);
	PlayerTextDrawSetShadow			(playerid,TD_UserTip[playerid], 0);
	PlayerTextDrawSetSelectable		(playerid,TD_UserTip[playerid], 0);


	TD_Score[playerid] =
	CreatePlayerTextDraw			(playerid, 637.000000, 439.000000, "SCORE");
	PlayerTextDrawAlignment			(playerid, TD_Score[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, TD_Score[playerid], 255);
	PlayerTextDrawFont				(playerid, TD_Score[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, TD_Score[playerid], 0.170000, 1.000000);
	PlayerTextDrawColor				(playerid, TD_Score[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, TD_Score[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, TD_Score[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, TD_Score[playerid], 0);
	PlayerTextDrawSetSelectable		(playerid, TD_Score[playerid], 0);


	TD_TeamBackGround[playerid] =
	CreatePlayerTextDraw			(playerid, 320.000000, 168.000000, "~~");
	PlayerTextDrawAlignment			(playerid, TD_TeamBackGround[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, TD_TeamBackGround[playerid], 255);
	PlayerTextDrawFont				(playerid, TD_TeamBackGround[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, TD_TeamBackGround[playerid], 0.500000, 5.999996);
	PlayerTextDrawColor				(playerid, TD_TeamBackGround[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, TD_TeamBackGround[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, TD_TeamBackGround[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, TD_TeamBackGround[playerid], 1);
	PlayerTextDrawUseBox			(playerid, TD_TeamBackGround[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, TD_TeamBackGround[playerid], 150);
	PlayerTextDrawTextSize			(playerid, TD_TeamBackGround[playerid], 0.000000, 104.000000);
	PlayerTextDrawSetSelectable		(playerid, TD_TeamBackGround[playerid], 0);

	TD_TeamTitle[playerid] =
	CreatePlayerTextDraw			(playerid, 268.000000, 166.000000, "Choose Team");
	PlayerTextDrawBackgroundColor	(playerid, TD_TeamTitle[playerid], 255);
	PlayerTextDrawFont				(playerid, TD_TeamTitle[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, TD_TeamTitle[playerid], 0.330000, 1.100000);
	PlayerTextDrawColor				(playerid, TD_TeamTitle[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, TD_TeamTitle[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, TD_TeamTitle[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid, TD_TeamTitle[playerid], 0);

	TD_TeamClose[playerid] =
	CreatePlayerTextDraw			(playerid, 368.000000, 165.000000, "x");
	PlayerTextDrawAlignment			(playerid, TD_TeamClose[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, TD_TeamClose[playerid], 255);
	PlayerTextDrawFont				(playerid, TD_TeamClose[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, TD_TeamClose[playerid], 0.370000, 1.100000);
	PlayerTextDrawColor				(playerid, TD_TeamClose[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, TD_TeamClose[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, TD_TeamClose[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid, TD_TeamClose[playerid], 1);
	PlayerTextDrawTextSize			(playerid, TD_TeamClose[playerid], 10.0, 10.0);

	for(new text = 0; text < 3; text++)
	{
		new str[20];
		switch(text)
		{
			case 0: str = "> Terrorist";
			case 1: str = "> Counter-Terrorist";
			case 2: str = "> Spectator";
			default: str = "Unknown";
		}
		TD_Team[playerid][text] =
		CreatePlayerTextDraw			(playerid, 269.000000, 178.00 + (13.00 * text), str);
		PlayerTextDrawBackgroundColor	(playerid, TD_Team[playerid][text], 255);
		PlayerTextDrawFont				(playerid, TD_Team[playerid][text], 1);
		PlayerTextDrawLetterSize		(playerid, TD_Team[playerid][text], 0.270000, 1.500000);
		PlayerTextDrawColor				(playerid, TD_Team[playerid][text], -1);
		PlayerTextDrawSetOutline		(playerid, TD_Team[playerid][text], 1);
		PlayerTextDrawSetProportional	(playerid, TD_Team[playerid][text], 1);
		PlayerTextDrawSetSelectable		(playerid, TD_Team[playerid][text], 1);
		PlayerTextDrawTextSize			(playerid, TD_Team[playerid][text], 269 + 100.0, 10.00);
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new string[128], name[MAX_PLAYER_NAME+1];
	GetPlayerName(playerid, name, sizeof(name));

	switch(reason)
	{
		case 0:format(string,sizeof(string),"%s has left the server (Lost connection)", name);
		case 1:format(string,sizeof(string),"%s has left the server (Quit)", name);
		case 2:format(string,sizeof(string),"%s has left the server (Kicked)", name);
	}
	SendClientMessageToAll(COLOR_GREY,string);

	SavePlayer(playerid);
	ResetPlayerVariables(playerid);
	foreach(new i : Player)
	{
	    if(pDeath[i][0] == playerid)
		{
			pDeath[i][0] = -1;
			pDeath[i][1] = -1;
		}
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	pDeath[playerid][0] = -1;
	pDeath[playerid][1] = -1;
	PreloadAnimLib(playerid, "BOMBER");

	new Float:x, Float:y, Float:z, Float:a, interior;
	switch(GameInfo[gState])
	{
		case 1,2:// Game Not Started Yet
		{
			TogglePlayerControllable(playerid,0);
			if(GameInfo[gMode] == 1)
			{
				x = MapSpawns[GameInfo[gMap]][playerid][0];
				y = MapSpawns[GameInfo[gMap]][playerid][1];
				z = MapSpawns[GameInfo[gMap]][playerid][2];
				a = MapSpawns[GameInfo[gMap]][playerid][3];
				interior = floatround(MapSpawns[GameInfo[gMap]][playerid][4]);
			}
			else// Team vs Team
			{
				x = MapSpawns[GameInfo[gMap]][pTeam[playerid]][0] + ( (0.2*random(30)) - (0.2*random(30)) );
				y = MapSpawns[GameInfo[gMap]][pTeam[playerid]][1] + ( (0.2*random(30)) - (0.2*random(30)) );
				z = MapSpawns[GameInfo[gMap]][pTeam[playerid]][2];
				a = MapSpawns[GameInfo[gMap]][pTeam[playerid]][3] + (random(45) - random(45));
				interior = floatround(MapSpawns[GameInfo[gMap]][pTeam[playerid]][4]);
			}
		}
		case 3: // Mid-game
		{
			new spawn = GetBestSpawnPoint();
			x = MapSpawns[GameInfo[gMap]][spawn][0] + ( (0.2*random(30)) - (0.2*random(30)) );
			y = MapSpawns[GameInfo[gMap]][spawn][1] + ( (0.2*random(30)) - (0.2*random(30)) );
			z = MapSpawns[GameInfo[gMap]][spawn][2];
			a = MapSpawns[GameInfo[gMap]][spawn][3] + (random(45) - random(45));
			interior = floatround(MapSpawns[GameInfo[gMap]][spawn][4]);
		}
	}

	SetPlayerSkin(playerid, pSkin[playerid]);
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, a);
	SetPlayerInterior(playerid, interior);
	SetCameraBehindPlayer(playerid);
	SetPlayerMarkerForPlayer(playerid, playerid, COLOR_GREEN);

	new weaponid, ammo, weplevel, level, id, name[MAX_PLAYER_NAME];
	GetPlayerName(playerid,name,sizeof(name));
	level = XpToLevel(pXP[playerid]);

	ResetPlayerWeapons(playerid);
	GivePlayerWeapon(playerid,46,1);//Parachute

	for(new slot = 0; slot < 3; slot++)
	{
		id = pChoice[playerid][slot];
		weaponid = ChoiceModels[slot][id][eModel];
		weplevel = ChoiceModels[slot][id][eMinLvl];

		switch(weaponid)
	    {
			case 22: ammo = 17;//Colt
			case 23: ammo = 17;//Silenced Colt
			case 24: ammo = 7;//Desert Eagle
			case 26: ammo = 2;//Sawnoff
			case 27: ammo = 7;//Spas
			case 28: ammo = 50;//Uzi
			case 29: ammo = 30;//MP5
			case 30: ammo = 30;//AK-47
			case 31: ammo = 50;//M4
			case 32: ammo = 50;//Tec-9
			case 33: ammo = 5;//Rifle
			case 34: ammo = 5;//Sniper Rifle
			default: ammo = 1;
		}
		if(level >= weplevel) GivePlayerWeapon(playerid,weaponid,ammo * 5);
	}

	SetPlayerHealthEx(playerid,100);
	SetPlayerArmourEx(playerid,100);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(pDeath[playerid][1] != -1) reason = pDeath[playerid][1];
	if(IsPlayerConnected(pDeath[playerid][0]))
	{
		killerid = pDeath[playerid][0];
		pKills[killerid]++;
	}
	pDeaths[playerid]++;

	SendDeathMessage(killerid, playerid, reason);
	if(IsPlayerConnected(killerid))
	{
		new deathstring[128], wepname[32], name[MAX_PLAYER_NAME+1],
		Float:distance,	Float:health, Float:armour, Float:totalhealth;

		health = pHP[killerid][0];
		armour = pHP[killerid][1];
		totalhealth = health + armour;

		GetDistanceFromPlayerToPlayer(playerid,killerid,distance);
		distance = distance / 3.28;

		format(wepname,sizeof(wepname),"%s",GetWeaponNameEx(reason));

		GetPlayerName(playerid, name, sizeof(name));
		format(deathstring,sizeof(deathstring),"You have killed %s | %s | %.02f M | +%i", name, wepname, distance, floatround(totalhealth));
		SendClientMessage(killerid,COLOR_WHITE,deathstring);

		GetPlayerName(killerid, name, sizeof(name));
		format(deathstring,sizeof(deathstring),"You got killed by %s | %s | %.02f M | +%i", name, wepname, distance, floatround(totalhealth));
		SendClientMessage(playerid,COLOR_WHITE,deathstring);

		GivePlayerXP(killerid,true,1.0);
	}

	CreateAmmoPickup(playerid);
	if(GameInfo[gState] > 2 && GameInfo[gState] < 5)
	{
		switch(GameInfo[gMode])
		{
			case 0: GiveTeamScore(pTeam[killerid]); // TDM
			case 1: GiveTeamScore(killerid); // DM
			case 2:// S&D
			{
				TogglePlayerGame(playerid, false);

				new alive;
				foreach(new players : Player)
				{
					if(players != playerid && IsPlayerSpawned(players) && pTeam[players] == pTeam[playerid])
						alive++;
				}

				if(alive == 0)
				{
					if((pTeam[playerid] == 0 && GameInfo[gState] != 4) || pTeam[playerid] == 1)
						SetGameState(5);
				}
			}
			case 3: CreateDataPickup(playerid); // K&C
		}
	}
	return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float:amount, weaponid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) return 1;
	DealPlayerDamage(damagedid,playerid,amount,weaponid);
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid)
{
	if(weaponid == 49 || weaponid == 53 || weaponid == 54 || weaponid == 51 || weaponid == 37 || (GetPlayerState(issuerid) == PLAYER_STATE_DRIVER && IsPlayerConnected(issuerid)) )
	{
		DealPlayerDamage(playerid,issuerid,amount,weaponid);
	}
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

public OnPlayerEditObject(playerid, playerobject, objectid, response, Float:fX, Float:fY, Float:fZ, Float:fRotX, Float:fRotY, Float:fRotZ)
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
    return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
    return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	switch(newstate)
	{
		case PLAYER_STATE_DRIVER, PLAYER_STATE_PASSENGER:
	    {
			if(newstate == PLAYER_STATE_DRIVER) SetPlayerArmedWeapon(playerid, 0);

			new vehicleid = GetPlayerVehicleID(playerid);
			foreach(new spectator : Player)
			{
				if(IsPlayerSpectating(spectator) && pSpecID[spectator] == playerid)
				{
					PlayerSpectateVehicle(spectator,vehicleid);
				}
			}
	    }
	    case PLAYER_STATE_ONFOOT:
	    {
			foreach(new spectator : Player)
			{
				if(IsPlayerSpectating(spectator) && pSpecID[spectator] == playerid)
				{
					PlayerSpectatePlayer(spectator,playerid);
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

public OnPlayerPickUpPickup(playerid, pickupid)
{
	PlayerPlaySound(playerid, 1150, 0.0, 0.0, 0.0);

	if(pickupid == gBombPickup && pTeam[playerid] == 0)
	{
		BombInteraction(1, playerid);
		return 1;
	}

	foreach(new players : Player)
	{
		if(pickupid == pWepPickup[players])
		{
			new level = XpToLevel(pXP[playerid]);
			for(new slot = 0; slot < 13; slot++)
			{
				switch(slot) {case 0,1,7,10,11,12: continue;}
				new id, weaponid, weaponlevel, weaponslot, ammo, string[128];

				for(new weapon = 0; weapon < 3; weapon++)
				{
					id = pChoice[playerid][weapon];
					weaponid = ChoiceModels[weapon][id][eModel];
					weaponlevel = ChoiceModels[weapon][id][eMinLvl];
					weaponslot = GetWeaponSlot(weaponid);
					if(weaponslot == slot && level >= weaponlevel && pWepAmmo[players][slot] > 0)
					{
						ammo = pWepAmmo[players][slot];
						format(string,sizeof(string),"+ %i ammo (Weapon: %s)", ammo, GetWeaponNameEx(weaponid));
						SendClientMessage(playerid,COLOR_WHITE,string);
						GivePlayerWeapon(playerid, weaponid, ammo);

						pWepAmmo[players][slot] = 0;
						break;
					}
				}
			}

			for(new slot = 0; slot < 13; slot++)
			{
				switch(slot) {case 0,1,7,10,11,12: continue;}

				new ammo = pWepAmmo[players][slot];
				if(ammo > 0) return 0;
			}
			RemoveAmmoPickup(players);
			return 1;
		}
		if(pickupid == pData[players])
		{
			RemoveDataPickup(players);
			if(pTeam[playerid] != pTeam[players])
			{
				GiveTeamScore(pTeam[playerid]);
				GivePlayerXP(playerid, true, 1.0);
			}
			return 1;
		}
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(PRESSED(KEY_WALK | KEY_JUMP) && pGUI[playerid] == false)
	{
	    TogglePlayerGUI(playerid,true);
		return 1;
	}

	if( IsPlayerSpawned(playerid) && !IsPlayerInAnyVehicle(playerid) && (PRESSED(KEY_HANDBRAKE) || RELEASED(KEY_HANDBRAKE)) )
	{
		if(IsPlayerAiming(playerid))
		{
			SetPlayerFirstPersonMode(playerid,0);
			pFirstPersonTick[playerid] = GetTickCount();
		}
	}

	if(IsPlayerSpectating(playerid))
	{
		new maxplayerid, minplayerid;
		maxplayerid = GetMinOrMaxPlayerID(1);
		minplayerid = GetMinOrMaxPlayerID(0);

		if(PRESSED(KEY_FIRE))
		{
			if(pSpecID[playerid] == maxplayerid)
			{
				foreach(new player : Player)
				{
					if(IsPlayerSpawned(player) && player < maxplayerid)
					{
						PlayerSpectatePlayerEx(playerid,player);
						return 1;
					}
				}
			}
			else
			{
				foreach(new player : Player)
				{
					if(IsPlayerSpawned(player) && player > pSpecID[playerid])
					{
						PlayerSpectatePlayerEx(playerid,player);
						return 1;
					}
				}
			}
		}
		if(PRESSED(KEY_HANDBRAKE))
		{
			if(pSpecID[playerid] == minplayerid)
			{
				foreach(new player : Player)
				{
					if(IsPlayerSpawned(player) && player > minplayerid)
					{
						PlayerSpectatePlayerEx(playerid,player);
						return 1;
					}
				}
			}
			else
			{
				foreach(new player : Player)
				{
					if(IsPlayerSpawned(player) && player > pSpecID[playerid])
					{
						PlayerSpectatePlayerEx(playerid,player);
						return 1;
					}
				}
			}
		}
	}

	if(gPlanter == playerid && pTeam[playerid] == 0 && GameInfo[gState] == 3 && gPlantCounter == 0)
	{
		for(new bombsite = 0; bombsite < 2; bombsite++)
		{
			if(IsPlayerInRangeOfPoint(playerid, 2, MapBombs[GameInfo[gMap]][bombsite][0], MapBombs[GameInfo[gMap]][bombsite][1], MapBombs[GameInfo[gMap]][bombsite][2]))
			{
				if(PRESSED(KEY_SECONDARY_ATTACK))
				{
					gPlantCounter = SetTimerEx("BombInteraction", 200, true, "ii", 2, playerid);

					SetPlayerProgressBarValue(playerid, TD_PlantBar[playerid], 0.0);
					ShowPlayerProgressBar(playerid, TD_PlantBar[playerid]);

					ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_LOOP", 3.0, 1, 0, 0, 0, 0, 1); // Start Planting
					AttachBombToPlayer(playerid, 1, true);
					return 1;

				}
				if(RELEASED(KEY_SECONDARY_ATTACK))
				{
					KillTimer(gPlantCounter);
					gPlantCounter = 0;

					SetPlayerProgressBarValue(playerid, TD_PlantBar[playerid], 0.0);
					HidePlayerProgressBar(playerid, TD_PlantBar[playerid]);

					ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 3.0, 0, 0, 0, 0, 0, 1); //Done Planting
    		        AttachBombToPlayer(playerid,0,true);
					return 1;
				}
			}
		}
	}
	if(GameInfo[gState] == 4 && pTeam[playerid] == 1 && gPlantCounter == 0)
	{
		if(IsPlayerInRangeOfPoint(playerid, 2, gBombPos[0], gBombPos[1], gBombPos[2]))
		{
			if(PRESSED(KEY_SECONDARY_ATTACK))
			{
				gPlantCounter = SetTimerEx("BombInteraction",200,true,"ii",3,playerid);

				SetPlayerProgressBarValue(playerid, TD_PlantBar[playerid], 0.0);
				ShowPlayerProgressBar(playerid, TD_PlantBar[playerid]);

				ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_LOOP", 3.0, 1, 0, 0, 0, 0, 1); // Start Planting
				return 1;
			}
			if(RELEASED(KEY_SECONDARY_ATTACK))
			{
				KillTimer(gPlantCounter);
				gPlantCounter = 0;

				SetPlayerProgressBarValue(playerid, TD_PlantBar[playerid], 0.0);
				HidePlayerProgressBar(playerid, TD_PlantBar[playerid]);

				ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 3.0, 0, 0, 0, 0, 0, 1); //Done Planting
				return 1;
			}
		}
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	new playerip[16];
	foreach(new playerid : Player)
	{
		GetPlayerIp(playerid, playerip, sizeof(playerip));
		if(!strcmp(ip,playerip))
		{
			switch(success)
			{
				case 0: KickEx(playerid, -1, false, "Failed RCON Login");
				case 1: if(pAdmin[playerid] == false) pAdmin[playerid] = true;
			}
			return 1;
		}
	}
	return 1;
}

public OnPlayerUpdate(playerid)
{
	new drunk_new, drunk_old;
	drunk_new = GetPlayerDrunkLevel(playerid);
	drunk_old = pDrunkLvl[playerid];

	if(drunk_new < 100)
	{
		pDrunkLvl[playerid] = 2000;
		SetPlayerDrunkLevel(playerid, pDrunkLvl[playerid]);
	}
	else if(drunk_old != drunk_new)
	{
		new fps = drunk_old - drunk_new;
		if(fps < 0) fps = 0;

		pDrunkLvl[playerid] = drunk_new;
		pFPS[playerid] = fps;
	}
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	if(pTeam[playerid] == pTeam[forplayerid] && GameInfo[gMode] != 1)
	{
		ShowPlayerNameTagForPlayer(playerid, forplayerid, 1);
		ShowPlayerNameTagForPlayer(forplayerid, playerid, 1);
		SetPlayerMarkerForPlayer(playerid, forplayerid, COLOR_GREEN);
		SetPlayerMarkerForPlayer(forplayerid, playerid, COLOR_GREEN);
	}
	else
	{
		ShowPlayerNameTagForPlayer(playerid, forplayerid, 0);
		ShowPlayerNameTagForPlayer(forplayerid, playerid, 0);
		SetPlayerMarkerForPlayer(playerid, forplayerid, (COLOR_RED & COLOR_TRANSPARENT));
		SetPlayerMarkerForPlayer(forplayerid, playerid, (COLOR_RED & COLOR_TRANSPARENT));
	}
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	ShowPlayerNameTagForPlayer(playerid, forplayerid, 0);
	ShowPlayerNameTagForPlayer(forplayerid, playerid, 0);
	SetPlayerMarkerForPlayer(playerid, forplayerid, COLOR_TRANSPARENT);
	SetPlayerMarkerForPlayer(forplayerid, playerid, COLOR_TRANSPARENT);
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

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(response)
	{
		case 0: PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
		case 1: PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	}

	switch(dialogid)
	{
	    case DIALOG_REGISTER:
	    {
			if(!response)
			{
				KickEx(playerid, -1, false, "Canceled Registration");
				return 1;
			}
			if(strlen(inputtext) < PASSWORD_MIN || strlen(inputtext) > PASSWORD_MAX)
			{
				new string[128], name[MAX_PLAYER_NAME+1];

				GetPlayerName(playerid, name, sizeof(name));

				format(string,sizeof(string),""C_WHITE"Welcome %s!\nPlease enter a password to register your new account.\nThe password has to be between %i - %i characters long",name,PASSWORD_MIN,PASSWORD_MAX);
				ShowPlayerDialog(playerid,DIALOG_REGISTER, DIALOG_STYLE_PASSWORD, ""C_WHITE"Register", string, "Register", "");
				return 1;
			}
			if(IsPlayerRegistered(playerid))
			{
				new string[128], name[MAX_PLAYER_NAME+1];
				
				GetPlayerName(playerid, name, sizeof(name));
				format(string,sizeof(string),"This name is registered! (%s)",name);
				SendClientMessage(playerid,COLOR_RED,string);
				return 1;
			}
			RegisterPlayer(playerid, inputtext);
		}
	    case DIALOG_LOGIN:
	    {
			if(!response)
			{
				KickEx(playerid, -1, false, "Canceled Login");
				return 1;
			}
			new query[400], DBResult:result, hash[129], name[MAX_PLAYER_NAME+1];

			GetPlayerName(playerid, name, sizeof(name));
			WP_Hash(hash,sizeof(hash),inputtext);
			format(query, sizeof(query), "SELECT `name` AND `password` FROM `usertable` WHERE `name` = '%s' AND `password` = '%s'", DB_Escape(name), DB_Escape(hash));
			result = db_query(database, query);
			if(db_num_rows(result) == 1)
			{
                LoginPlayer(playerid);
			}
			else
			{
				pPassWarnings[playerid] += 1;
				if(pPassWarnings[playerid] >= WARNINGS_PASS)
				{
					KickEx(playerid, -1, false, "Incorrect Password");
					return 1;
				}

				new string[128];
				format(string,sizeof(string),""C_WHITE"Welcome back %s!\nPlease enter your password to login to your account.\n"C_RED"Incorrect Password (%i tries left!)",name,WARNINGS_PASS-pPassWarnings[playerid]);
				ShowPlayerDialog(playerid,DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, ""C_WHITE"Login", string, "Login", "");
			}
			db_free_result(result);
		}
		case DIALOG_NAME:
		{
			if(!response) return 1;
			ChangePlayerName(playerid, inputtext);
		}
		case DIALOG_PASSWORD:
		{
			if(!response) return 1;
			ChangePlayerPassword(playerid, inputtext);
		}
		case DIALOG_RESETSTATS:
		{
			if(!response) return 1;

			if(IsPlayerRegistered(playerid))
			{
				new query[200], name[MAX_PLAYER_NAME+1];
				GetPlayerName(playerid, name, sizeof(name));

				format(query,sizeof(query),"DELETE `kill`, `death`, `win`, `lose`, `experience`, `primary`, `secondary` FROM `usertable` WHERE `name` = '%s'",name);
				db_free_result(db_query(database,query));

				SendClientMessage(playerid, COLOR_WHITE, "Your stats have been reset.");
			}
		}
	}
	return 0;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	TogglePlayerGUI(playerid,true);
	TogglePlayerStatsMenu(playerid,clickedplayerid,true);
	return 1;
}

public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    SetPlayerPosFindZ(playerid, fX, fY, fZ+1);
    return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid == TD_UserButton[playerid][0])
	{
		TogglePlayerTeamMenu(playerid, true);
		return 1;
	}
	if(playertextid == TD_UserButton[playerid][1])
	{
		TogglePlayerLoadoutMenu(playerid,true);
		return 1;
	}
	if(playertextid == TD_UserButton[playerid][2])
	{
		TogglePlayerStatsMenu(playerid,playerid,true);
		return 1;
	}
	if(playertextid == TD_UserButton[playerid][3])
	{
		ShowPlayerDialog(playerid,DIALOG_RESETSTATS,DIALOG_STYLE_MSGBOX, ""C_WHITE"Reset Stats", ""C_RED"Are you sure you want to reset your stats?", "Yes", "No");
		return 1;
	}
	if(playertextid == TD_UserButton[playerid][4])
	{
		ShowPlayerDialog(playerid,DIALOG_NAME, DIALOG_STYLE_INPUT, ""C_WHITE"Change Name", ""C_WHITE"Please enter your new name.", "Apply", "Close");
		return 1;
	}
	if(playertextid == TD_UserButton[playerid][5])
	{
		ShowPlayerDialog(playerid,DIALOG_PASSWORD, DIALOG_STYLE_PASSWORD, ""C_WHITE"Change Password", ""C_WHITE"Please enter your new password.", "Apply", "Close");
		return 1;
	}
	if(playertextid == TD_StatsClose[playerid])
	{
		TogglePlayerStatsMenu(playerid,playerid,false);
		return 1;
	}
	if(playertextid == TD_CloseButton[playerid])
	{
		new id, wepid, weplevel, Float:xp, level;
		xp = pXP[playerid];
		level = XpToLevel(xp);

		for(new slot = 0; slot < 3; slot++)
		{
			id = pChoice[playerid][slot];
			wepid = ChoiceModels[slot][id][eModel];
			weplevel = ChoiceModels[slot][id][eMinLvl];
			if(level < weplevel)
			{
				new string[128];
				format(string,sizeof(string),"You have chosen a locked weapon! (%s)",GetWeaponNameEx(wepid));
				SendClientMessage(playerid,COLOR_RED,string);
				PlayerPlaySound(playerid, 1055, 0.0, 0.0, 0.0);
				return 1;
			}
		}
		SendClientMessage(playerid,COLOR_WHITE,"Changes will be applied upon next spawn.");
		TogglePlayerLoadoutMenu(playerid,false);
		return 1;
	}
	for(new response = 0; response < 2; response++)
	{
		for(new slot = 0; slot < 3; slot++)
		{
			if(playertextid == TD_SelectButton[playerid][slot][response])
			{
				new id, size;
				size = sizeof(ChoiceModels[]) - 1;
				id = pChoice[playerid][slot];

				switch(response)
				{
	    			case 0:// Back Arrow
	    			{
						if(id > 0)
						{
							id --;
							PlayerPlaySound(playerid, 1056, 0,0,0);
						}
						else return PlayerPlaySound(playerid,1055,0,0,0);
					}
	    			case 1:// Forward Arrow
	    			{
						if(id < size)
						{
							id ++;
							PlayerPlaySound(playerid, 1057, 0,0,0);
						}
						else return PlayerPlaySound(playerid,1055,0,0,0);
					}
				}

				new model, weplevel, Float:xp, level, weaponid, wepname[32];

				weaponid = ChoiceModels[slot][id][eModel];
				weplevel = ChoiceModels[slot][id][eMinLvl];
				xp = pXP[playerid];
				level = XpToLevel(xp);
				model = ConvertWeaponModel(weaponid);
				pChoice[playerid][slot] = id;

				if(level >= weplevel) format(wepname,sizeof(wepname),"%s",GetWeaponNameEx(weaponid));
				else format(wepname,sizeof(wepname),"%s ~r~(level %i)",GetWeaponNameEx(weaponid),weplevel);

				PlayerTextDrawSetPreviewModel	(playerid,TD_ChoiceModel[playerid][slot], model);
				PlayerTextDrawSetPreviewRot		(playerid,TD_ChoiceModel[playerid][slot], 0.0, 330.0, 320.0, 0.8);
				PlayerTextDrawShow				(playerid,TD_ChoiceModel[playerid][slot]);
				PlayerTextDrawSetString         (playerid,TD_ChoiceName[playerid][slot], wepname);
			    return 1;
			}
		}
	}
	if(playertextid == TD_TeamClose[playerid])
	{
	    TogglePlayerTeamMenu(playerid, false);
	}
	for(new team = 0; team < 3; team++)
	{
		if(playertextid == TD_Team[playerid][team])
		{
			switch(team)
			{
				case 0,1:
				{
					pTeam[playerid] = team;
					if(TogglePlayerGame(playerid, true) == 1)
					{
						TogglePlayerTeamMenu(playerid, false);
						TogglePlayerGUI(playerid, false);
					}
				}
				default:
				{
					TogglePlayerGame(playerid, false);
					TogglePlayerTeamMenu(playerid, false);
					TogglePlayerGUI(playerid, false);
				}
			}
			return 1;
		}
	}
	return 1;
}

public OnPlayerClickTextDraw(playerid,Text:clickedid)
{
	if(clickedid == Text:(INVALID_TEXT_DRAW) && pGUI[playerid] == true)
	{
		TogglePlayerGUI(playerid, false);
		TogglePlayerLoadoutMenu(playerid, false);
		TogglePlayerStatsMenu(playerid,playerid, false);
		TogglePlayerTeamMenu(playerid, false);
	}
	return 1;
}
