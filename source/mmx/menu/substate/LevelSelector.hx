package mmx.menu.substate;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import hpp.flixel.ui.HPPButton;
import hpp.flixel.ui.HPPHUIBox;
import hpp.flixel.ui.HPPPager;
import hpp.flixel.ui.HPPTouchScrollContainer;
import hpp.flixel.ui.HPPUIGrid;
import mmx.common.view.LongButton;
import mmx.menu.view.LevelButton;
import mmx.menu.view.LevelSelectorPage;
import mmx.util.SavedDataUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LevelSelector extends FlxSubState
{
	public var worldId:UInt;

	var levelButtonsContainer:HPPTouchScrollContainer;
	var controlButtonContainer:FlxSpriteGroup;

	var backButton:HPPButton;

	var onBackRequest:HPPButton->Void;
	var pager:HPPPager;

	function new( onBackRequest:HPPButton->Void ):Void
	{
		this.onBackRequest = onBackRequest;

		super();
	}

	override public function create():Void
	{
		super.create();

		createLevelButtons();
		createControlButtons();
		createPager();
	}
	
	function createLevelButtons() 
	{
		add( levelButtonsContainer = new HPPTouchScrollContainer( FlxG.width, FlxG.height, new HPPTouchScrollContainerConfig( { snapToPages: true } ) ) );
		levelButtonsContainer.scrollFactor.set();
		
		var container:HPPHUIBox = new HPPHUIBox();
		container.add( new LevelSelectorPage( worldId, 0, 12 ) );
		container.add( new LevelSelectorPage( worldId, 12, 24 ) );
		
		levelButtonsContainer.add( container );
		
		if (SavedDataUtil.getLastPlayedLevel(worldId) > 11)
		{
			levelButtonsContainer.currentPage = 2;
		}
	}
	
	function createControlButtons()
	{
		add( controlButtonContainer = new FlxSpriteGroup() );
		controlButtonContainer.scrollFactor.set();

		controlButtonContainer.add( backButton = new LongButton( "BACK", onBackRequest ) );
		backButton.x = FlxG.width / 2 - backButton.width / 2;
		backButton.y = FlxG.height - 40 - backButton.height;
	}
	
	function createPager():Void 
	{
		add( pager = new HPPPager( levelButtonsContainer, "pager_page", "pager_selected", 10 ) );
		pager.x = FlxG.width / 2 - pager.width / 2;
		pager.y = backButton.y - 40;
	}
}