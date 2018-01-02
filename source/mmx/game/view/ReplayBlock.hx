package mmx.game.view;

import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import hpp.flixel.ui.HPPHUIBox;
import hpp.flixel.ui.HPPToggleButton;
import hpp.flixel.ui.PlaceHolder;
import hpp.ui.VAlign;
import mmx.assets.Fonts;

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

		createCheckbox("Show 3 stars replay", function(_){});
		container.add(new PlaceHolder(30, 0));
		createCheckbox("Show player's best replay", function(_){});

		add(new PlaceHolder(573, 45, 0x44000000));
		add(container);

		container.x = width / 2 - container.width / 2;
		container.y = height / 2 - container.height / 2;
	}

	function createCheckbox(labelText:String, onCheck:HPPToggleButton->Void):Void
	{
		var checkboxContainer:HPPHUIBox = new HPPHUIBox(10);

		var checkbox:HPPToggleButton = new HPPToggleButton("", "", onCheck, "small_checkbox_off", "small_checkbox_on");
		checkbox.isSelected = AppConfig.SHOW_FPS;
		checkboxContainer.add(checkbox);

		var checkboxLabel:FlxText = new FlxText(0, 0, 0, labelText, 18);
		checkboxLabel.color = FlxColor.WHITE;
		checkboxLabel.alignment = "left";
		checkboxLabel.font = Fonts.AACHEN_MEDIUM;
		checkboxContainer.add(checkboxLabel);

		container.add(checkboxContainer);
	}
}