package mmx.state;

import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.ui.FlxButton;
import hpp.flixel.ui.HPPButton;
import hpp.flixel.util.HPPAssetManager;
import js.Browser;
import mmx.game.Background;
import mmx.menu.substate.LevelSelector;
import mmx.menu.substate.WorldSelector;
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
	
	var worldSelector:WorldSelector;
	var levelSelector:LevelSelector;
	
	override public function create():Void
	{
		super.create();

		loadAssets();
		build();
		openWorldSelector();
		
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
		persistentUpdate = true;
		
		stage = Lib.current.stage;

		add( background = new Background( 0 ) );
		
		destroySubStates = false;
		worldSelector = new WorldSelector( openLevelSelector );
		levelSelector = new LevelSelector( openWorldSelector );

		camera.scroll.set( stage.stageWidth / 2, stage.stageHeight / 2 );
	}
	
	function openLevelSelector( worldId:UInt ):Void
	{
		levelSelector.worldId = worldId;
		background.worldId = worldId;
		
		openSubState( levelSelector );
	}
	
	function openWorldSelector( target:HPPButton = null ):Void
	{
		openSubState( worldSelector );
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