package mmx.game.terrain;

import flash.geom.Matrix;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Krisztian Somoracz
 */
class BrushTerrain extends FlxSprite
{
	var linePointsInput:Array<BrushArea> = [];
	var linePoints:Array<BrushArea>;
	
	var vertices:Array<Float>;
	var indices:Array<Int>;
	var uvtData:Array<Float>;
	var lastLength:Float = 0;
	var segLength:Float = 0;
	
	public function new ( levelSize:Rectangle, groundPoints:Array<FlxPoint>, brushTexture:FlxGraphic, terrainContentTexture:FlxGraphic, textureMaxWidth:Float, textureHeight:Float, scaleGroundSize:Float = 1, groundBaseHeight:Float = 700 )
	{
		super();
		
		groundPoints = optimizeGroundPointsToGraphics( groundPoints, brushTexture.width, textureMaxWidth );
		textureMaxWidth *= scaleGroundSize;
		textureHeight *= scaleGroundSize;
		BrushArea.lw = textureHeight;
		
		var graphicContainer:Sprite = new Sprite();
		var scaleMatrix:Matrix = new Matrix();
		scaleMatrix.scale( scaleGroundSize, scaleGroundSize );
		graphicContainer.graphics.beginBitmapFill( terrainContentTexture.bitmap, scaleMatrix );
		
		for ( point in groundPoints )
		{
			graphicContainer.graphics.lineTo( point.x * scaleGroundSize, point.y * scaleGroundSize );
		}
		
		var brushArea:BrushArea;
		var index:Int = cast groundPoints.length - 1;
		
		for ( i in 0...cast groundPoints.length )
		{
			graphicContainer.graphics.lineTo( groundPoints[index].x * scaleGroundSize, groundPoints[index].y * scaleGroundSize + groundBaseHeight );
		
			if ( i == 0 )
			{
				brushArea = new BrushArea( groundPoints[i].x * scaleGroundSize, groundPoints[i].y * scaleGroundSize );
				linePointsInput.push( brushArea );
			}
			else
			{
				brushArea = new BrushArea( groundPoints[i].x * scaleGroundSize, groundPoints[i].y * scaleGroundSize, linePointsInput[linePointsInput.length - 1] );
				linePointsInput.push( brushArea );
			}
			if ( i == groundPoints.length - 2 )
			{
				brushArea = new BrushArea( groundPoints[i + 1].x * scaleGroundSize, groundPoints[i + 1].y * scaleGroundSize, linePointsInput[linePointsInput.length - 1] );
				linePointsInput.push( brushArea );
			}
			
			index--;
		}
		graphicContainer.graphics.endFill();
		
		calculateGraphicTriangles();
		
		var brushBitmapData = new BitmapData( cast brushTexture.bitmap.width / 2, cast brushTexture.bitmap.height / 2, true, 0x60 );
		brushBitmapData.draw( brushTexture.bitmap, scaleMatrix );
		renderTriangles( graphicContainer, brushBitmapData );
		
		var graphicBitmap:BitmapData = new BitmapData( cast levelSize.width * scaleGroundSize, cast levelSize.height * scaleGroundSize, true, 0x60 );
		graphicBitmap.draw( graphicContainer );
		
		loadGraphic( graphicBitmap );
	}
	
	function optimizeGroundPointsToGraphics( groundPoints:Array<FlxPoint>, textureWidth:Float, textureMaxWidth:Float ):Array<FlxPoint>
	{
		var result:Array<FlxPoint> = [];
		
		var index:UInt = 0;
		for ( i in 0...groundPoints.length - 1 )
		{
			var lineLength:Float = groundPoints[i + 1].distanceTo( groundPoints[i] );
			
			if ( lineLength < textureMaxWidth )
			{
				result.push( groundPoints[i] );
			}
			else
			{
				var angle:Float = Math.atan2( groundPoints[i + 1].y - groundPoints[i].y, groundPoints[i + 1].x - groundPoints[i].x );
				var pieces:UInt = Math.ceil( lineLength / ( textureWidth < textureMaxWidth ? textureWidth : textureMaxWidth ) );
				var blockSize = lineLength / pieces;

				for ( j in 0...pieces )
				{
					var newPoint:FlxPoint = new FlxPoint( 
						groundPoints[i].x + blockSize * j * Math.cos( angle ),
						groundPoints[i].y + blockSize * j * Math.sin( angle )
					);
					
					result.push( newPoint );
				}
			}
		}
		
		return result;
	}
	
	function calculateGraphicTriangles():Void
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
		
		var index:Int = 0;
		for ( i in 0...cast linePoints.length / 2 - 1 )
		{
			lp = linePoints[index];
			vertices = vertices.concat( [lp.xL + 140, lp.yL, lp.xR + 140, lp.yR] );
			
			if ( index == linePoints.length - 1 )
			{
				lp = linePoints[index];
			}
			else
			{
				lp = linePoints[index + 1];
			}
			
			vertices = vertices.concat( [lp.xL + 140, lp.yL, lp.xR + 140, lp.yR] );
			indices = indices.concat( [count, count + 1, count + 2, count + 1, count + 2, count + 3] );
			indices = indices.concat( [count + 2, count + 3, count + 4, count + 3, count + 4, count + 5] );
			uvtData = uvtData.concat( [0, 0, 0, 1, .5, 0, .5, 1] );
			
			count += 4;
			index += 2;
		}
	}
	
	function renderTriangles( graphicContainer:Sprite, brushTexture:BitmapData ):Void
	{
		graphicContainer.graphics.beginBitmapFill( brushTexture, null, true, true );
		graphicContainer.graphics.drawTriangles( vertices, indices, uvtData );
		graphicContainer.graphics.endFill();
	}
}