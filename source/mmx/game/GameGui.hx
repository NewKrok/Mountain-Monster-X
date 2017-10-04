package mmx.game;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import hpp.flixel.ui.HPPButton;
import mmx.AppConfig;
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
	var fpsCounter:FPSCounter;
	
	var pauseButton:HPPButton;
	
	public function new( resumeGameCallBack:Void->Void, pauseGameCallBack:HPPButton->Void ) 
	{
		super();
		
		add( coinCounter = new CoinCounter() );
		coinCounter.x = 10;
		coinCounter.y = 10;
		
		add( timeCounter = new TimeCounter() );
		timeCounter.x = FlxG.width / 2 - timeCounter.width / 2;
		timeCounter.y = 10;
		
		if ( AppConfig.SHOW_FPS )
		{
			add( fpsCounter = new FPSCounter() );
			fpsCounter.x = FlxG.width - fpsCounter.width - 10;
			fpsCounter.y = FlxG.height - fpsCounter.height - 10;
		}
		
		add( startCounter = new StartCounter( resumeGameCallBack ) );
		
		add( pauseButton = new HPPButton( "", pauseGameCallBack, "pause_button" ) );
		pauseButton.overScale = .98;
		pauseButton.x = FlxG.stage.stageWidth - pauseButton.width - 10;
		pauseButton.y = 10;
		
		scrollFactor.set();
	}
	
	public function pause():Void
	{
		startCounter.stop();
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