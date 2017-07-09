package hpp.flixel.util;

import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import hpp.flixel.display.FPPMovieClip;

/**
 * ...
 * @author Krisztian Somoracz
 */
class AssetManager 
{
	static var loadedAtlas:Array<FlxAtlasFrames> = [];
	
	public static function loadAtlas( atlasUrl:String, descriptionUrl:String ):Void
	{
		loadedAtlas.push( FlxAtlasFrames.fromSparrow( atlasUrl, descriptionUrl ) );
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
	
	public static function getSprite( assetId:String ):FlxSprite
	{
		var sprite:FlxSprite = new FlxSprite();
		
		sprite.loadGraphic( getGraphic( assetId ) );
		
		return sprite;
	}
	
	public static function getMovieClip( assetId:String ):FPPMovieClip
	{
		var movieClip:FPPMovieClip = new FPPMovieClip();
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
		
		return selectedAtlas;
	}
}