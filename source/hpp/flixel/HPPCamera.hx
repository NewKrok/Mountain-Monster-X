package hpp.flixel;

import flixel.FlxCamera;

/**
 * ...
 * @author Krisztian Somoracz
 */
class HPPCamera extends FlxCamera
{
	public function resetPosition():Void
	{
		if ( _scrollTarget != null ) _scrollTarget.set();
		if ( _lastTargetPosition != null ) _lastTargetPosition.set();
		if ( scroll != null ) scroll.set();
	}
}