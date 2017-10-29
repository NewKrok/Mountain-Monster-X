package mmx.util;

import flixel.util.FlxSave;

/**
 * ...
 * @author Krisztian Somoracz
 */
class SavedDataUtil 
{
	static private var gameSave:FlxSave;
	
	public static function load( dataName:String )
	{
		gameSave = new FlxSave();
		gameSave.bind( dataName );
		
		if (gameSave.data.baseInfo == null)
		{
			gameSave.data.baseInfo = {gameName: AppConfig.GAME_NAME, version: AppConfig.GAME_VERSION};
		}
		
		if (gameSave.data.settings == null)
		{
			gameSave.data.settings = {showFPS: false, enableAlphaAnimation:false};
		}
		
		if (gameSave.data.helpInfos == null)
		{
			gameSave.data.helpInfos = [];
		}
		
		if (gameSave.data.levelInfos == null)
		{
			gameSave.data.levelInfos = [{worldId:0, levelId:0, score:0, starCount:0, collectedCoins:0, time:0, isEnabled:true, isCompleted:false, isLastPlayed:true}];
		}
	}
	
	public static function save():Void
	{
		gameSave.data.baseInfo.version = AppConfig.GAME_VERSION;
		gameSave.flush();
	}
	
	public static function getBaseAppInfo():BaseAppInfo
	{
		return gameSave.data.baseInfo;
	}
	
	public static function getAllLevelInfo():Array<LevelInfo>
	{
		return gameSave.data.levelInfos;
	}
	
	public static function getLevelInfo(worldId:UInt, levelId:UInt):LevelInfo
	{
		for ( i in 0...gameSave.data.levelInfos.length )
		{
			var levelInfo:LevelInfo = gameSave.data.levelInfos[i];
			
			if (levelInfo.worldId == worldId && levelInfo.levelId == levelId)
			{
				return levelInfo;
			}
		}
		
		var newEntry:LevelInfo = {worldId:worldId, levelId:levelId, score:0, starCount:0, collectedCoins:0, time:0, isEnabled:false, isCompleted:false, isLastPlayed:false};
		gameSave.data.levelInfos.push(newEntry);
		
		return newEntry;
	}
	
	static public function resetLastPlayedInfo() 
	{
		for ( i in 0...gameSave.data.levelInfos.length )
		{
			var levelInfo:LevelInfo = gameSave.data.levelInfos[i];
			levelInfo.isLastPlayed = false;
		}
	}
	
	
	static public function getLastPlayedLevel(worldId:UInt):UInt
	{
		for (i in 0...gameSave.data.levelInfos.length)
		{
			if (gameSave.data.levelInfos[i].worldId == worldId && gameSave.data.levelInfos[i].isLastPlayed)
			{
				return gameSave.data.levelInfos[i].levelId;
			}
		}
		
		return 0;
	}
	
	public static function getHelpInfo(worldId:UInt):HelpInfo
	{
		for (i in 0...gameSave.data.helpInfos.length)
		{
			if (gameSave.data.helpInfos[i].worldId == worldId)
			{
				return gameSave.data.helpInfos[i];
			}
		}
		
		var newEntry:HelpInfo = {worldId:worldId, isShowed: false}
		gameSave.data.helpInfos.push(newEntry);
		
		return newEntry;
	}
	
	public static function setHelpInfo(worldId:UInt, isShowed:Bool):Void
	{
		getHelpInfo( worldId ).isShowed = isShowed;
	}
	
	public static function getSettingsInfo():SettingsInfo
	{
		return gameSave.data.settings;
	}
}

typedef BaseAppInfo = {
	var gameName:String;
	var version:String;
}

typedef SettingsInfo = {
	var showFPS:Bool;
	var enableAlphaAnimation:Bool;
}

typedef HelpInfo = {
	var worldId:UInt;
	var isShowed:Bool;
}

typedef LevelInfo = {
	var worldId:UInt;
	var levelId:UInt;
	var score:UInt;
	var starCount:UInt;
	var collectedCoins:UInt;
	var time:Float;
	var isEnabled:Bool;
	var isCompleted:Bool;
	var isLastPlayed:Bool;
}