package mmx.util;

import haxe.Json;
import haxe.macro.Expr.Error;

import haxe.Log;

import mmx.datatype.LevelData;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LevelUtil 
{
	public static function LevelDataFromJson( jsonLevelData:String ):LevelData
	{
		var level:LevelData;
		
		try
		{
			level = Json.parse( jsonLevelData );
		}
		catch( e:Error )
		{
			Log.trace( "[LevelUtil] parsing error" );
			level = null;
		}
		
		return level;
	}
}