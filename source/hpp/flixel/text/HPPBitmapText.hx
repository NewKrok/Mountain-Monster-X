package hpp.flixel.text;

import flixel.text.FlxBitmapText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.util.FlxColor;
import hpp.flixel.util.HPPAssetManager;

/**
 * ...
 * @author Krisztian Somoracz
 *
 * Extends FlxSpriteGroup to support set text size based on the font size.
 * At the moment it's a dirty hack but at least you can modify the text size.
 */
class HPPBitmapText extends FlxBitmapText
{
	public var fontSize( default, set ):Float;
	
	public function new( fontName:String, text:String = "", fontSize:Float = 12, textColor:Int = FlxColor.WHITE, alignment:String = "left" )
	{
		super( HPPAssetManager.getBitmapFont( fontName ) );
		
		useTextColor = true;
		
		this.alignment = alignment;
		this.text = text;
		this.textColor = textColor;
		this.fontSize = fontSize;
	}
	
	function set_fontSize( value:Float ):Float 
	{
		var spriteScale:Float = value / font.size;
		
		scale.set( spriteScale, spriteScale );
		
		return fontSize = value;
	}
}