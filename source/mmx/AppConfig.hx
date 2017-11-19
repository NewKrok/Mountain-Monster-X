package mmx;

/**
 * ...
 * @author Krisztian Somoracz
 */
class AppConfig 
{
	public static inline var GAME_NAME:String = "MountainMonster";
	public static inline var GAME_VERSION:String = "1.2.1";
	
	public static inline var MAXIMUM_GAME_TIME_BONUS:Int = 12000;
	public static inline var COIN_SCORE_MULTIPLIER:Int = 50;
	
	public static var IS_ALPHA_ANIMATION_ENABLED:Bool = false;
	public static var SHOW_FPS:Bool = false;
	
	public static var IS_MOBILE_DEVICE:Bool = false;
	public static var IS_DESKTOP_DEVICE(get, null):Bool;
	
	static function get_IS_DESKTOP_DEVICE():Bool 
	{
		return !IS_MOBILE_DEVICE;
	}
}