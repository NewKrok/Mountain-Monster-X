package mmx.assets;

import openfl.Assets;
import openfl.text.Font;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Fonts 
{
	public static var DEFAULT_FONT:String = "Verdana";
	public static var AACHEN_MEDIUM(default, null):String;
	
	public static function init():Void
	{
		AACHEN_MEDIUM = Assets.getFont("assets/fonts/aachen_medium_plain.ttf").fontName;
	}
}