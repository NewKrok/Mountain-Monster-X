package mmx.game;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import hpp.flixel.util.HPPAssetManager;
import mmx.datatype.CarData;

class AbstractCar extends FlxSpriteGroup
{
	var carData:CarData;
	
	public var carBodyGraphics:FlxSprite;
	public var wheelRightGraphics:FlxSprite;
	public var wheelLeftGraphics:FlxSprite;
	
	public function new( carData:CarData, scale:Float = 1 ) 
	{
		super();
		
		this.carData = carData;
		
		buildGraphics();
		
		carBodyGraphics.scale = new FlxPoint( scale, scale );
		wheelRightGraphics.scale = new FlxPoint( scale, scale );
		wheelLeftGraphics.scale = new FlxPoint( scale, scale );
	}
	
	function buildGraphics():Void
	{
		add( carBodyGraphics = HPPAssetManager.getSprite( "car_body_" + carData.graphicId ) );
		carBodyGraphics.antialiasing = true;
		
		add( wheelRightGraphics = HPPAssetManager.getSprite( "wheel_" + carData.graphicId ) );
		wheelRightGraphics.antialiasing = true;
		
		add( wheelLeftGraphics = HPPAssetManager.getSprite( "wheel_" + carData.graphicId ) );
		wheelLeftGraphics.antialiasing = true;
	}
}