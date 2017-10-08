package;

import flixel.FlxG;
import hpp.flixel.system.HPPFlxMain;
import mmx.state.MenuState;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var fps:FPS;
	
	public function new()
	{
		super();
		
		addChild( new HPPFlxMain( 0, 0, MenuState ) );
		
		addChild( fps = new FPS() );
		fps.visible = false;
		
		FlxG.mouse.unload();
		FlxG.mouse.useSystemCursor = true;
	}
}