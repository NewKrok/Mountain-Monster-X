package;

import flixel.FlxGame;
import mmx.state.MenuState;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		
		addChild( new FlxGame( 0, 0, MenuState ) );
		addChild( new FPS( stage.stageWidth - 75, 30, 0xffffff ) );
	}
}