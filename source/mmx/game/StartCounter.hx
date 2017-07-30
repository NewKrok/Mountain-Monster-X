package mmx.game;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;
import hpp.flixel.util.HPPAssetManager;

/**
 * ...
 * @author Krisztian Somoracz
 */
class StartCounter extends FlxSpriteGroup
{
	var onCompleteCallback:Void->Void;

	var counterImages:Array<FlxSprite>;
	var animationIndex:UInt;
	var showTween:VarTween;
	var hideTween:VarTween;

	public function new( onCompleteCallback:Void->Void )
	{
		super();

		this.onCompleteCallback = onCompleteCallback;

		build();

		scrollFactor.set();
	}

	function build():Void
	{
		counterImages = [];
		for ( i in 0...3 )
		{
			var counterImage:FlxSprite = HPPAssetManager.getSprite( "counter_" + ( 3 - i ) );
			counterImages.push( counterImage );
			counterImage.alpha = 0;
			add( counterImage );
		}
	}

	function resetCounterImages():Void
	{
		for ( i in 0...3 )
		{
			var counterImage:FlxSprite = counterImages[i];
			counterImage.x = FlxG.width / 2 - counterImage.width / 2;
			counterImage.y = FlxG.height / 2;
			counterImage.alpha = 0;
		}
	}
	
	public function start():Void
	{
		disposeTweens();
		animationIndex = 0;
		resetCounterImages();
		handleNextAnimation( null );
	}
	
	function disposeTweens():Void
	{
		if ( hideTween != null )
		{
			hideTween.cancel();
			hideTween.destroy();
			hideTween = null;
		}
		
		if ( showTween != null )
		{
			showTween.cancel();
			showTween.destroy();
			showTween = null;
		}
	}
	
	function handleNextAnimation( tween:FlxTween ):Void
	{
		if( animationIndex > 0 )
		{
			hideTween = FlxTween.tween( 
				counterImages[ animationIndex - 1 ],
				{ alpha: 0, y: animationIndex == counterImages.length ? counterImages[ animationIndex - 1 ].y : FlxG.height / 2 - 200 },
				.4,
				{ startDelay: .3, ease: FlxEase.cubeOut }
			);
		}
		
		if ( animationIndex == counterImages.length )
		{
			onCompleteCallback();
		}
		else
		{
			if( animationIndex < counterImages.length )
			{
				showTween = FlxTween.tween( 
					counterImages[ animationIndex ],
					{ alpha: 1, y: FlxG.height / 2 - 100 },
					.4,
					{ startDelay: .2, onComplete: handleNextAnimation, ease: FlxEase.cubeOut }
				);
			}

			animationIndex++;
		}
	}
}