package mmx.game;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.TweenOptions;
import hpp.flixel.util.AssetManager;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Coin extends FlxSprite
{
	public var isCollected( default, null ):Bool;
	
	public function new( x:Float, y:Float )
	{
		super( x, y );
		
		loadGraphic( AssetManager.getGraphic( "coin" ) );
	}
	
	public function collect():Void
	{
		isCollected = true;
		/*
		Tweener.removeTweens( this );
		Tweener.addTween( this, {
			time: .5,
			x: x - 100,
			y: y - 50,
			rotation: Math.PI * 6,
			alpha: 0,
			transition: 'linear',
			onComplete: hide
		} );*/
	}

	private function hide():Void
	{
		visible = false;
	}

	public function resetToStart():Void
	{
		isCollected = false;
		visible = true;
		alpha = 1;
		startAnimation();
	}

	function startAnimation():Void
	{
		FlxTween.tween( this, { scale: .9 }, .2 );
		
		/*Tweener.removeTweens( this );
		Tweener.addTween( this, {time: .2, scaleX: .9, scaleY: .9, transition: 'linear'} );
		Tweener.addTween( this, {time: .4, delay: .2, scaleX: 1.1, scaleY: 1.1, transition: 'linear'} );
		Tweener.addTween( this, {time: .2, delay: .6, scaleX: 1, scaleY: 1, transition: 'linear'} );
		Tweener.addTween( this, {time: 1 + Math.random() * 3, onComplete: startAnimation, transition: 'linear'} );*/
	}
}