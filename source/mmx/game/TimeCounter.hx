package mmx.game;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import hpp.flixel.text.HPPBitmapText;
import hpp.flixel.util.HPPAssetManager;
import hpp.flixel.util.HPPTimeUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */ 
class TimeCounter extends FlxSpriteGroup
{
	var background:FlxSprite;
	var text:HPPBitmapText;

	public function new()
	{
		super();

		add( background = HPPAssetManager.getSprite( "gui_time_back" ) );

		text = new HPPBitmapText( "Aachen-Light", "00:00", 30, 0xFF26FF92, "center" );
		text.autoSize = false;
		text.fieldWidth = cast width + 45;
		
		add( text );
	}

	public function updateValue( value:Float ):Void
	{
		if( value <= 1000 * 10 )
		{
			text.textColor = 0xFFFFB399;
		}
		else
		{
			text.textColor = 0xFF26FF92;
		}
		
		text.text = HPPTimeUtil.timeStampToFormattedTime( value, HPPTimeUtil.TIME_FORMAT_MM_SS );
	}
}