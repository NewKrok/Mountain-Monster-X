package mmx.menu.substate;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIList;
import flixel.group.FlxSpriteGroup;
import flixel.input.touch.FlxTouchManager;
import flixel.math.FlxPoint;
import hpp.flixel.ui.HPPButton;
import hpp.flixel.ui.HPPScrollContainer;
import hpp.flixel.util.HPPAssetManager;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LevelSelector extends FlxSubState
{
	private static inline var COL_PER_PAGE:UInt = 4;
	private static inline var ROW_PER_PAGE:UInt = 3;
	
	private static var LEVEL_BUTTON_SIZE:FlxPoint = new FlxPoint( 144, 124 );
	private static var LEVEL_BUTTON_OFFSET:FlxPoint = new FlxPoint( 30, 30 );
	private static inline var PAGER_BASE_Y_OFFSET:Float = -50;
		
	public var worldId:UInt;

	var levelButtonsContainer:HPPScrollContainer;
	var controlButtonContainer:FlxSpriteGroup;

	var backButton:HPPButton;

	var onBackRequest:Void->Void;
	var levelButtons:Array<LevelButton>;
	var pages:Array<FlxSpriteGroup>;
	var pagerStart:FlxSprite;
	var pagerEnd:FlxSprite;

	function new( onBackRequest:Void->Void ):Void
	{
		this.onBackRequest = onBackRequest;

		super();
	}

	override public function create():Void
	{
		super.create();

		createLevelButtons();
		createControlButtons();
	}
	
	function createLevelButtons() 
	{
		add( levelButtonsContainer = new HPPScrollContainer( FlxG.width, FlxG.height, ScrollDirection.HORIZONTAL, true ) );
		levelButtonsContainer.scrollFactor.set();
		
		pages = [];
		addPage();
		
		levelButtons = [];
		var col:UInt = 0;
		var row:UInt = 0;
		var pageIndex:UInt = 0;
		
		var pageContainer:FlxSpriteGroup = new FlxSpriteGroup();
		pages[pageIndex].add( pageContainer );
		
		for( i in 0...24 )
		{
			levelButtons.push( new LevelButton( worldId, i ) );
			levelButtons[ i ].x = col * LEVEL_BUTTON_SIZE.x + LEVEL_BUTTON_OFFSET.x * col;
			levelButtons[ i ].y = row * LEVEL_BUTTON_SIZE.y + LEVEL_BUTTON_OFFSET.y * row;
			pageContainer.add( levelButtons[ i ] );

			col++;
			if( col == COL_PER_PAGE )
			{
				col = 0;
				row++;
			}
			if( row == ROW_PER_PAGE )
			{
				row = 0;
				addPage();
				
				pageContainer.x = pageIndex * FlxG.width + FlxG.width / 2 - pageContainer.width / 2;
				pageContainer.y = PAGER_BASE_Y_OFFSET + FlxG.height / 2 - pageContainer.height / 2;
				
				pageIndex++;
				pageContainer = new FlxSpriteGroup();
				pages[pageIndex].add( pageContainer );
			}
		}
		
		levelButtonsContainer.add( pagerStart = new FlxSprite() );
		pagerStart.loadGraphic( new BitmapData( 10, 10, true, 0x0 ) );
		levelButtonsContainer.add( pagerEnd = new FlxSprite() );
		pagerEnd.loadGraphic( new BitmapData( 10, 10, true, 0x0 ) );
		pagerEnd.x = pageIndex * FlxG.width - pagerEnd.width;
	}
	
	function addPage():Void
	{
		var page = new FlxSpriteGroup();
		page.scrollFactor.set();
		pages.push( page );
		levelButtonsContainer.add( page );
	}

	function createControlButtons()
	{
		add( controlButtonContainer = new FlxSpriteGroup() );
		controlButtonContainer.scrollFactor.set();

		controlButtonContainer.add( backButton = new HPPButton( "Back", onBackRequest ) );
		backButton.loadGraphic( HPPAssetManager.getGraphic( "base_button" ) );
		backButton.autoCenterLabel();
		backButton.overScale = .95;
		backButton.x = FlxG.width / 2 - backButton.width / 2;
		backButton.y = FlxG.height - 40 - backButton.height;
	}
}