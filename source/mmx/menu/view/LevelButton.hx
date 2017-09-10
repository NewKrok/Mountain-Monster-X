package mmx.menu.view;

import flixel.FlxG;
import flixel.addons.text.FlxTextField;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import hpp.flixel.text.HPPBitmapText;
import hpp.flixel.ui.HPPButton;
import hpp.flixel.ui.HPPExtendableButton;
import hpp.flixel.ui.HPPVUIBox;
import mmx.assets.Fonts;
import mmx.state.GameState;
import openfl.Assets;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LevelButton extends HPPExtendableButton
{
	var title:FlxText;
	var score:FlxText;
	var levelStarView:LevelStarView;
	
	var worldId:UInt;
	var levelId:UInt;
	
	public function new( worldId:UInt, levelId:UInt )
	{
		super( loadLevel, "level_button_base" );
		
		this.worldId = worldId;
		this.levelId = levelId;
		
		overScale = .95;
		
		var container:HPPVUIBox = new HPPVUIBox( 4 );
		
		title = new FlxText( 0, 0, cast width, "Level " + ( levelId + 1 ), 25 );
		title.font = Fonts.AACHEN_LIGHT;
		title.color = FlxColor.WHITE;
		title.alignment = "center";
		container.add( title );
		
		container.add( levelStarView = new LevelStarView() );
		levelStarView.setStarCount( Math.floor( Math.random() * 3 ) );
		
		score = new FlxText( 0, 0, title.width, "9 999", 25 );
		score.font = Fonts.AACHEN_LIGHT;
		score.color = FlxColor.YELLOW;
		score.alignment = "center";
		container.add( score );
		
		add( container );
		
		container.y = 8;
	}
	
	function loadLevel( target:HPPButton ):Void
	{
		FlxG.switchState( new GameState( worldId, levelId ) );
	}
}