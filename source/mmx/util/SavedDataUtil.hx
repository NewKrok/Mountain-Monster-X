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
			gameSave.data.baseInfo = {gameName: AppConfig.GAME_NAME, version: AppConfig.GAME_VERSION}
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
}

typedef BaseAppInfo = {
	var gameName:String;
	var version:String;
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