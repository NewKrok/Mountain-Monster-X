package mmx.game;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import hpp.flixel.ui.HPPButton;
import hpp.flixel.ui.HPPHUIBox;
import hpp.flixel.util.HPPAssetManager;
import mmx.AppConfig;
import mmx.game.NotificationHandler.Notification;
import mmx.game.TimeCounter;
import openfl.events.TouchEvent;

/**
 * ...
 * @author Krisztian Somoracz
 */
class GameGui extends FlxSpriteGroup
{
	public var controlLeftState(default, null):Bool;
	public var controlRightState(default, null):Bool;
	public var controlUpState(default, null):Bool;
	public var controlDownState(default, null):Bool;
	
	var notificationHandler:NotificationHandler;
	
	var touches:Map<Int, FlxSprite>;
	
	var coinCounter:CoinCounter;
	var timeCounter:TimeCounter;
	var startCounter:StartCounter;
	var fpsCounter:FPSCounter;
	
	var controlLeft:FlxSprite;
	var controlRight:FlxSprite;
	var controlUp:FlxSprite;
	var controlDown:FlxSprite;
	
	var pauseButton:HPPButton;
	
	public function new( resumeGameCallBack:Void->Void, pauseGameCallBack:HPPButton->Void ) 
	{
		super();
		
		touches = new Map<Int, FlxSprite>();
		
		add( coinCounter = new CoinCounter() );
		coinCounter.x = 10;
		coinCounter.y = 10;
		
		add( timeCounter = new TimeCounter() );
		timeCounter.x = FlxG.width / 2 - timeCounter.width / 2;
		timeCounter.y = 10;
		
		add(startCounter = new StartCounter(resumeGameCallBack));
		
		add(pauseButton = new HPPButton("", pauseGameCallBack, "pause_button"));
		pauseButton.overScale = .98;
		pauseButton.x = FlxG.stage.stageWidth - pauseButton.width - 10;
		pauseButton.y = 10;
		
		add(notificationHandler = new NotificationHandler());
		
		if (AppConfig.SHOW_FPS)
		{
			add(fpsCounter = new FPSCounter());
			
			if (AppConfig.IS_MOBILE_DEVICE)
			{
				fpsCounter.x = pauseButton.x - fpsCounter.width - 10;
				fpsCounter.y = 10;
			}
			else
			{
				fpsCounter.x = FlxG.width - fpsCounter.width - 10;
				fpsCounter.y = FlxG.height - fpsCounter.height - 10;
			}
		}
		
		if (AppConfig.IS_MOBILE_DEVICE)
		{
			createControlButtons();
		}
		
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
	
	function createControlButtons() 
	{
		var padding:UInt = 10;
		
		var leftBlock:HPPHUIBox = new HPPHUIBox(padding);
		add(leftBlock);
		leftBlock.add(controlLeft = HPPAssetManager.getSprite("control_left"));
		leftBlock.add(controlRight = HPPAssetManager.getSprite("control_right"));
		leftBlock.x = padding;
		leftBlock.y = FlxG.height - leftBlock.height - padding;
		
		var rightBlock:HPPHUIBox = new HPPHUIBox(padding);
		add(rightBlock);
		rightBlock.add(controlDown = HPPAssetManager.getSprite("control_down"));
		rightBlock.add(controlUp = HPPAssetManager.getSprite("control_up"));
		rightBlock.x = FlxG.width - rightBlock.width - padding;
		rightBlock.y = leftBlock.y;
		
		FlxG.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
		FlxG.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		FlxG.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
	}
	
	function onTouchBegin(e:TouchEvent) 
	{
		var touchPoint:FlxPoint = new FlxPoint(e.stageX, e.stageY);
		var touchSprite:FlxSprite = null;
		
		if (controlLeft.overlapsPoint(touchPoint))
		{
			controlLeftState = true;
			touchSprite = controlLeft;
		}
		if (controlRight.overlapsPoint(touchPoint))
		{
			controlRightState = true;
			touchSprite = controlRight;
		}
		if (controlUp.overlapsPoint(touchPoint))
		{
			controlUpState = true;
			touchSprite = controlUp;
		}
		if (controlDown.overlapsPoint(touchPoint))
		{
			controlDownState = true;
			touchSprite = controlDown;
		}
		
		if (touchSprite != null)
		{
			touchSprite.scale.set(1.1, 1.1);
			touches.set(e.touchPointID, touchSprite);
		}
	}
	
	function onTouchEnd(e:TouchEvent) 
	{
		var touchPoint:FlxPoint = new FlxPoint(e.stageX, e.stageY);
		
		if (controlLeft.overlapsPoint(touchPoint))
		{
			controlLeftState = false;
			controlLeft.scale.set(1, 1);
		}
		if (controlRight.overlapsPoint(touchPoint))
		{
			controlRightState = false;
			controlRight.scale.set(1, 1);
		}
		if (controlUp.overlapsPoint(touchPoint))
		{
			controlUpState = false;
			controlUp.scale.set(1, 1);
		}
		if (controlDown.overlapsPoint(touchPoint))
		{
			controlDownState = false;
			controlDown.scale.set(1, 1);
		}
		
		touches.remove(e.touchPointID);
	}
	
	function onTouchMove(e:TouchEvent) 
	{
		var touchPoint:FlxPoint = new FlxPoint(e.stageX, e.stageY);
		
		var touchSprite:FlxSprite = touches.get(e.touchPointID);
		
		if (touchSprite != null && !touchSprite.overlapsPoint(touchPoint))
		{
			if (touchSprite == controlLeft) controlLeftState = false;
			if (touchSprite == controlRight) controlRightState = false;
			if (touchSprite == controlUp) controlUpState = false;
			if (touchSprite == controlDown) controlDownState = false;
			
			touchSprite.scale.set(1, 1);
			touches.remove(e.touchPointID);
		}
	}
	
	public function addNotification(type:Notification):Void
	{
		notificationHandler.addEntry(type);
	}
	
	public function updateCoinCount( value:UInt ):Void
	{
		coinCounter.updateValue( value );
	}
	
	public function updateRemainingTime( value:Float ):Void
	{
		timeCounter.updateValue( value );
	}
	
	override public function destroy():Void 
	{
		FlxG.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
		FlxG.stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		FlxG.stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
		
		super.destroy();
	}
}