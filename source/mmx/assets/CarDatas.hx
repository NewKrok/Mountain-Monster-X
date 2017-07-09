package mmx.assets;

import haxe.Json;
import haxe.Log;

import mmx.datatype.CarData;

/**
 * ...
 * @author Krisztian Somoracz
 */
class CarDatas 
{
	public static inline var MAX_SPEED:Float = 14;
	public static inline var MIN_SPEED:Float = 9;
	public static inline var MAX_ROTATION:Float = 9;
	public static inline var MIN_ROTATION:Float = 5;
	public static inline var MAX_DAMPING:Float = .9;
	public static inline var MIN_DAMPING:Float = .4;

	static var carDatas:Array<CarData>;
	
	public static function loadData( jsonData:String ):Void
	{
		try
		{
			carDatas = Json.parse( jsonData ).carDatas;
		}
		catch( e:String )
		{
			Log.trace( "[CarDatas] parsing error" );
			carDatas = null;
		}
	}
	
	public static function getData( carId:UInt ):CarData
	{
		for( i in 0...carDatas.length )
		{
			if( carDatas[i].id == carId )
			{
				return carDatas[i];
			}
		}
		return null;
	}
}