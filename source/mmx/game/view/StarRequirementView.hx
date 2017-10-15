package mmx.game.view;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import hpp.flixel.ui.HPPHUIBox;
import hpp.flixel.ui.HPPVUIBox;
import hpp.flixel.ui.PlaceHolder;
import hpp.flixel.util.HPPAssetManager;
import hpp.util.HPPNumberUtil;
import mmx.assets.Fonts;

/**
 * ...
 * @author Krisztian Somoracz
 */
class StarRequirementView extends HPPHUIBox
{
	var starView:FlxSprite;
	var description:FlxText;

	public function new(starCount:UInt, requirement:UInt)
	{
		super(20);

		add(starView = HPPAssetManager.getSprite("large_star_" + starCount));

		var textContainer:HPPVUIBox = new HPPVUIBox();
		
		textContainer.add(new PlaceHolder(0, 10));
		
		var text:FlxText = new FlxText(0, 0, 0, "EARN " + HPPNumberUtil.formatNumber(requirement) + " SCORE", 33);
		text.autoSize = true;
		text.color = FlxColor.WHITE;
		text.alignment = "left";
		text.font = Fonts.AACHEN_MEDIUM;
		textContainer.add(text);
		
		add(textContainer);
	}
}