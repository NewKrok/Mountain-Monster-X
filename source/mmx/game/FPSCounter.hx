package mmx.game;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.misc.VarTween;
import flixel.util.FlxColor;
import hpp.flixel.util.HPPAssetManager;
import mmx.assets.Fonts;

/**
 * ...
 * @author Krisztian Somoracz
 */
class FPSCounter extends FlxSpriteGroup
{
	var background:FlxSprite;
	var text:FlxText;
	var defaultTextScale:Float;
	var count:UInt;
	var scaleTween:VarTween;

	public function new()
	{
		super();

		add( background = HPPAssetManager.getSprite( "gui_fps_back" ) );

		text = new FlxText( 40, 0, cast width - 40, "0", 33 );
		text.autoSize = false;
		text.color = 0xFF4D90FE;
		text.alignment = "center";
		text.font = Fonts.AACHEN_MEDIUM;
		text.borderStyle = FlxTextBorderStyle.OUTLINE;
		text.borderSize = 2;
		text.borderColor = 0xAA013FA5;
		text.y = 10;
		defaultTextScale = text.scale.x;
		
		add( text );
	}

	override public function update( elapsed:Float ):Void 
	{
		super.update( elapsed );
	
		text.text = Std.string( Main.fps.currentFPS );
	}
}