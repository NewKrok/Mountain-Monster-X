package hpp.flixel.ui;

import flixel.addons.ui.FlxUIButton;

/**
 * ...
 * @author Krisztian Somoracz
 */
class HPPButton extends FlxUIButton
{
	public var overScale:Float = 1;
	
	override private function onOverHandler():Void
	{
		super.onOverHandler();
		
		scale.set( overScale, overScale );
	}
	
	override private function onOutHandler():Void
	{
		super.onOutHandler();
		
		scale.set( 1, 1 );
	}
}