package mmx.menu.substate;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import hpp.flixel.ui.HPPButton;
import hpp.flixel.ui.HPPTouchScrollContainer;
import hpp.flixel.ui.HPPVUIBox;
import mmx.assets.Fonts;
import mmx.common.view.LongButton;

/**
 * ...
 * @author Krisztian Somoracz
 */
class NewsPage extends FlxSubState
{
	var openWelcomePage:HPPButton->Void;
	
	var backButton:HPPButton;
	
	function new(openWelcomePage:HPPButton->Void):Void
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
		baseBack.makeGraphic(FlxG.width, FlxG.height, 0xAA000000);
		baseBack.scrollFactor.set();
		add(baseBack);
		
		var container:HPPVUIBox = new HPPVUIBox(20);
		container.scrollFactor.set();
		
		container.add( createTitle() );
		
		// TODO later add the entries to the scroll container
		/*var scrollContainerConfig:HPPTouchScrollContainerConfig = new HPPTouchScrollContainerConfig();
		scrollContainerConfig.snapToPages = false;
		scrollContainerConfig.direction = HPPScrollDirection.VERTICAL;
		var scrollContainer:HPPTouchScrollContainer = new HPPTouchScrollContainer(FlxG.width, 400, scrollContainerConfig);*/
		
		container.add(createEntry("- 0.1 -", "This is the First version with version number. The game currently is under development."));
		
		//container.add(scrollContainer);
		
		container.x = FlxG.width / 2 - container.width / 2;
		container.y = 40;
		add( container );
		
		add( backButton = new LongButton( "BACK", openWelcomePage ) );
		backButton.x = FlxG.width / 2 - backButton.width / 2;
		backButton.y = FlxG.height - 40 - backButton.height;
	}
	
	function createTitle():FlxText
	{
		var text = new FlxText();
		
		text.color = FlxColor.CYAN;
		text.alignment = "center";
		text.size = 40;
		text.font = Fonts.AACHEN_LIGHT;
		text.borderStyle = FlxTextBorderStyle.SHADOW;
		text.fieldWidth = 800;
		text.text = "LATEST NEWS";
		
		return text;
	}
	
	function createEntry(version:String, description:String):FlxSpriteGroup
	{
		var entryContainer:HPPVUIBox = new HPPVUIBox(5);
		
		var versionText = new FlxText();
		versionText.color = FlxColor.WHITE;
		versionText.alignment = "center";
		versionText.size = 30;
		versionText.font = Fonts.AACHEN_LIGHT;
		versionText.borderStyle = FlxTextBorderStyle.OUTLINE;
		versionText.text = version;
		entryContainer.add(versionText);
		
		var descText = new FlxText();
		descText.color = FlxColor.WHITE;
		descText.alignment = "center";
		descText.size = 25;
		descText.font = Fonts.AACHEN_LIGHT;
		descText.text = description;
		entryContainer.add(descText);
		
		return entryContainer;
	}
}