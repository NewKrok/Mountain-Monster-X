package mmx.datatype;

import flixel.math.FlxPoint;

/**
 * ...
 * @author Krisztian Somoracz
 */
typedef LevelData =
{
	var worldId( default, default ):UInt;
	var levelId( default, default ):UInt;
	var maxWidth( default, default ):UInt;
	var maxCameraY( default, default ):UInt;
	var starValues( default, default ):Array<UInt>;
	var startPoint( default, default ):FlxPoint;
	var finishPoint( default, default ):FlxPoint;
	var groundPoints( default, default ):Array<FlxPoint>;
	var bridgePoints( default, default ):Array<Dynamic>; // TODO create a typdef for it
	var starPoints( default, default ):Array<FlxPoint>;
}