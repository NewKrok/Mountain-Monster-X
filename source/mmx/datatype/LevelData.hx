package mmx.datatype;

import flixel.math.FlxPoint;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Krisztian Somoracz
 */
typedef LevelData =
{
	var worldId( default, default ):UInt;
	var levelId( default, default ):UInt;
	var cameraBounds( default, default ):Rectangle;
	var starValues( default, default ):Array<UInt>;
	var startPoint( default, default ):FlxPoint;
	var finishPoint( default, default ):FlxPoint;
	var groundPoints( default, default ):Array<FlxPoint>;
	var bridgePoints( default, default ):Array<BridgeData>;
	var starPoints( default, default ):Array<FlxPoint>;
}

typedef BridgeData =
{
	var bridgeAX:Float;
	var bridgeAY:Float;
	var bridgeBX:Float;
	var bridgeBY:Float;
}