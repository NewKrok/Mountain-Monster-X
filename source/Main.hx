package;

import flixel.FlxG;
import hpp.flixel.system.HPPFlxMain;
import hpp.util.DeviceData;
import hpp.util.JsFullScreenUtil;
import js.Browser;
import mmx.AppConfig;
import mmx.assets.Fonts;
import mmx.state.MenuState;
import mmx.util.SavedDataUtil;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var fps:FPS;

	public function new()
	{
		super();

		SavedDataUtil.load( "MountainMonsterSavedData" );
		var settingsInfo:SettingsInfo = SavedDataUtil.getSettingsInfo();

		AppConfig.IS_ALPHA_ANIMATION_ENABLED = settingsInfo.enableAlphaAnimation;
		AppConfig.SHOW_FPS = settingsInfo.showFPS;
		AppConfig.SHOW_3_STAR_REPLAY = settingsInfo.show3StarsReplay;
		AppConfig.SHOW_PLAYER_REPLAY = settingsInfo.showPlayersReplay;
		AppConfig.IS_MOBILE_DEVICE = DeviceData.isMobile();

		JsFullScreenUtil.init("openfl-content");
		Fonts.init();

		addChild( new HPPFlxMain( 0, 0, MenuState ) );

		addChild( fps = new FPS() );
		fps.visible = false;

		FlxG.mouse.unload();
		FlxG.mouse.useSystemCursor = true;

		untyped __js__("
			window.addEventListener('keydown', function(e) {
				if([32, 37, 38, 39, 40].indexOf(e.keyCode) > -1) {
					e.preventDefault();
				}
			}, false);
		");
	}
}