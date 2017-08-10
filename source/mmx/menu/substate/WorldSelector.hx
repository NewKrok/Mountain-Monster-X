package mmx.menu.substate;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import hpp.flixel.ui.HPPButton;
import hpp.flixel.util.HPPAssetManager;

/**
 * ...
 * @author Krisztian Somoracz
 */
class WorldSelector extends FlxSubState
{
	var levelPackButtonContainer:FlxSpriteGroup;
	var controlButtonContainer:FlxSpriteGroup;

	var levelPackButton0:HPPButton;
	var levelPackButton1:HPPButton;
	var levelPackButton2:HPPButton;
	var levelPackButton3:HPPButton;
	
	var backButton:HPPButton;
	
	var onWorldSelected:UInt->Void;
	
	function new( onWorldSelected:UInt->Void ):Void
	{
		this.onWorldSelected = onWorldSelected;
		
		super();
	}
	
	override public function create():Void 
	{
		super.create();
		
		createLevelPackButtons();
		createControlButtons();
	}
	
	function createLevelPackButtons():Void 
	{
		add( levelPackButtonContainer = new FlxSpriteGroup() );
		levelPackButtonContainer.scrollFactor.set();
		
		levelPackButtonContainer.add( levelPackButton0 = new HPPButton( "", loadWorld0 ) );
		levelPackButton0.loadGraphic( HPPAssetManager.getGraphic( "level_pack_0" ) );
		levelPackButton0.overScale = .95;
		
		levelPackButtonContainer.add( levelPackButton1 = new HPPButton( "", loadWorld1 ) );
		levelPackButton1.loadGraphic( HPPAssetManager.getGraphic( "level_pack_1" ) );
		levelPackButton1.x = levelPackButton0.width + 10;
		levelPackButton1.overScale = .95;
		
		levelPackButtonContainer.add( levelPackButton2 = new HPPButton( "", loadWorld2 ) );
		levelPackButton2.loadGraphic( HPPAssetManager.getGraphic( "level_pack_2" ) );
		levelPackButton2.y = levelPackButton0.height + 10;
		levelPackButton2.overScale = .95;
		
		levelPackButtonContainer.add( levelPackButton3 = new HPPButton( "", loadWorld3 ) );
		levelPackButton3.loadGraphic( HPPAssetManager.getGraphic( "level_pack_coming_soon" ) );
		levelPackButton3.x = levelPackButton1.x;
		levelPackButton3.y = levelPackButton2.y;
		
		levelPackButtonContainer.x = FlxG.width / 2 - levelPackButtonContainer.width / 2;
		levelPackButtonContainer.y = FlxG.height / 2 - levelPackButtonContainer.height / 2 - 50;
	}
	
	function loadWorld0():Void
	{
		onWorldSelected( 0 );
	}

	function loadWorld1() :Void
	{
		onWorldSelected( 1 );
	}

	function loadWorld2():Void
	{
		onWorldSelected( 2 );
	}
	
	function loadWorld3():Void
	{
	}
	
	function createControlButtons() 
	{
		add( controlButtonContainer = new FlxSpriteGroup() );
		controlButtonContainer.scrollFactor.set();
		
		controlButtonContainer.add( backButton = new HPPButton( "Back" ) );
		backButton.loadGraphic( HPPAssetManager.getGraphic( "base_button" ) );
		backButton.autoCenterLabel();
		backButton.overScale = .95;
		backButton.x = FlxG.width / 2 - backButton.width / 2;
		backButton.y = FlxG.height - 40 - backButton.height;
	}
}