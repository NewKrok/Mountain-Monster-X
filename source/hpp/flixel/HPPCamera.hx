package hpp.flixel;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxAxes;

/**
 * ...
 * @author Krisztian Somoracz
 */
class HPPCamera extends FlxCamera
{
	public var speedZoomEnabled:Bool = false;
	public var maxSpeedZoom:Float = 1.2;
	public var minSpeedZoom:Float = 1;
	public var speedZoomRatio:Float = 200;
	
	public function resetPosition():Void
	{
		if ( _scrollTarget != null ) _scrollTarget.set();
		if ( _lastTargetPosition != null ) _lastTargetPosition.set();
		if ( scroll != null ) scroll.set();
	}
	
	override public function update( elapsed:Float ):Void 
	{
		if ( speedZoomEnabled && target != null && _lastTargetPosition != null )
		{
			zoom = 1 + ( 1 - Math.min( maxSpeedZoom, minSpeedZoom + _lastTargetPosition.distanceTo( target.getPosition() ) / speedZoomRatio ) );
		}
		
		super.update( elapsed );
	}
}