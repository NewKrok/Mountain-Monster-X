package mmx.game.view;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import hpp.flixel.ui.HPPHUIBox;
import hpp.flixel.ui.HPPToggleButton;
import hpp.flixel.ui.PlaceHolder;
import hpp.ui.VAlign;
import mmx.assets.Fonts;
import mmx.util.SavedDataUtil;
import mmx.util.SavedDataUtil.SettingsInfo;

/**
 * ...
 * @author Krisztian Somoracz
 */
class ReplayBlock extends FlxSpriteGroup
{
	var container:HPPHUIBox = new HPPHUIBox();

	public function new()
	{
		super();

		container = new HPPHUIBox(2, VAlign.TOP);

		createCheckbox("Show 3 stars replay", AppConfig.SHOW_3_STAR_REPLAY, update3StarsReplay);
		container.add(new PlaceHolder(30, 0));
		createCheckbox("Show player's best replay", AppConfig.SHOW_PLAYER_REPLAY, updatePlayersReplay);

		add(new PlaceHolder(573, 45, 0x44000000));
		add(container);

		container.x = width / 2 - container.width / 2;
		container.y = height / 2 - container.height / 2;
	}

	function createCheckbox(labelText:String, defaultState:Bool, onCheck:HPPToggleButton->Void):Void
	{
		var checkboxContainer:HPPHUIBox = new HPPHUIBox(10);

		var checkbox:HPPToggleButton = new HPPToggleButton("", "", onCheck, "small_checkbox_off", "small_checkbox_on");
		checkbox.isSelected = defaultState;
		checkboxContainer.add(checkbox);

		var checkboxLabel:FlxText = new FlxText(0, 0, 0, labelText, 18);
		checkboxLabel.color = FlxColor.WHITE;
		checkboxLabel.alignment = "left";
		checkboxLabel.font = Fonts.AACHEN;
		checkboxContainer.add(checkboxLabel);

		container.add(checkboxContainer);
	}

	function update3StarsReplay(target:HPPToggleButton)
	{
		AppConfig.SHOW_3_STAR_REPLAY = target.isSelected;

		var settingsInfo:SettingsInfo = SavedDataUtil.getSettingsInfo();
		settingsInfo.show3StarsReplay = AppConfig.SHOW_3_STAR_REPLAY;
		SavedDataUtil.save();
	}

	function updatePlayersReplay(target:HPPToggleButton)
	{
		AppConfig.SHOW_PLAYER_REPLAY = target.isSelected;

		var settingsInfo:SettingsInfo = SavedDataUtil.getSettingsInfo();
		settingsInfo.showPlayersReplay = AppConfig.SHOW_PLAYER_REPLAY;
		SavedDataUtil.save();
	}
}