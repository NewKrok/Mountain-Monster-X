package mmx.menu;

import flixel.FlxG;
import hpp.flixel.ui.HPPButton;
import hpp.flixel.util.HPPAssetManager;
import mmx.state.GameState;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LevelButton extends HPPButton
{
	var worldId:UInt;
	var levelId:UInt;
	
	public function new( worldId:UInt, levelId:UInt )
	{
		super( null, loadLevel );
		
		this.worldId = worldId;
		this.levelId = levelId;
		
		loadGraphic( HPPAssetManager.getGraphic( "level_button_base" ) );
		overScale = .95;
	}
	
	function loadLevel() 
	{
		FlxG.switchState( new GameState( worldId, levelId ) );
	}
}