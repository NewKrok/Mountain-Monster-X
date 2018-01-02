package mmx.util;

import haxe.Json;
import haxe.Log;
import mmx.datatype.LevelData;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LevelUtil
{
	private static var worldNames:Array<String> = [
		"Sharp Mountain",
		"Ice World",
		"Desert Valley",
		"Candy Land"
	];

	public static function LevelDataFromJson(jsonData:String):LevelData
	{
		var level:LevelData;

		try
		{
			level = Json.parse(jsonData);
		}
		catch( e:String )
		{
			Log.trace( "[LevelUtil] parsing error" );
			level = null;
		}

		return level;
	}

	public static function getWorldNameByWorldId(id:UInt):String
	{
		return worldNames[id];
	}
}