package mmx.menu.substate;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIButton;
import hpp.flixel.ui.HPPButton;
import hpp.flixel.ui.HPPVUIBox;
import mmx.common.GameConfig;
import mmx.common.view.LongBackButton;

/**
 * ...
 * @author Krisztian Somoracz
 */
class SettingsPage extends FlxSubState
{
	var openWelcomePage:HPPButton->Void;
	
	var showFPSCheckbox:FlxUIButton;
	var backButton:HPPButton;
	
	function new( openWelcomePage:HPPButton->Void ):Void
	{
		super();
		
		this.openWelcomePage = openWelcomePage;
	}

	override public function create():Void
	{
		super.create();

		build();
	}

	function build():Void
	{
		var container:HPPVUIBox = new HPPVUIBox( 20 );
		
		showFPSCheckbox = new FlxUIButton( 0, 0, "SHOW FPS", setFPS );
		showFPSCheckbox.toggled = GameConfig.SHOW_FPS;
		container.add( showFPSCheckbox );
		
		container.x = FlxG.width / 2 - container.width / 2;
		container.y = 40;
		
		add( backButton = new LongBackButton( openWelcomePage ) );
		backButton.x = FlxG.width / 2 - backButton.width / 2;
		backButton.y = FlxG.height - 40 - backButton.height;
	}
	
	function setFPS():Void
	{
		showFPSCheckbox.toggled = !showFPSCheckbox.toggled;
		GameConfig.SHOW_FPS = showFPSCheckbox.toggled;
	}
}