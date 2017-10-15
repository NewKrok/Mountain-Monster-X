package mmx.game;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import hpp.flixel.util.HPPAssetManager;
import hpp.util.HPPTimeUtil;
import mmx.assets.Fonts;

/**
 * ...
 * @author Krisztian Somoracz
 */ 
class TimeCounter extends FlxSpriteGroup
{
	var background:FlxSprite;
	var text:FlxText;

	public function new(defaultValue:Float = 0)
	{
		super();

		add( background = HPPAssetManager.getSprite("gui_time_back"));

		text = new FlxText( 40, 0, cast width - 40, "00:00", 33 );
		text.autoSize = false;
		text.color = 0xFF26FF92;
		text.alignment = "center";
		text.font = Fonts.AACHEN_MEDIUM;
		text.y = 12;
		
		add(text);
		
		updateValue(defaultValue);
	}

	public function updateValue(value:Float):Void
	{
		if(value <= 1000 * 10)
		{
			text.color = 0xFFFFB399;
		}
		else
		{
			text.color = 0xFF26FF92;
		}
		
		text.text = HPPTimeUtil.timeStampToFormattedTime(value, HPPTimeUtil.TIME_FORMAT_MM_SS);
	}
}