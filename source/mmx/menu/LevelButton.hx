package mmx.menu;

import flixel.FlxG;
import flixel.util.FlxColor;
import hpp.flixel.text.HPPBitmapText;
import hpp.flixel.ui.HPPButton;
import hpp.flixel.ui.HPPExtendableButton;
import mmx.assets.Fonts;
import mmx.state.GameState;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LevelButton extends HPPExtendableButton
{
	var title:HPPBitmapText;
	var score:HPPBitmapText;
	
	var worldId:UInt;
	var levelId:UInt;
	
	public function new( worldId:UInt, levelId:UInt )
	{
		super( loadLevel, "level_button_base" );
		
		this.worldId = worldId;
		this.levelId = levelId;
		
		overScale = .95;
		
		title = new HPPBitmapText( Fonts.AACHEN_LIGHT, "Level " + ( levelId + 1 ), 25, FlxColor.WHITE, "center" );
		title.autoSize = false;
		title.fieldWidth = cast width + 100;
		title.x = width / 2 - title.width / 2;
		title.y = -10;
		add( title );
		
		score = new HPPBitmapText( Fonts.AACHEN_LIGHT, "9 999", 25, FlxColor.YELLOW, "center" );
		score.autoSize = false;
		score.fieldWidth = cast title.width;
		score.x = title.x;
		score.y = 66;
		add( score );
	}
	
	function loadLevel( target:HPPButton ):Void
	{
		FlxG.switchState( new GameState( worldId, levelId ) );
	}
}