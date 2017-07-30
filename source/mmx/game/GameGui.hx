package mmx.game;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import mmx.game.TimeCounter;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameGui extends FlxSpriteGroup
{
	var coinCounter:CoinCounter;
	var timeCounter:TimeCounter;
	var startCounter:StartCounter;
	
	public function new( resumeGameCallBack:Void->Void, pauseGameCallBack:Void->Void ) 
	{
		super();
		
		add( coinCounter = new CoinCounter() );
		coinCounter.x = 10;
		coinCounter.y = 10;
		
		add( timeCounter = new TimeCounter() );
		timeCounter.x = FlxG.width / 2 - timeCounter.width / 2;
		timeCounter.y = 10;
		
		add( startCounter = new StartCounter( resumeGameCallBack ) );
		
		scrollFactor.set();
	}
	
	public function resumeGameRequest():Void
	{
		startCounter.start();
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