package mmx.game.substate;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import hpp.flixel.ui.HPPButton;
import hpp.flixel.ui.HPPHUIBox;

/**
 * ...
 * @author Krisztian Somoracz
 */ 
class PausePanel extends FlxSubState
{
	var resumeButton:HPPButton;
	var restartButton:HPPButton;
	var exitButton:HPPButton;
	
	var buttonContainer:HPPHUIBox;
	var baseBack:FlxSprite;
	var container:FlxSpriteGroup;
	
	var resumeRequest:HPPButton->Void;
	var restartRequest:HPPButton->Void;
	var exitRequest:HPPButton->Void;
	
	function new( resumeRequest:HPPButton->Void, restartRequest:HPPButton->Void, exitRequest:HPPButton->Void ):Void
	{
		super();
		
		this.exitRequest = exitRequest;
		this.restartRequest = restartRequest;
		this.resumeRequest = resumeRequest;
	}

	override public function create():Void
	{
		super.create();

		build();
	}

	function build():Void
	{
		add( container = new FlxSpriteGroup() );
		container.scrollFactor.set();
		
		container.add( baseBack = new FlxSprite() );
		baseBack.makeGraphic( FlxG.stage.stageWidth, FlxG.stage.stageHeight, FlxColor.BLACK );
		baseBack.alpha = .5;
		
		container.add( buttonContainer = new HPPHUIBox( 20 ) );
		
		buttonContainer.add( resumeButton = new HPPButton( "", resumeRequest, "large_resume_button" ) );
		resumeButton.overScale = .98;
		
		buttonContainer.add( restartButton = new HPPButton( "", restartRequest, "large_restart_button" ) );
		restartButton.overScale = .98;
		
		buttonContainer.add( exitButton = new HPPButton( "", exitRequest, "large_exit_button" ) );
		exitButton.overScale = .98;
		
		buttonContainer.x = FlxG.stage.stageWidth / 2 - buttonContainer.width / 2;
		buttonContainer.y = FlxG.stage.stageHeight / 2 - buttonContainer.height / 2;
	}
}