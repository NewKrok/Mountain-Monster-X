package mmx.game;

import apostx.replaykit.IPlaybackPerformer;
import flixel.FlxSprite;
import haxe.Unserializer;
import mmx.datatype.CarData;

class GhostCar extends AbstractCar implements IPlaybackPerformer
{
	public function new( carData:CarData, scale:Float = 1 ) 
	{
		super( carData, scale );
		
		alpha = 0.5;
	}
	
	public function sync(car:AbstractCar):Void
	{
		syncSprite( carBodyGraphics, car.carBodyGraphics );
		syncSprite( wheelRightGraphics, car.wheelRightGraphics );
		syncSprite( wheelLeftGraphics, car.wheelLeftGraphics );
	}
	
	private function syncSprite( from:FlxSprite, to:FlxSprite ):Void
	{
		to.x = from.x;
		to.y = from.y;
		to.angle = from.angle;
	}
	
	public function unserializeWithTransition( from:Unserializer, to:Unserializer, percent:Float ):Void 
	{
		unserializeSprite( from, to, percent, carBodyGraphics );
		unserializeSprite( from, to, percent, wheelRightGraphics );
		unserializeSprite( from, to, percent, wheelLeftGraphics );
	}
	
	private function unserializeSprite( from:Unserializer, to:Unserializer, percent:Float, sprite:FlxSprite ):Void
	{
		sprite.x = calculateLinearTransitionValue( from.unserialize(), to.unserialize(), percent );
		sprite.y = calculateLinearTransitionValue( from.unserialize(), to.unserialize(), percent );
		sprite.angle = calculateLinearTransitionValue( from.unserialize(), to.unserialize(), percent );
	}
	
	private function calculateLinearTransitionValue( from:Float, to:Float, percent:Float ):Float
	{
		return from + (to - from) * percent;
	}
}