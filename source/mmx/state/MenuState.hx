package mmx.state;

import flixel.FlxG;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.ui.FlxButton;
import hpp.flixel.util.HPPAssetManager;
import mmx.game.Background;
import openfl.Lib;
import openfl.display.Stage;
import openfl.events.MouseEvent;

/**
 * ...
 * @author Krisztian Somoracz
 */
class MenuState extends FlxState
{
	var stage:Stage;
	
	var background:Background;
	var offsetPercent:FlxPoint = new FlxPoint();
	
	var buttonA:FlxButton;
	var buttonB:FlxButton;
	var buttonC:FlxButton;

	override public function create():Void
	{
		super.create();

		loadAssets();
		build();
		
		stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
	}
	
	function loadAssets():Void
	{
		HPPAssetManager.loadXMLAtlas( "assets/images/atlas1.png", "assets/images/atlas1.xml" );
		HPPAssetManager.loadXMLAtlas( "assets/images/atlas2.png", "assets/images/atlas2.xml" );
		HPPAssetManager.loadXMLAtlas( "assets/images/atlas3.png", "assets/images/atlas3.xml" );
		
		HPPAssetManager.loadXMLBitmapFont( "assets/fonts/aachen-light.png", "assets/fonts/aachen-light.fnt.xml" );
	}

	function build():Void
	{
		stage = Lib.current.stage;
		
		add( background = new Background( 2 ) );
		
		add( buttonA = new FlxButton( stage.stageWidth / 2 - 50, 100, "World 0", loadWorld0 ) );
		add( buttonB = new FlxButton( stage.stageWidth / 2 - 50, 150, "World 1", loadWorld1 ) );
		add( buttonC = new FlxButton( stage.stageWidth / 2 - 50, 200, "World 2", loadWorld2 ) );
	}
	
	function loadWorld0():Void
	{
		loadGame( 0, 0 );
	}
	
	function loadWorld1() :Void
	{
		loadGame( 1, 0 );
	}
	
	function loadWorld2():Void
	{
		loadGame( 2, 0 );
	}
	
	function onMouseMove( e:MouseEvent ):Void
	{
		var centerX:Float = stage.stageWidth / 2;
		var centerY:Float = stage.stageHeight / 2;

		var xDirection:Int = stage.mouseX > centerX ? -1 : 1;
		var yDirection:Int = stage.mouseY > centerY ? -1 : 1;

		var xRatio:Float = ( stage.mouseX - centerX ) / centerX * -1;
		var yRatio:Float = ( stage.mouseY - centerY ) / centerY;
		
		offsetPercent.set( stage.mouseX + xRatio * 40, stage.mouseY + yRatio * 40 );

		camera.focusOn( offsetPercent );
	}

	function loadGame( worldId:UInt, levelId:UInt ):Void
	{
		FlxG.switchState( new GameState( worldId, levelId ) );
	}
	
	override public function update( elapsed:Float ):Void 
	{
		super.update( elapsed );
		
		if ( buttonA.status == FlxButton.HIGHLIGHT )
		{
			background.worldId = 0;
		}
		else if ( buttonB.status == FlxButton.HIGHLIGHT )
		{
			background.worldId = 1;
		}
		else if ( buttonC.status == FlxButton.HIGHLIGHT )
		{
			background.worldId = 2;
		}
	}
	
	override public function destroy():Void 
	{
		HPPAssetManager.clear();
		
		stage.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
		
		super.destroy();
	}
}