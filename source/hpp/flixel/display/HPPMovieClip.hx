package hpp.flixel.display;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * ...
 * @author Krisztian Somoracz
 */
class HPPMovieClip extends FlxSprite
{
	inline static var defaultAnimName:String = "anim";
	
	public var animationPrefix( default, default ):String = "";
	public var isPlaying( default, null ):Bool = false;
	public var frameRate( default, set ):UInt = 30;
	public var currentFrame( get, set ):UInt;
	
	public function play():Void
	{
		animation.play( defaultAnimName );
		
		isPlaying = true;
	}
	
	public function gotoAndPlayFromRandomIndex():Void
	{
		animation.randomFrame();
		
		play();
	}
	
	public function gotoAndPlay( frameIndex:UInt ):Void
	{
		animation.frameIndex = frameIndex;
		
		play();
	}
	
	public function gotoAndStop( frameIndex:UInt ):Void
	{
		stop();
		
		animation.frameIndex = frameIndex;
	}
	
	public function gotoAndStopToRandomIndex():Void
	{
		stop();
		
		animation.randomFrame();
	}
	
	public function stop():Void
	{
		animation.stop();
		
		isPlaying = false;
	}
	
	override public function set_frames( Frames:FlxFramesCollection ):FlxFramesCollection
	{
		super.frames = Frames;
		updateAnimationState();
	
		return Frames;
	}
	
	public function set_frameRate( value:UInt ):UInt
	{
		frameRate = value;
		updateAnimationState();
		
		return frameRate;
	}
	
	public function set_currentFrame( value:UInt ):UInt
	{
		if ( isPlaying )
		{
			gotoAndPlay( value );
		}
		else
		{
			gotoAndStop( value );
		}
		
		return value;
	}
	
	public function get_currentFrame():UInt
	{
		return animation.frameIndex;
	}
	
	function updateAnimationState():Void
	{
		if ( animation != null )
		{
			animation.addByPrefix( defaultAnimName, animationPrefix, frameRate );
			
			if ( isPlaying )
			{
				play();
			}
		}
	}
}