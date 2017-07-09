package mmx.datatype;

import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

import hpp.flixel.display.FPPMovieClip;

/**
 * ...
 * @author Krisztian Somoracz
 */
typedef BackgroundData =
{
	var easing( default, default ):FlxPoint;
	var container( default, default ):FlxSpriteGroup;
	var elements( default, default ):Array<FPPMovieClip>;
}