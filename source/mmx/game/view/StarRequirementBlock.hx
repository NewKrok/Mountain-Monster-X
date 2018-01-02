package mmx.game.view;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import hpp.flixel.ui.HPPHUIBox;
import hpp.flixel.ui.PlaceHolder;
import hpp.flixel.util.HPPAssetManager;
import hpp.ui.VAlign;
import hpp.util.NumberUtil;
import mmx.assets.Fonts;

/**
 * ...
 * @author Krisztian Somoracz
 */
class StarRequirementBlock extends FlxSpriteGroup
{
	var container:HPPHUIBox = new HPPHUIBox();

	public function new(starRequirements:Array<UInt>)
	{
		super();

		container = new HPPHUIBox(2, VAlign.MIDDLE);

		var starPattern:Array<Array<String>> = [
			["small_star_reached", "small_star_normal", "small_star_normal"],
			["small_star_reached", "small_star_reached", "small_star_normal"],
			["small_star_reached", "small_star_reached", "small_star_reached"]
		];

		for (i in 0...3)
		{
			for (j in 0...3)
				container.add(HPPAssetManager.getSprite(starPattern[i][j]));

			container.add(new PlaceHolder(5, 1));

			var text:FlxText = new FlxText(0, 0, 0, NumberUtil.formatNumber(starRequirements[i]), 18);
			text.autoSize = true;
			text.color = FlxColor.WHITE;
			text.alignment = "left";
			text.font = Fonts.AACHEN_MEDIUM;
			container.add(text);

			if (i != 2)
				container.add(new PlaceHolder(60, 1));
		}

		add(new PlaceHolder(573, 45, 0x44000000));
		add(container);

		container.x = width / 2 - container.width / 2;
		container.y = height / 2 - container.height / 2;
	}
}