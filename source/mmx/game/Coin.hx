package mmx.game;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.tweens.misc.VarTween;
import hpp.flixel.util.AssetManager;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Coin extends FlxSprite
{
	public var isCollected( default, null ):Bool;
	
	var tween:VarTween;
	
	public function new( x:Float, y:Float )
	{
		super( x, y );
		
		loadGraphic( AssetManager.getGraphic( "coin" ) );
		
		scale.set( .8, .8 );
	}
	
	public function collect():Void
	{
		isCollected = true;
		
		disposeTween();
		
		tween = FlxTween.tween( 
			this,
			{ x: x - 100, y: y-50, alpha: 0, angle: Math.PI * 6 },
			.5,
			{ type: FlxTween.ONESHOT, onComplete: tweenCompleted }
		);
	}

	function tweenCompleted( tween:FlxTween ):Void
	{
		visible = false;
		
		disposeTween();
	}

	override public function reset( x:Float, y:Float ):Void
	{
		super.reset( x, y );
		
		isCollected = false;
		visible = true;
		alpha = 1;
		angle = 0;
		
		disposeTween();
		startAnimation();
	}

	function startAnimation():Void
	{
		tween = FlxTween.tween( 
			scale,
			{ x: 1, y: 1 },
			.4,
			{ type: FlxTween.PINGPONG, ease: FlxEase.sineIn, loopDelay: Math.random() }
		);
	}
	
	function disposeTween():Void
	{
		if ( tween != null )
		{
			tween.cancel();
			tween.destroy();
			tween = null;
		}
	}
}