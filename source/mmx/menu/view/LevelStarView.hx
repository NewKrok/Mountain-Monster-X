package mmx.menu.view;

import flixel.group.FlxSpriteGroup;
import hpp.flixel.display.HPPMovieClip;
import hpp.flixel.util.HPPAssetManager;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LevelStarView extends FlxSpriteGroup
{
	var view:HPPMovieClip;
	
	public function new() 
	{
		super();
		
		add( view = HPPAssetManager.getMovieClip( "level_button_stars_", "0" ) );
	}
	
	public function setStarCount( value:UInt ):Void
	{
		view.gotoAndStop( value );
	}
	
	override function get_width():Float 
	{
		return 115;
	}
}