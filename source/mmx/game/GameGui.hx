package mmx.game;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import mmx.game.TimeCounter;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameGui extends FlxSpriteGroup
{
	var coinCounter:CoinCounter;
	var timeCounter:TimeCounter;
	var guiCamera:FlxCamera;
	
	public function new() 
	{
		super();
		
		add( coinCounter = new CoinCounter() );
		coinCounter.x = 10;
		coinCounter.y = 10;
		
		add( timeCounter = new TimeCounter() );
		timeCounter.x = FlxG.width / 2 - timeCounter.width / 2;
		timeCounter.y = 10;
		
		scrollFactor.set();
	}
	
	public function updateCoinCount( value:UInt ):Void
	{
		coinCounter.updateValue( value );
	}
	
	public function updateRemainingTime( value:Float ):Void
	{
		timeCounter.updateValue( value );
	}
}