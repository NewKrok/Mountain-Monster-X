package mmx.game.terrain;

import flash.geom.Matrix;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.display.TriangleCulling;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Krisztian Somoracz
 */
class BrushTerrain extends FlxSprite
{
	var linePointsInput:Array<BrushArea>;
	var linePoints:Array<BrushArea>;
	
	var vertices:Array<Float>;
	var indices:Array<Int>;
	var uvtData:Array<Float>;
	var lastLength:Float = 0;
	var segLength:Float = 0;
	
	public function new ( levelSize:Rectangle, groundPoints:Array<FlxPoint>, brushTexture:FlxGraphic, terrainContentTexture:FlxGraphic, textureMaxWidth:Float, textureHeight:Float, scale:Float = 1 )
	{
		super();
		linePointsInput = [];
		
		textureMaxWidth *= scale;
		textureHeight *= scale;
		
		BrushArea.lw = textureHeight;
		
		var graphicContainer:Sprite = new Sprite();
		var scaleMatrix:Matrix = new Matrix();
		scaleMatrix.scale( scale, scale );
		graphicContainer.graphics.beginBitmapFill( terrainContentTexture.bitmap, scaleMatrix );
		
		for ( point in groundPoints )
		{
			graphicContainer.graphics.lineTo( point.x * scale, point.y * scale );
		}
		
		var lp:BrushArea;
		var index:Int = cast groundPoints.length - 1;
		
		for ( i in 0...cast groundPoints.length )
		{
			graphicContainer.graphics.lineTo( groundPoints[index].x * scale, groundPoints[index].y * scale + 700 );
		
			if ( i == 0 )
			{
				lp = new BrushArea( groundPoints[i].x * scale, groundPoints[i].y * scale );
				linePointsInput.push( lp );
			}
			else
			{
				lp = new BrushArea( groundPoints[i].x * scale, groundPoints[i].y * scale, linePointsInput[linePointsInput.length - 1] );
				linePointsInput.push( lp );
			}
			if ( i == groundPoints.length - 2 )
			{
				lp = new BrushArea( groundPoints[i + 1].x * scale, groundPoints[i + 1].y * scale, linePointsInput[linePointsInput.length - 1] );
				linePointsInput.push( lp );
			}
			
			index--;
		}
		graphicContainer.graphics.endFill();
		
		calculate();
		var test = new BitmapData( cast brushTexture.bitmap.width / 2, cast brushTexture.bitmap.height / 2, true, 0x60 );
		test.draw( brushTexture.bitmap, scaleMatrix );
		render( graphicContainer, test );
		
		var graphicBitmap:BitmapData = new BitmapData( cast levelSize.width * scale, cast levelSize.height * scale, true, 0x60 );
		graphicBitmap.draw( graphicContainer );
		
		loadGraphic( graphicBitmap );
	}
	
	function calculate():Void
	{
		segLength = 1;
		lastLength = 0;
		linePoints = [];
		linePoints.push ( linePointsInput[0] );
		vertices = [];
		indices = [];
		uvtData = [];
		var lp:BrushArea;
		
		for ( i in 1...linePointsInput.length )
		{
			lp = linePointsInput[i];
			if ( lp.currentLength > lastLength + segLength )
			{
				lastLength = lp.currentLength;
				linePoints.push ( lp );
			}
		}
		var count = 0;
		var uvStep:Float = .5;
		var currentUV:Float = 0;
		
		var index:Int = 0;
		for ( i in 0...cast linePoints.length / 2 - 1 )
		{
			lp = linePoints[index];
			vertices = vertices.concat( [lp.xL + 150, lp.yL, lp.xR + 150, lp.yR] );
			
			if ( index == linePoints.length - 1 )
			{
				lp = linePoints[index];
			}
			else
			{
				lp = linePoints[index + 1];
			}
			
			vertices = vertices.concat( [lp.xL + 150, lp.yL, lp.xR + 150, lp.yR] );
			indices = indices.concat( [count, count + 1, count + 2, count + 1, count + 2, count + 3] );
			indices = indices.concat( [count + 2, count + 3, count + 4, count + 3, count + 4, count + 5] );
			uvtData = uvtData.concat( [currentUV, 0, currentUV, 1, currentUV + uvStep, 0, currentUV + uvStep, 1] );
			count += 4;
			currentUV += uvStep;
			currentUV += uvStep;
			
			index += 2;
		}
	}
	
	function render( graphicContainer:Sprite, brushTexture:BitmapData ):Void
	{
		graphicContainer.graphics.beginBitmapFill( brushTexture, null, true, true );
		graphicContainer.graphics.drawTriangles( vertices, indices/*, uvtData*/ );
		graphicContainer.graphics.endFill();
	}
}
