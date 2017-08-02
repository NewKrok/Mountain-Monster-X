package mmx.state;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.ui.FlxButton;
import hpp.flixel.ui.HPPButton;
import hpp.flixel.util.HPPAssetManager;
import js.Browser;
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
	var backgroundTween:VarTween;
	var offsetPercent:FlxPoint = new FlxPoint();
	
	var levelPackButtonContainer:FlxSpriteGroup;
	var controlButtonContainer:FlxSpriteGroup;

	var levelPackButton0:HPPButton;
	var levelPackButton1:HPPButton;
	var levelPackButton2:HPPButton;
	var levelPackButton3:HPPButton;
	
	var backButton:HPPButton;

	override public function create():Void
	{
		super.create();

		loadAssets();
		build();

		#if html5
		Browser.window.addEventListener( 'devicemotion', accelerometerMove, true );
		#end

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

		add( background = new Background( 0 ) );

		createLevelPackButtons();
		createControlButtons();
		
		camera.scroll.set( stage.stageWidth / 2, stage.stageHeight / 2 );
	}
	
	function createLevelPackButtons():Void 
	{
		add( levelPackButtonContainer = new FlxSpriteGroup() );
		levelPackButtonContainer.scrollFactor.set();
		
		levelPackButtonContainer.add( levelPackButton0 = new HPPButton( 0, 0, "", loadWorld0 ) );
		levelPackButton0.loadGraphic( HPPAssetManager.getGraphic( "level_pack_0" ) );
		levelPackButton0.overScale = .95;
		
		levelPackButtonContainer.add( levelPackButton1 = new HPPButton( 0, 0, "", loadWorld1 ) );
		levelPackButton1.loadGraphic( HPPAssetManager.getGraphic( "level_pack_1" ) );
		levelPackButton1.x = levelPackButton0.width + 10;
		levelPackButton1.overScale = .95;
		
		levelPackButtonContainer.add( levelPackButton2 = new HPPButton( 0, 0, "", loadWorld2 ) );
		levelPackButton2.loadGraphic( HPPAssetManager.getGraphic( "level_pack_2" ) );
		levelPackButton2.y = levelPackButton0.height + 10;
		levelPackButton2.overScale = .95;
		
		levelPackButtonContainer.add( levelPackButton3 = new HPPButton( 0, 0, "", loadWorld3 ) );
		levelPackButton3.loadGraphic( HPPAssetManager.getGraphic( "level_pack_coming_soon" ) );
		levelPackButton3.x = levelPackButton1.x;
		levelPackButton3.y = levelPackButton2.y;
		
		levelPackButtonContainer.x = stage.stageWidth / 2 - levelPackButtonContainer.width / 2;
		levelPackButtonContainer.y = stage.stageHeight / 2 - levelPackButtonContainer.height / 2 - 50;
	}
	
	function createControlButtons() 
	{
		add( controlButtonContainer = new FlxSpriteGroup() );
		controlButtonContainer.scrollFactor.set();
		
		controlButtonContainer.add( backButton = new HPPButton( 0, 0, "Back" ) );
		backButton.loadGraphic( HPPAssetManager.getGraphic( "base_button" ) );
		backButton.autoCenterLabel();
		backButton.overScale = .95;
		backButton.x = stage.stageWidth / 2 - backButton.width / 2;
		backButton.y = stage.stageHeight - 40 - backButton.height;
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
	
	function loadWorld3():Void
	{
	}
	
	#if html5
	function accelerometerMove( e ):Void
	{
		offsetPercent.set( stage.stageWidth / 2 + e.accelerationIncludingGravity.y * 15, stage.stageHeight / 2 + e.accelerationIncludingGravity.x * 15 );

		removeBackgroundTween();
		backgroundTween = FlxTween.tween( 
			camera.scroll,
			{ x: offsetPercent.x, y: offsetPercent.y },
			.4,
			{ ease: FlxEase.expoOut }
		);
	}
	#end

	function onMouseMove( e:MouseEvent ):Void
	{
		var centerX:Float = stage.stageWidth / 2;
		var centerY:Float = stage.stageHeight / 2;

		var xDirection:Int = stage.mouseX > centerX ? -1 : 1;
		var yDirection:Int = stage.mouseY > centerY ? -1 : 1;

		var xRatio:Float = ( stage.mouseX - centerX ) / centerX * -1;
		var yRatio:Float = ( stage.mouseY - centerY ) / centerY;

		offsetPercent.set( stage.stageWidth / 2 - xRatio * 50, stage.stageHeight / 2 + yRatio * 50 );

		removeBackgroundTween();
		backgroundTween = FlxTween.tween( 
			camera.scroll,
			{ x: offsetPercent.x, y: offsetPercent.y },
			.4,
			{ ease: FlxEase.expoOut }
		);
	}
	
	function removeBackgroundTween():Void
	{
		if ( backgroundTween != null )
		{
			backgroundTween.cancel();
			backgroundTween.destroy();
			backgroundTween = null;
		}
	}

	function loadGame( worldId:UInt, levelId:UInt ):Void
	{
		FlxG.switchState( new GameState( worldId, levelId ) );
	}
	
	override public function update( elapsed:Float ):Void
	{
		super.update( elapsed );

		if ( levelPackButton0.status == FlxButton.HIGHLIGHT )
		{
			background.worldId = 0;
		}
		else if ( levelPackButton1.status == FlxButton.HIGHLIGHT )
		{
			background.worldId = 1;
		}
		else if ( levelPackButton2.status == FlxButton.HIGHLIGHT )
		{
			background.worldId = 2;
		}
	}

	override public function destroy():Void
	{
		HPPAssetManager.clear();
		
		#if html5
		Browser.window.removeEventListener( 'devicemotion', accelerometerMove, true );
		#end

		stage.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );

		super.destroy();
	}
}