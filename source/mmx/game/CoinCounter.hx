package mmx.game;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import flixel.util.FlxColor;
import hpp.flixel.text.HPPBitmapText;
import hpp.flixel.util.HPPAssetManager;

/**
 * ...
 * @author Krisztian Somoracz
 */
class CoinCounter extends FlxSpriteGroup
{
	var background:FlxSprite;
	var text:HPPBitmapText;
	var defaultTextScale:Float;
	var count:UInt;
	var scaleTween:VarTween;

	public function new()
	{
		super();

		add( background = HPPAssetManager.getSprite( "gui_coin_back" ) );

		text = new HPPBitmapText( "Aachen-Light", "0", 35, FlxColor.YELLOW, "center" );
		text.autoSize = false;
		text.fieldWidth = cast width + 45;
		defaultTextScale = text.scale.x;
		
		add( text );
	}

	public function updateValue( value:UInt ):Void
	{	
		if( value != count )
		{
			count = value;

			if( count != 0 )
			{
				disposeTween();
				scaleTween = FlxTween.tween( 
					text.scale,
					{ x: defaultTextScale + .2, y: defaultTextScale + .2 },
					.1,
					{ type: FlxTween.ONESHOT, ease: FlxEase.cubeIn, onComplete: resetScale }
				);
			}

			text.text = Std.string( value );
		}
	}
	
	function resetScale( tween:FlxTween ):Void
	{
		scaleTween = FlxTween.tween( 
			text.scale,
			{ x: defaultTextScale, y: defaultTextScale },
			.1,
			{ type: FlxTween.ONESHOT, ease: FlxEase.cubeIn, startDelay: .2 }
		);
	}
	
	function disposeTween():Void
	{
		if ( scaleTween != null )
		{
			scaleTween.cancel();
			scaleTween.destroy();
			scaleTween = null;
		}
	}
}