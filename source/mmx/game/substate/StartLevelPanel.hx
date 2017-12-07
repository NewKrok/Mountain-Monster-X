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
import hpp.ui.HAlign;
import hpp.util.NumberUtil;
import hpp.util.TimeUtil;
import mmx.assets.Fonts;
import mmx.common.view.LongButton;
import mmx.game.view.StarRequirementView;
import mmx.util.SavedDataUtil.LevelInfo;

/**
 * ...
 * @author Krisztian Somoracz
 */ 
class StartLevelPanel extends FlxSubState
{
	var content:HPPVUIBox;
	
	var startButton:HPPButton;
	var exitButton:HPPButton;
	var nextButton:HPPButton;
	var prevButton:HPPButton;
	
	var startRequest:HPPButton->Void;
	var exitRequest:HPPButton->Void;
	var nextLevelRequest:HPPButton->Void;
	var prevLevelRequest:HPPButton->Void;
	
	var baseBack:FlxSprite;
	var container:FlxSpriteGroup;
	var starRequirements:Array<UInt>;
	var levelInfo:LevelInfo;
	
	function new(levelInfo:LevelInfo, starRequirements:Array<UInt>, startRequest:HPPButton->Void, exitRequest:HPPButton->Void, nextLevelRequest:HPPButton->Void, prevLevelRequest:HPPButton->Void):Void
	{
		super();
		
		this.levelInfo = levelInfo;
		this.starRequirements = starRequirements;
		this.startRequest = startRequest;
		this.exitRequest = exitRequest;
		this.nextLevelRequest = nextLevelRequest;
		this.prevLevelRequest = prevLevelRequest;
	}

	override public function create():Void
	{
		super.create();

		build();
	}

	function build():Void
	{
		add(container = new FlxSpriteGroup());
		container.scrollFactor.set();
		
		container.add(baseBack = new FlxSprite());
		baseBack.makeGraphic(FlxG.stage.stageWidth, FlxG.stage.stageHeight, FlxColor.BLACK);
		baseBack.alpha = .5;
		
		var baseBack:FlxSprite = HPPAssetManager.getSprite("panel_background");
		container.add(baseBack);
		baseBack.x = container.width / 2 - baseBack.width / 2;
		baseBack.y = container.height / 2 - baseBack.height / 2 - 40 - (canStartPrevLevel() || canStartNextLevel() ? 47 : 0);
		
		content = new HPPVUIBox();
		container.add(content);
		
		content.add(new PlaceHolder(0,36));
		createTitle();
		content.add(new PlaceHolder(0,10));
		createStarRequirementView();
		content.add(new PlaceHolder(0,20));
		createFooter();
		content.add(new PlaceHolder(0,50));
		createButtons();
		
		content.x = container.width / 2 - content.width / 2;
		content.y = container.height / 2 - content.height / 2 - 5;
	}
	
	function createTitle():Void 
	{
		var levelText:FlxText = new FlxText(0, 0, cast baseBack.width, "Level " + (levelInfo.levelId + 1), 35);
		levelText.autoSize = false;
		levelText.color = FlxColor.WHITE;
		levelText.alignment = "center";
		levelText.font = Fonts.AACHEN_MEDIUM;
		levelText.y = 12;
		content.add(levelText);
		
		var worldText:FlxText = new FlxText(0, 0, cast baseBack.width, "Level pack " + (levelInfo.worldId + 1), 20);
		worldText.autoSize = false;
		worldText.color = FlxColor.WHITE;
		worldText.alignment = "center";
		worldText.font = Fonts.AACHEN_MEDIUM;
		worldText.y = 12;
		content.add(worldText);
	}
	
	function createStarRequirementView():Void 
	{
		var starInfoContainer:HPPVUIBox = new HPPVUIBox(10, HAlign.LEFT);
		
		for (i in 0...3) starInfoContainer.add(new StarRequirementView(3 - i, starRequirements[2 - i]));
		
		content.add(starInfoContainer);
	}
	
	function createFooter():Void 
	{
		var footer:HPPHUIBox = new HPPHUIBox();
		
		var bestScoreLabelText:FlxText = new FlxText(0, 0, 0, "Best score ", 25);
		bestScoreLabelText.autoSize = true;
		bestScoreLabelText.color = FlxColor.WHITE;
		bestScoreLabelText.alignment = "left";
		bestScoreLabelText.font = Fonts.AACHEN_MEDIUM;
		footer.add(bestScoreLabelText);
		
		var bestScoreText:FlxText = new FlxText(0, 0, 0, levelInfo.isCompleted ? NumberUtil.formatNumber(levelInfo.score) : "N/A", 25);
		bestScoreText.autoSize = true;
		bestScoreText.color = FlxColor.YELLOW;
		bestScoreText.alignment = "left";
		bestScoreText.font = Fonts.AACHEN_MEDIUM;
		footer.add(bestScoreText);
		
		footer.add(new PlaceHolder(100,0));
		
		var bestTimeLabelText:FlxText = new FlxText(0, 0, 0, "Best time ", 25);
		bestTimeLabelText.autoSize = true;
		bestTimeLabelText.color = FlxColor.WHITE;
		bestTimeLabelText.alignment = "left";
		bestTimeLabelText.font = Fonts.AACHEN_MEDIUM;
		footer.add(bestTimeLabelText);
		
		var bestTimeText:FlxText = new FlxText(0, 0, 0, levelInfo.isCompleted ? TimeUtil.timeStampToFormattedTime(levelInfo.time, TimeUtil.TIME_FORMAT_MM_SS_MS) : "N/A", 25);
		bestTimeText.autoSize = true;
		bestTimeText.color = FlxColor.YELLOW;
		bestTimeText.alignment = "left";
		bestTimeText.font = Fonts.AACHEN_MEDIUM;
		footer.add(bestTimeText);
		
		content.add(footer);
	}
	
	function createButtons():Void 
	{
		var buttonContainer:HPPHUIBox = new HPPHUIBox(30);
		
		buttonContainer.add(exitButton = new LongButton(AppConfig.IS_DESKTOP_DEVICE ? "E(X)IT" : "EXIT", exitRequest));
		buttonContainer.add(startButton = new LongButton(AppConfig.IS_DESKTOP_DEVICE ? "(S)TART GAME" : "START GAME", startRequest));
		
		content.add(buttonContainer);
		
		var subButtonContainer:HPPHUIBox = new HPPHUIBox(30);
		var _canStartPrevLevel:Bool = canStartPrevLevel();
		var _canStartNextLevel:Bool = canStartNextLevel();
		
		if (_canStartPrevLevel || _canStartNextLevel)
		{
			content.add(new PlaceHolder(0, 20));
		}
		if (_canStartPrevLevel)
		{
			subButtonContainer.add(prevButton = new LongButton(AppConfig.IS_DESKTOP_DEVICE ? "(P)REVIOUS LEVEL" : "PREVIOUS LEVEL", prevLevelRequest));
		}
		if (_canStartNextLevel)
		{
			subButtonContainer.add(nextButton = new LongButton(AppConfig.IS_DESKTOP_DEVICE ? "(N)EXT LEVEL" : "NEXT LEVEL", nextLevelRequest));
		}
		content.add(subButtonContainer);
	}
	
	function canStartPrevLevel():Bool
	{
		return levelInfo.levelId != 0;
	}
	
	function canStartNextLevel():Bool
	{
		// TODO remove this hack after the whole world playable
		if (levelInfo.worldId == 0)
		{
			return levelInfo.isCompleted && levelInfo.levelId != 23;
		}
		else
		{
			return levelInfo.isCompleted && levelInfo.levelId != 11;
		}
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (AppConfig.IS_DESKTOP_DEVICE)
		{
			if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.S)
			{
				startRequest(null);
			}
			
			if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.X)
			{
				exitRequest(null);
			}
			
			if (FlxG.keys.justPressed.P && canStartPrevLevel())
			{
				prevLevelRequest(null);
			}
			
			if (FlxG.keys.justPressed.N && canStartNextLevel())
			{
				nextLevelRequest(null);
			}
		}
	}
}