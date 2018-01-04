package mmx.menu.substate;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import hpp.flixel.ui.HPPButton;
import hpp.flixel.ui.HPPHUIBox;
import hpp.flixel.ui.HPPToggleButton;
import hpp.flixel.ui.HPPVUIBox;
import hpp.ui.HAlign;
import hpp.util.JsFullScreenUtil;
import mmx.AppConfig;
import mmx.assets.Fonts;
import mmx.common.view.LongButton;
import mmx.util.SavedDataUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */
class SettingsPage extends FlxSubState
{
	var openWelcomePage:HPPButton->Void;

	var showFPSCheckbox:HPPToggleButton;
	var fpsText:FlxText;

	var alphaAnimationCheckBox:HPPToggleButton;
	var alphaAnimationsText:FlxText;

	var fullScreenCheckBox:HPPToggleButton;
	var fullScreenText:FlxText;

	var backButton:HPPButton;

	function new( openWelcomePage:HPPButton->Void ):Void
	{
		super();

		this.openWelcomePage = openWelcomePage;
	}

	override public function create():Void
	{
		super.create();

		build();
	}

	function build():Void
	{
		var baseBack:FlxSprite = new FlxSprite();
		baseBack.makeGraphic( FlxG.width, FlxG.height, 0xAA000000 );
		baseBack.scrollFactor.set();
		add( baseBack );

		var container:HPPVUIBox = new HPPVUIBox( 20, HAlign.LEFT );
		container.scrollFactor.set();

		if (AppConfig.IS_DESKTOP_DEVICE) container.add(createFullscreenSetting());
		container.add( createFpsSetting() );
		container.add( createAlphaAnimationSetting() );

		container.x = FlxG.width / 2 - container.width / 2;
		container.y = FlxG.height / 2 - container.height / 2;
		add( container );

		add( backButton = new LongButton( "BACK", saveAndClose ) );
		backButton.x = FlxG.width / 2 - backButton.width / 2;
		backButton.y = FlxG.height - 40 - backButton.height;
	}

	function saveAndClose(target:HPPButton)
	{
		var settingsInfo:SettingsInfo = SavedDataUtil.getSettingsInfo();
		settingsInfo.enableAlphaAnimation = AppConfig.IS_ALPHA_ANIMATION_ENABLED;
		settingsInfo.showFPS = AppConfig.SHOW_FPS;
		SavedDataUtil.save();

		openWelcomePage(target);
	}

	function createFullscreenSetting():FlxSpriteGroup
	{
		var settingContainer:HPPHUIBox = new HPPHUIBox(20);

		fullScreenCheckBox = new HPPToggleButton("", "", setFullscreen, "checkbox_off", "checkbox_on");
		fullScreenCheckBox.isSelected = JsFullScreenUtil.isFullScreen();
		settingContainer.add( fullScreenCheckBox );

		fullScreenText = new FlxText();
		fullScreenText.color = FlxColor.WHITE;
		fullScreenText.alignment = "left";
		fullScreenText.size = 35;
		fullScreenText.font = Fonts.AACHEN;
		fullScreenText.borderStyle = FlxTextBorderStyle.SHADOW;
		fullScreenText.fieldWidth = 650;

		updateFullScreenText();
		settingContainer.add(fullScreenText);

		#if js
			untyped __js__('window.addEventListener("resize", ()=>this.updateFullScreenState())');
		#end

		return cast settingContainer;
	}

	function setFullscreen(target:HPPToggleButton):Void
	{
		updateFullScreenText();

		if (JsFullScreenUtil.isFullScreen())
		{
			JsFullScreenUtil.cancelFullScreen();
		}
		else
		{
			JsFullScreenUtil.requestFullScreen();
		}
	}

	function updateFullScreenState()
	{
		fullScreenCheckBox.isSelected = JsFullScreenUtil.isFullScreen();
		updateFullScreenText();
	}

	function updateFullScreenText():Void
	{
		fullScreenText.text = "Change to full screen mode (" + ( fullScreenCheckBox.isSelected ? "TURNED ON" : "TURNED OFF" ) + ") Note: On some site this feature is not available";
	}

	function setFPS( target:HPPToggleButton ):Void
	{
		updateFpsText();

		AppConfig.SHOW_FPS = showFPSCheckbox.isSelected;
	}

	function updateFpsText():Void
	{
		fpsText.text = "Show FPS during the game (" + ( showFPSCheckbox.isSelected ? "TURNED ON" : "TURNED OFF" ) + ")";
	}

	function createFpsSetting():FlxSpriteGroup
	{
		var settingContainer:HPPHUIBox = new HPPHUIBox( 20 );

		showFPSCheckbox = new HPPToggleButton( "", "", setFPS, "checkbox_off", "checkbox_on" );
		showFPSCheckbox.isSelected = AppConfig.SHOW_FPS;
		settingContainer.add( showFPSCheckbox );

		fpsText = new FlxText();
		fpsText.color = FlxColor.WHITE;
		fpsText.alignment = "left";
		fpsText.size = 35;
		fpsText.font = Fonts.AACHEN;
		fpsText.borderStyle = FlxTextBorderStyle.SHADOW;
		fpsText.fieldWidth = 650;
		updateFpsText();
		settingContainer.add( fpsText );

		return cast settingContainer;
	}

	function createAlphaAnimationSetting():FlxSpriteGroup
	{
		var settingContainer:HPPHUIBox = new HPPHUIBox( 20 );

		alphaAnimationCheckBox = new HPPToggleButton( "", "", setAlphaAnimation, "checkbox_off", "checkbox_on" );
		alphaAnimationCheckBox.isSelected = AppConfig.IS_ALPHA_ANIMATION_ENABLED;
		settingContainer.add( alphaAnimationCheckBox );

		alphaAnimationsText = new FlxText();
		alphaAnimationsText.color = FlxColor.WHITE;
		alphaAnimationsText.alignment = "left";
		alphaAnimationsText.size = 35;
		alphaAnimationsText.font = Fonts.AACHEN;
		alphaAnimationsText.borderStyle = FlxTextBorderStyle.SHADOW;
		alphaAnimationsText.fieldWidth = 650;
		updateAlphaAnimationText();
		settingContainer.add( alphaAnimationsText );

		return cast settingContainer;
	}

	function setAlphaAnimation( target:HPPToggleButton ):Void
	{
		updateAlphaAnimationText();

		AppConfig.IS_ALPHA_ANIMATION_ENABLED = alphaAnimationCheckBox.isSelected;
	}

	function updateAlphaAnimationText():Void
	{
		alphaAnimationsText.text = "Enable alpha animations - Not recommended in mobile or with slow PC (" + ( alphaAnimationCheckBox.isSelected ? "TURNED ON" : "TURNED OFF" ) + ")";
	}
}