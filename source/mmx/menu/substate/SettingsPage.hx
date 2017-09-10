package mmx.menu.substate;

import flixel.FlxG;
import flixel.FlxSubState;
import hpp.flixel.ui.HPPButton;
import mmx.common.view.LongBackButton;

/**
 * ...
 * @author Krisztian Somoracz
 */
class SettingsPage extends FlxSubState
{
	var openWelcomePage:HPPButton->Void;
	
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
		add( backButton = new LongBackButton( openWelcomePage ) );
		backButton.x = FlxG.width / 2 - backButton.width / 2;
		backButton.y = FlxG.height - 40 - backButton.height;
	}
}