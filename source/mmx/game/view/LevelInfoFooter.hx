package mmx.game.view;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import hpp.flixel.ui.HPPHUIBox;
import hpp.flixel.ui.PlaceHolder;
import hpp.util.NumberUtil;
import hpp.util.TimeUtil;
import mmx.assets.Fonts;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LevelInfoFooter extends FlxSpriteGroup
{
	var container:HPPHUIBox = new HPPHUIBox();
	var bestScoreText:FlxText;
	var bestTimeText:FlxText;

	public function new(isCompleted:Bool, score:Float, time:Float)
	{
		super();

		container = new HPPHUIBox();

		var bestScoreLabelText:FlxText = new FlxText(0, 0, 0, "Best score ", 20);
		bestScoreLabelText.autoSize = true;
		bestScoreLabelText.color = FlxColor.WHITE;
		bestScoreLabelText.alignment = "left";
		bestScoreLabelText.font = Fonts.AACHEN;
		container.add(bestScoreLabelText);

		bestScoreText = new FlxText(0, 0, 0, isCompleted ? NumberUtil.formatNumber(score) : "N/A", 20);
		bestScoreText.autoSize = true;
		bestScoreText.color = FlxColor.YELLOW;
		bestScoreText.alignment = "left";
		bestScoreText.font = Fonts.AACHEN;
		container.add(bestScoreText);

		container.add(new PlaceHolder(180,0));

		var bestTimeLabelText:FlxText = new FlxText(0, 0, 0, "Best time ", 20);
		bestTimeLabelText.autoSize = true;
		bestTimeLabelText.color = FlxColor.WHITE;
		bestTimeLabelText.alignment = "left";
		bestTimeLabelText.font = Fonts.AACHEN;
		container.add(bestTimeLabelText);

		bestTimeText = new FlxText(0, 0, 0, isCompleted ? TimeUtil.timeStampToFormattedTime(time, TimeUtil.TIME_FORMAT_MM_SS_MS) : "N/A", 20);
		bestTimeText.autoSize = true;
		bestTimeText.color = FlxColor.YELLOW;
		bestTimeText.alignment = "left";
		bestTimeText.font = Fonts.AACHEN;
		container.add(bestTimeText);

		add(new PlaceHolder(573, 35, 0x44000000));
		add(container);

		container.x = width / 2 - container.width / 2;
		container.y = height / 2 - container.height / 2;
	}

	public function updateData(isCompleted:Bool, score:Float, time:Float):Void
	{
		bestScoreText.text = isCompleted ? NumberUtil.formatNumber(score) : "N/A";
		bestTimeText.text = isCompleted ? TimeUtil.timeStampToFormattedTime(time, TimeUtil.TIME_FORMAT_MM_SS_MS) : "N/A";
	}
}