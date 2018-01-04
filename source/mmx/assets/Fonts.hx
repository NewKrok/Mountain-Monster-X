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
	public static var AACHEN(default, null):String;

	public static function init():Void
	{
		AACHEN = Assets.getFont("assets/fonts/Aachen Regular.ttf").fontName;
	}
}