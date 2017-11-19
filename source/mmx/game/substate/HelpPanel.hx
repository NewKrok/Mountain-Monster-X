package mmx.game.substate;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import hpp.flixel.ui.HPPButton;
import hpp.flixel.ui.HPPHUIBox;
import hpp.flixel.ui.HPPVUIBox;
import hpp.flixel.ui.PlaceHolder;
import hpp.flixel.util.HPPAssetManager;
import mmx.assets.Fonts;
import mmx.common.view.LongButton;
import mmx.util.SavedDataUtil;

/**
 * ...
 * @author Krisztian Somoracz
 */
class HelpPanel extends FlxSubState
{
	// TODO: move to config file or at least add some language handler class
	var HELP_TEXTS:Array<Array<HelpDescription>> = [
		[
			{
				desktop: "Use 'Up' and 'Down' arrows to accelerate or to brake.".toUpperCase(),
				mobile: "Touch right arrows to accelerate or to brake.".toUpperCase()
			},
			{
				desktop: "Use 'Left' and 'Right' arrows to lean back or to lean front with the car.".toUpperCase(),
				mobile: "Touch left arrows to lean back or to lean front with the car.".toUpperCase()
			},
			{ desktop: "Collect Coins to earn more score.".toUpperCase() },
			{ desktop: "Do back flip, front flip, wheelie or nice air time to earn more score.".toUpperCase() },
			{ desktop: "Good luck, have a nice ride!".toUpperCase() },
		],
		[
			{ desktop: 'It is hard to drive on places covered with snow.'.toUpperCase()},
			{ desktop: 'Be careful in the blizzard!'.toUpperCase()},
		],
		[
			{ desktop: 'Watch out for the crates, they can be moved easily.'.toUpperCase()}
		],
		[
			{ desktop: 'description...'.toUpperCase()}
		]
	];
	
	var nextButton:LongButton;
	var prevButton:LongButton;
	
	var baseBack:FlxSprite;
	var container:FlxSpriteGroup;
	var content:HPPVUIBox;
	var helpIconContainer:FlxSpriteGroup;
	var helpDescription:FlxText;
	var helpDataContainer:HPPHUIBox;
	
	var startGameRequest:HPPButton->Void;
	
	var worldId:Int;
	var helpIndex:Int = 0;
	
	function new( worldId:Int, startGameRequest:HPPButton->Void )
	{
		super();
		
		this.worldId = worldId;
		
		this.startGameRequest = startGameRequest;
	}

	override public function create():Void
	{
		super.create();

		build();
	}

	function build()
	{
		add(container = new FlxSpriteGroup());
		container.scrollFactor.set();
		
		container.add(baseBack = new FlxSprite());
		baseBack.makeGraphic(FlxG.stage.stageWidth, FlxG.stage.stageHeight, FlxColor.BLACK);
		baseBack.alpha = .5;
		
		var baseBack:FlxSprite = HPPAssetManager.getSprite("help_back");
		container.add(baseBack);
		baseBack.x = container.width / 2 - baseBack.width / 2;
		baseBack.y = container.height / 2 - baseBack.height / 2 - 48;
		
		container.add(content = new HPPVUIBox(40));
		
		helpDataContainer = new HPPHUIBox();
		helpIconContainer = new FlxSpriteGroup();
		helpIconContainer.add(new PlaceHolder(214, 206));
		helpDataContainer.add(helpIconContainer);
		
		helpDataContainer.add(new PlaceHolder(35, 10));
		
		helpDescription = new FlxText(0, 0, 446, "", 30);
		helpDescription.font = Fonts.AACHEN_MEDIUM;
		helpDescription.color = FlxColor.WHITE;
		helpDescription.width = 446;
		helpDescription.alignment = "center";
		helpDescription.wordWrap = true;
		helpDataContainer.add(helpDescription);
		
		helpDataContainer.add(new PlaceHolder(19, 10));
		
		content.add(helpDataContainer);
		
		var buttonContainer:HPPHUIBox = new HPPHUIBox(20);
		
		buttonContainer.add( prevButton = new LongButton(AppConfig.IS_DESKTOP_DEVICE ? "(B)ACK" : "BACK", onPrevRequest));
		prevButton.overScale = .98;
		
		buttonContainer.add( nextButton = new LongButton(AppConfig.IS_DESKTOP_DEVICE ? "(N)EXT" : "NEXT", onNextRequest));
		nextButton.overScale = .98;
		
		content.add(buttonContainer);
		content.x = FlxG.width / 2 - content.width / 2;
		content.y = FlxG.height / 2 - content.height / 2;
		
		updateView();
	}
	
	function updateView():Void 
	{
		updateHelpIcon();
		updateHelpText();
		updateButtons();
	}
	
	function updateHelpIcon()
	{
		helpIconContainer.remove(helpIconContainer.getFirstExisting());
		
		helpIconContainer.add(HPPAssetManager.getSprite("help_icon_" + worldId + "_" + helpIndex));
	}
	
	function updateHelpText()
	{
		helpDescription.text = ( AppConfig.IS_MOBILE_DEVICE && HELP_TEXTS[worldId][helpIndex].mobile != null ) ? HELP_TEXTS[worldId][helpIndex].mobile : HELP_TEXTS[worldId][helpIndex].desktop;
		
		helpDataContainer.rePosition();
	}
	
	function updateButtons() 
	{
		prevButton.alpha = helpIndex == 0 ? .5 : 1;

		if (helpIndex == HELP_TEXTS[worldId].length - 1)
		{
			nextButton.label.text = AppConfig.IS_DESKTOP_DEVICE ? "(C)LOSE" : "CLOSE";
		}
		else
		{
			nextButton.label.text = AppConfig.IS_DESKTOP_DEVICE ? "(N)EXT" : "NEXT";
		}
	}
	
	function onNextRequest(target:HPPButton = null) 
	{
		helpIndex++;
		
		if (helpIndex == HELP_TEXTS[worldId].length)
		{
			SavedDataUtil.setHelpInfo(worldId, true);
			SavedDataUtil.save();
			
			startGameRequest(target);
		}
		else
		{
			updateView();
		}
	}
	
	function onPrevRequest(target:HPPButton = null) 
	{
		if (helpIndex == 0) return;
		
		helpIndex--;
		updateView();
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (AppConfig.IS_DESKTOP_DEVICE)
		{
			if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.RIGHT || (FlxG.keys.justPressed.N && helpIndex < HELP_TEXTS[worldId].length - 1) || (FlxG.keys.justPressed.C && helpIndex == HELP_TEXTS[worldId].length - 1 ))
			{
				onNextRequest(null);
			}
			
			if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.B)
			{
				onPrevRequest(null);
			}
		}
	}
}

typedef HelpDescription =
{
	var desktop:String;
	
	@:optional var mobile:String;
}