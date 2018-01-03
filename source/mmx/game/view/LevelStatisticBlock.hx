package mmx.game.view;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import hpp.flixel.ui.HPPHUIBox;
import hpp.flixel.ui.HPPVUIBox;
import hpp.flixel.ui.PlaceHolder;
import hpp.flixel.util.HPPAssetManager;
import hpp.ui.VAlign;
import hpp.util.TimeUtil;
import mmx.assets.Fonts;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LevelStatisticBlock extends FlxSpriteGroup
{
	var container:HPPHUIBox = new HPPHUIBox();

	var coinText:FlxText;
	var timeText:FlxText;

	public function new(collectedCoins:Float, currentTime:Float)
	{
		super();

		container = new HPPHUIBox(10, VAlign.MIDDLE);

		container.add(HPPAssetManager.getSprite("coin_icon"));
		var coinBox:HPPVUIBox = new HPPVUIBox();
		coinBox.add(new PlaceHolder(1, 4));
		coinText = new FlxText(0, 0, 0, Std.string(collectedCoins), 28);
		coinText.color = FlxColor.YELLOW;
		coinText.alignment = "left";
		coinText.font = Fonts.AACHEN_MEDIUM;
		coinBox.add(coinText);
		container.add(coinBox);

		container.add(new PlaceHolder(30, 1));

		container.add(HPPAssetManager.getSprite("time_icon"));
		var timeBox:HPPVUIBox = new HPPVUIBox();
		timeBox.add(new PlaceHolder(1, 4));
		timeText = new FlxText(0, 0, 0, TimeUtil.timeStampToFormattedTime(currentTime, TimeUtil.TIME_FORMAT_MM_SS), 28);
		timeText.color = 0xFF26FF92;
		timeText.alignment = "left";
		timeText.font = Fonts.AACHEN_MEDIUM;
		timeBox.add(timeText);
		container.add(timeBox);

		add(new PlaceHolder(573, 45, 0x44000000));
		add(container);

		container.x = width / 2 - container.width / 2;
		container.y = height / 2 - container.height / 2;
	}

	public function updateData(collectedCoins:Float, currentTime:Float)
	{
		coinText.text = Std.string(collectedCoins);
		timeText.text = TimeUtil.timeStampToFormattedTime(currentTime, TimeUtil.TIME_FORMAT_MM_SS);
	}
}