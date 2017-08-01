package hpp.flixel.util;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import haxe.Log;
import hpp.flixel.display.HPPMovieClip;

/**
 * ...
 * @author Krisztian Somoracz
 */
class HPPAssetManager 
{
	static var loadedAtlas:Array<FlxAtlasFrames> = [];
	static var loadedFonts:Array<FlxBitmapFont> = [];
	
	public static function loadXMLAtlas( atlasUrl:String, descriptionUrl:String ):Void
	{
		loadedAtlas.push( FlxAtlasFrames.fromSparrow( atlasUrl, descriptionUrl ) );
	}
	
	public static function loadJsonAtlas( atlasUrl:String, descriptionUrl:String ):Void
	{
		loadedAtlas.push( FlxAtlasFrames.fromTexturePackerJson( atlasUrl, descriptionUrl ) );
	}
	
	public static function loadXMLBitmapFont( atlasUrl:String, descriptionUrl:String ):Void
	{
		loadedFonts.push( FlxBitmapFont.fromAngelCode( atlasUrl, descriptionUrl ) );
	}
	
	public static function getGraphic( assetId:String ):FlxGraphic
	{
		var selectedFrame:FlxFrame = getFrame( assetId );
		var key:String = getAssetKeyFromFrame( selectedFrame );
		
		return FlxGraphic.fromBitmapData( selectedFrame.paint(), false, key );
	}
	
	public static function getFrame( assetId:String ):FlxFrame
	{
		return getFlxAtlasFramesByAssetId( assetId ).getByName( assetId );
	}
	
	public static function getSprite( assetId:String, antialiasing:Bool = true ):FlxSprite
	{
		var sprite:FlxSprite = new FlxSprite();
		
		sprite.loadGraphic( getGraphic( assetId ) );
		sprite.antialiasing = antialiasing;
		
		return sprite;
	}
	
	public static function getMovieClip( assetId:String, antialiasing:Bool = true ):HPPMovieClip
	{
		var movieClip:HPPMovieClip = new HPPMovieClip();
		movieClip.animationPrefix = assetId;
		
		var atlas:FlxAtlasFrames = getFlxAtlasFramesByAssetId( movieClip.animationPrefix + "00" );
		var frames:FlxFramesCollection = new FlxFramesCollection( null );
		
		for ( frame in atlas.frames )
		{
			if ( StringTools.startsWith( frame.name, assetId ) )
			{
				frames.pushFrame( frame );
			}
		}
		
		movieClip.frames = frames;
		movieClip.antialiasing = antialiasing;
		
		return movieClip;
	}
	
	static function getAssetKeyFromFrame( frame:FlxFrame ):String
	{
		var key:String = frame.parent.key;
		
		if ( frame.name != null )
		{
			key += ":" + frame.name;
		}
		else
		{
			key += ":" + frame.frame.toString();
		}
		
		return key;
	}
	
	static function getFlxAtlasFramesByAssetId( assetId:String ):FlxAtlasFrames
	{
		var selectedAtlas:FlxAtlasFrames = null;
		
		for ( element in loadedAtlas )
		{
			if ( element.getByName( assetId ) != null )
			{
				selectedAtlas = element;
				break;
			}
		}
		
		if ( selectedAtlas == null )
		{
			Log.trace( "[AssetManager] missing graphic - " + assetId );
		}
		
		return selectedAtlas;
	}
	
	public static function getBitmapFont( fontName:String ):FlxBitmapFont
	{
		return loadedFonts.filter( function( font:FlxBitmapFont ){ return font.fontName == fontName; } )[0];
	}
	
	public static function clear():Void
	{
		for ( atlas in loadedAtlas )
		{
			atlas.destroy();
		}
		loadedAtlas = [];
		
		for ( font in loadedFonts )
		{
			font.destroy();
		}
		loadedFonts = [];
	}
}