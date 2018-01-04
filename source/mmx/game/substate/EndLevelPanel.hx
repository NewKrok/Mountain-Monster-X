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
import hpp.util.NumberUtil;
import hpp.util.TimeUtil;
import mmx.assets.Fonts;
import mmx.common.view.LongButton;
import mmx.datatype.LevelData;
import mmx.game.view.CollectedCoinsInfoBlock;
import mmx.game.view.LevelInfoFooter;
import mmx.game.view.LevelStatisticBlock;
import mmx.util.LevelUtil;
import mmx.util.SavedDataUtil.LevelInfo;

/**
 * ...
 * @author Krisztian Somoracz
 */
class EndLevelPanel extends FlxSubState
{
	var content:HPPVUIBox;
	var panelBack:FlxSprite;
	var levelStatisticBlock:LevelStatisticBlock;
	var collectedCoinsInfoBlock:CollectedCoinsInfoBlock;
	var levelInfoFooter:LevelInfoFooter;

	var startButton:HPPButton;
	var exitButton:HPPButton;
	var nextButton:HPPButton;
	var prevButton:HPPButton;

	var restartRequest:HPPButton->Void;
	var exitRequest:HPPButton->Void;
	var nextLevelRequest:HPPButton->Void;
	var prevLevelRequest:HPPButton->Void;

	var scoreText:FlxText;
	var earnedStarView:FlxSprite;
	var earnedStarContainer:FlxSpriteGroup;
	var newHighScoreText:FlxText;
	var highscoreText:FlxText;

	var baseBack:FlxSprite;
	var container:FlxSpriteGroup;
	var levelInfo:LevelInfo;
	var levelData:LevelData;

	var isBuilt:Bool;
	var currentScore:UInt;
	var currentTime:Float;
	var currentCollectedCoins:UInt;
	var currentEarnedStarView:UInt;

	function new(levelInfo:LevelInfo, levelData:LevelData, restartRequest:HPPButton->Void, exitRequest:HPPButton->Void, nextLevelRequest:HPPButton->Void, prevLevelRequest:HPPButton->Void):Void
	{
		super();

		this.levelInfo = levelInfo;
		this.levelData = levelData;
		this.restartRequest = restartRequest;
		this.exitRequest = exitRequest;
		this.nextLevelRequest = nextLevelRequest;
		this.prevLevelRequest = prevLevelRequest;
	}

	override public function create():Void
	{
		super.create();

		build();
		isBuilt = true;
	}

	function build()
	{
		add(container = new FlxSpriteGroup());
		container.scrollFactor.set();

		container.add(baseBack = new FlxSprite());
		baseBack.makeGraphic(FlxG.stage.stageWidth, FlxG.stage.stageHeight, FlxColor.BLACK);
		baseBack.alpha = .5;

		panelBack = HPPAssetManager.getSprite("panel_background");
		container.add(panelBack);
		panelBack.x = container.width / 2 - panelBack.width / 2;
		panelBack.y = container.height / 2 - panelBack.height / 2 - 40 - ( canStartPrevLevel() || canStartNextLevel() ? 50 : 0 );

		content = new HPPVUIBox();
		container.add(content);
		content.add(new PlaceHolder(0, 36));
		createTitle();
		content.add(new PlaceHolder(0, 5));
		content.add(levelStatisticBlock = new LevelStatisticBlock(currentCollectedCoins, levelData.starPoints.length, currentTime));
		content.add(new PlaceHolder(0, 5));
		content.add(collectedCoinsInfoBlock = new CollectedCoinsInfoBlock(currentCollectedCoins, levelData.starPoints.length));
		createEarnedStarView();
		createScoreView();
		content.add(new PlaceHolder(0, 30));
		content.add(levelInfoFooter = new LevelInfoFooter(levelInfo.isCompleted, levelInfo.score, levelInfo.time));
		content.add(new PlaceHolder(0, 50));
		createButtons();

		content.x = container.width / 2 - content.width / 2;
		content.y = container.height / 2 - content.height / 2 - 5;

		highscoreText.visible = currentScore >= levelInfo.score;
	}

	function createTitle()
	{
		var subContainer:FlxSpriteGroup = new FlxSpriteGroup();
		subContainer.add(new PlaceHolder(1,1));

		var levelText:FlxText = new FlxText(0, 0, 0, "LEVEL " + (levelInfo.levelId + 1), 35);
		levelText.autoSize = true;
		levelText.color = FlxColor.WHITE;
		levelText.alignment = "left";
		levelText.font = Fonts.AACHEN;
		subContainer.add(levelText);

		var worldText:FlxText = new FlxText(0, 0, 0, LevelUtil.getWorldNameByWorldId(levelInfo.worldId).toUpperCase(), 20);
		worldText.autoSize = true;
		worldText.color = 0xFFCCCCCC;
		worldText.alignment = "left";
		worldText.font = Fonts.AACHEN;
		worldText.x = panelBack.width - worldText.fieldWidth - 60;
		subContainer.add(worldText);

		var completedText:FlxText = new FlxText(0, 0, 0, "COMPLETED", 28);
		completedText.autoSize = true;
		completedText.color = FlxColor.YELLOW;
		completedText.alignment = "left";
		completedText.font = Fonts.AACHEN;
		completedText.y = 30;
		subContainer.add(completedText);

		highscoreText = new FlxText(0, 0, 0, "NEW HIGHSCORE!", 28);
		highscoreText.autoSize = true;
		highscoreText.color = FlxColor.YELLOW;
		highscoreText.alignment = "left";
		highscoreText.font = Fonts.AACHEN;
		highscoreText.x = panelBack.width - highscoreText.fieldWidth - 60;
		highscoreText.y = completedText.y;
		subContainer.add(highscoreText);

		content.add(subContainer);
	}

	function createEarnedStarView()
	{
		earnedStarContainer = new FlxSpriteGroup();
		earnedStarContainer.add(earnedStarView = HPPAssetManager.getSprite("large_star_" + currentEarnedStarView));

		content.add(earnedStarContainer);
	}

	function createScoreView()
	{
		var row:HPPHUIBox = new HPPHUIBox(10);

		scoreText = new FlxText(0, 0, 0, "SCORE: " + NumberUtil.formatNumber(currentScore), 35);
		scoreText.autoSize = true;
		scoreText.color = FlxColor.YELLOW;
		scoreText.alignment = "center";
		scoreText.font = Fonts.AACHEN;

		row.add(scoreText);
		content.add(row);
	}

	function createButtons()
	{
		var buttonContainer:HPPHUIBox = new HPPHUIBox(30);

		buttonContainer.add(exitButton = new LongButton(AppConfig.IS_DESKTOP_DEVICE ? "E(X)IT" : "EXIT", exitRequest));
		buttonContainer.add(startButton = new LongButton(AppConfig.IS_DESKTOP_DEVICE ? "(R)ESTART GAME" : "RESTART GAME", restartRequest));

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

	public function updateView(currentScore:UInt, currentTime:Float, currentCollectedCoins:UInt, currentEarnedStarView:UInt):Void
	{
		this.currentTime = currentTime;
		this.currentScore = currentScore;
		this.currentCollectedCoins = currentCollectedCoins;
		this.currentEarnedStarView = currentEarnedStarView;

		if (!isBuilt) return;

		highscoreText.visible = currentScore >= levelInfo.score;

		scoreText.text = "SCORE: " + NumberUtil.formatNumber(currentScore);

		earnedStarContainer.remove( earnedStarView );
		earnedStarView.destroy();
		earnedStarContainer.add(earnedStarView = HPPAssetManager.getSprite("large_star_" + currentEarnedStarView));

		levelStatisticBlock.updateData(currentCollectedCoins, levelData.starPoints.length, currentTime);
		collectedCoinsInfoBlock.updateData(currentCollectedCoins, levelData.starPoints.length);
		levelInfoFooter.updateData(levelInfo.isCompleted, levelInfo.score, levelInfo.time);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (AppConfig.IS_DESKTOP_DEVICE)
		{
			if (FlxG.keys.justPressed.R)
			{
				restartRequest(null);
			}

			if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.X)
			{
				exitRequest(null);
			}

			if (FlxG.keys.justPressed.P && canStartPrevLevel())
			{
				prevLevelRequest(null);
			}

			if ((FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.N) && canStartNextLevel())
			{
				nextLevelRequest(null);
			}
		}
	}
}