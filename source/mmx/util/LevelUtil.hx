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
	public static function LevelDataFromJson( jsonData:String ):LevelData
	{
		var level:LevelData;
		
		try
		{
			level = Json.parse( jsonData );
		}
		catch( e:String )
		{
			Log.trace( "[LevelUtil] parsing error" );
			level = null;
		}
		
		return level;
	}
}