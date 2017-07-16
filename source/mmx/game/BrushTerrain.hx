package mmx.game;

import flash.geom.Matrix;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Krisztian Somoracz
 */
class BrushTerrain extends FlxSprite
{
	public function new ( levelSize:Rectangle, groundPoints:Array<FlxPoint>, brushTexture:FlxGraphic, terrainContentTexture:FlxGraphic, textureMaxWidth:Float, textureHeight:Float, scale:Float = 1 )
	{
		super();
		
		var graphicContainer:Sprite = new Sprite();
		var scaleMatrix:Matrix = new Matrix();
		scaleMatrix.scale( scale, scale );
		graphicContainer.graphics.beginBitmapFill( terrainContentTexture.bitmap, scaleMatrix );
		
		for ( point in groundPoints )
		{
			graphicContainer.graphics.lineTo( point.x * scale, point.y * scale );
		}
		
		var index:Int = cast groundPoints.length - 1;
		for ( i in 0...cast groundPoints.length )
		{
			graphicContainer.graphics.lineTo( groundPoints[index].x * scale, groundPoints[index].y * scale + 700 );
		
			index--;
		}
		graphicContainer.graphics.endFill();
		
		var graphicBitmap:BitmapData = new BitmapData( cast levelSize.width / 2, cast levelSize.height / 2, 0x60 );
		graphicBitmap.draw( graphicContainer );
		
		loadGraphic( graphicBitmap );
	}
}