package mmx.state;

import apostx.replaykit.Playback;
import apostx.replaykit.Recorder;
import flixel.FlxCamera;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Timer;
import hpp.flixel.HPPCamera;
import hpp.flixel.ui.HPPButton;
import hpp.flixel.util.HPPAssetManager;
import mmx.assets.CarDatas;
import mmx.common.PlayerInfo;
import mmx.datatype.LevelData;
import mmx.game.Background;
import mmx.game.Car;
import mmx.game.Coin;
import mmx.game.GameGui;
import mmx.game.GhostCar;
import mmx.game.SmallRock;
import mmx.game.constant.CGameTimeValue;
import mmx.game.constant.CLibraryElement;
import mmx.game.constant.CPhysicsValue;
import mmx.game.constant.CScore;
import mmx.game.library.crate.AbstractCrate;
import mmx.game.library.crate.Crate;
import mmx.game.library.crate.LongCrate;
import mmx.game.library.crate.RampCrate;
import mmx.game.library.crate.SmallCrate;
import mmx.game.library.crate.SmallLongCrate;
import mmx.game.library.crate.SmallRampCrate;
import mmx.game.snow.Snow;
import mmx.game.substate.EndLevelPanel;
import mmx.game.substate.HelpPanel;
import mmx.game.substate.PausePanel;
import mmx.game.substate.StartLevelPanel;
import mmx.game.terrain.BrushTerrain;
import mmx.game.NotificationHandler.Notification;
import mmx.state.MenuState.MenuSubStateType;
import mmx.util.LevelUtil;
import mmx.util.SavedDataUtil;
import nape.constraint.PivotJoint;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.shape.Polygon;
import nape.space.Space;
import openfl.Assets;
import openfl.geom.Rectangle;

class GameState extends FlxState
{
	inline static var LEVEL_DATA_SCALE:Float = 2;

	var space:Space;

	var startLevelPanel:StartLevelPanel;
	var endLevelPanel:EndLevelPanel;
	var pausePanel:PausePanel;
	var helpPanel:HelpPanel;
	var gameGui:GameGui;
	var background:Background;

	var container:FlxSpriteGroup;
	var terrainContainer:FlxSpriteGroup;
	var coinContainer:FlxSpriteGroup;
	var libraryElementContainer:FlxSpriteGroup;

	var lastCameraStepOffset:FlxPoint;

	var groundBodies:Array<Body>;

	var bridgeBodies:Array<Array<Body>>;
	var bridgeBlocks:Array<Array<FlxSprite>>;

	var smallRocks:Array<SmallRock>;
	var usedSmallRocks:Array<SmallRock>;

	var coins:Array<Coin>;

	var gameObjects:Array<FlxSprite>;

	var recorder:Recorder;
	var basePlayback:Playback;
	var playerPlayback:Playback;
	var baseReplayData:String;

	var car:Car;
	var baseGhostCar:GhostCar;
	var playerGhostCar:GhostCar;
	var snow:Snow;

	/*
		var achievementManager:AchievementManager;
	*/

	var effects:Array<FlxSprite> = [];
	var crates:Array<AbstractCrate> = [];

	var levelData:LevelData;
	var levelId:UInt;
	var worldId:UInt;

	var left:Bool;
	var right:Bool;
	var up:Bool;
	var down:Bool;

	var gameTime:Float = 0;
	var gameStartTime:Float = 0;
	var pauseStartTime:Float = 0;
	var totalPausedTime:Float = 0;

	var collectedCoin:UInt = 0;
	var collectedExtraCoins:UInt = 0;

	var countOfFrontFlip:UInt = 0;
	var countOfBackFlip:UInt = 0;
	var countOfNiceWheelie:UInt = 0;
	var countOfNiceAirTime:UInt = 0;

	var isLost:Bool;
	var isWon:Bool;
	var canControll:Bool;
	var isGameStarted:Bool;
	var isGamePaused:Bool;
	var isPhysicsEnabled:Bool;

	var now:Float;

	var levelInfo:LevelInfo;

	public function new(worldId:UInt, levelId:UInt):Void
	{
		this.worldId = worldId;
		this.levelId = levelId;

		// TODO remove this hack after car selector added
		PlayerInfo.selectedCarId = worldId == 0 ? 0 : 1;

		levelInfo = SavedDataUtil.getLevelInfo(worldId, levelId);
		SavedDataUtil.resetLastPlayedInfo();
		levelInfo.isLastPlayed = true;
		SavedDataUtil.setLastPlayedWorldId(worldId);
		SavedDataUtil.save();

		super();
	}

	override public function create():Void
	{
		super.create();

		loadAssets();

		levelData = LevelUtil.LevelDataFromJson(Assets.getText("assets/data/level/world_" + worldId + "/level_" + worldId + "_" + levelId + ".json"));
		setLevelDataScale();

		try {
			baseReplayData = Assets.getText("assets/data/replay/world_" + worldId + "/replay_" + worldId + "_" + levelId + ".txt");
		}
		catch (e:Dynamic){ trace("Invalid or missing replay data."); }

		build();
	}

	function loadAssets():Void
	{
		CarDatas.loadData(Assets.getText("assets/data/car_datas.json"));

		HPPAssetManager.loadXMLAtlas("assets/images/atlas1.png", "assets/images/atlas1.xml");
		HPPAssetManager.loadXMLAtlas("assets/images/atlas2.png", "assets/images/atlas2.xml");
		HPPAssetManager.loadXMLAtlas("assets/images/atlas3.png", "assets/images/atlas3.xml");

		HPPAssetManager.loadJsonAtlas("assets/images/terrain_textures.png", "assets/images/terrain_textures.json");
	}

	function setLevelDataScale():Void
	{
		for (i in 0...levelData.groundPoints.length)
		{
			levelData.groundPoints[i] = new FlxPoint(levelData.groundPoints[i].x * LEVEL_DATA_SCALE, levelData.groundPoints[i].y * LEVEL_DATA_SCALE);
		}

		for (i in 0...levelData.starPoints.length)
		{
			levelData.starPoints[i] = new FlxPoint(levelData.starPoints[i].x * LEVEL_DATA_SCALE, levelData.starPoints[i].y * LEVEL_DATA_SCALE);
		}

		if (levelData.bridgePoints != null)
		{
			for (i in 0...levelData.bridgePoints.length)
			{
				levelData.bridgePoints[i].bridgeAX *= LEVEL_DATA_SCALE;
				levelData.bridgePoints[i].bridgeAY *= LEVEL_DATA_SCALE;
				levelData.bridgePoints[i].bridgeBX *= LEVEL_DATA_SCALE;
				levelData.bridgePoints[i].bridgeBY *= LEVEL_DATA_SCALE;
			}
		}

		if (levelData.gameObjects != null)
		{
			for (i in 0...levelData.gameObjects.length)
			{
				levelData.gameObjects[i].x *= LEVEL_DATA_SCALE;
				levelData.gameObjects[i].y *= LEVEL_DATA_SCALE;
				levelData.gameObjects[i].pivotX *= LEVEL_DATA_SCALE;
				levelData.gameObjects[i].pivotY *= LEVEL_DATA_SCALE;
			}
		}

		if (levelData.libraryElements != null)
		{
			for (i in 0...levelData.libraryElements.length)
			{
				levelData.libraryElements[i].x *= LEVEL_DATA_SCALE;
				levelData.libraryElements[i].y *= LEVEL_DATA_SCALE;
			}
		}

		levelData.startPoint = new FlxPoint(levelData.startPoint.x * LEVEL_DATA_SCALE, levelData.startPoint.y * LEVEL_DATA_SCALE);
		levelData.finishPoint = new FlxPoint(levelData.finishPoint.x * LEVEL_DATA_SCALE, levelData.finishPoint.y * LEVEL_DATA_SCALE);

		levelData.cameraBounds = new Rectangle(
			levelData.cameraBounds.x * LEVEL_DATA_SCALE,
			levelData.cameraBounds.y * LEVEL_DATA_SCALE,
			levelData.cameraBounds.width * LEVEL_DATA_SCALE,
			levelData.cameraBounds.height * LEVEL_DATA_SCALE
		);
	}

	function build():Void
	{
		destroySubStates = false;

		pausePanel = new PausePanel(resumeRequest, restartRequest, exitRequest);
		endLevelPanel = new EndLevelPanel(levelInfo, levelData, restartRequest, exitRequest, nextLevelRequest, prevLevelRequest);

		lastCameraStepOffset = new FlxPoint();

		add(background = new Background(worldId));
		add(container = new FlxSpriteGroup());

		createCamera();
		createPhysicsWorld();
		createGroundPhysics();
		createGhostCar();
		createCar();
		createGameObjects();
		createBridges();
		createGroundGraphics();
		createCoins();
		createSmallRocks();
		createLibraryElements();

		camera.follow(car.carBodyGraphics, FlxCameraFollowStyle.PLATFORMER, 5 / FlxG.updateFramerate);

		switch (worldId)
		{
			case 1:
				snow = new Snow();
				add(snow);
		}

		add(gameGui = new GameGui(resume, pauseRequest));

		//cast(camera, HPPCamera).addZoomResistanceToSprite(gameGui);
		//cast(camera, HPPCamera).addZoomResistanceToSprite(background);

		reset();

		if (levelId == 0 && !SavedDataUtil.getHelpInfo(worldId).isShowed)
		{
			helpPanel = new HelpPanel(worldId, openStartLevelPanelRequest);
			openSubState(helpPanel);
		}
	}

	function openStartLevelPanelRequest(target:HPPButton = null):Void
	{
		if (startLevelPanel != null)
		{
			startLevelPanel.destroy();
			startLevelPanel = null;
		}

		startLevelPanel = new StartLevelPanel(levelInfo, levelData.starValues, resumeRequest, exitRequest, nextLevelRequest, prevLevelRequest);
		openSubState(startLevelPanel);
	}

	function reset():Void
	{
		isLost = false;
		isWon = false;
		canControll = true;
		left = false;
		right = false;
		up = false;
		down = false;
		isGameStarted = false;
		isGamePaused = false;
		collectedCoin = 0;
		collectedExtraCoins = 0;
		countOfFrontFlip = 0;
		countOfBackFlip = 0;
		countOfNiceAirTime = 0;
		countOfNiceWheelie = 0;
		gameTime = 0;
		totalPausedTime = 0;

		car.isOnWheelie = false;
		car.isOnAir = false;
		car.jumpAngle = 0;
		car.lastAngleOnGround = 0;

		gameGui.updateCoinCount(collectedCoin);
		gameGui.updateRemainingTime(CGameTimeValue.MAXIMUM_GAME_TIME);

		for (i in 0...coins.length)
		{
			coins[ i ].reset(levelData.starPoints[ i ].x, levelData.starPoints[ i ].y);
		}

		for (i in 0...smallRocks.length)
		{
			smallRocks[ i ].reset(0, 0);
		}

		car.teleportTo(levelData.startPoint.x, levelData.startPoint.y);

		cast(camera, HPPCamera).resetPosition();
		camera.focusOn(car.carBodyGraphics.getPosition());
		background.update(1);
		lastCameraStepOffset.set(camera.scroll.x, camera.scroll.y);

		resetCrates();
		updateBridges();

		start();

		if (levelInfo.replayCarId != playerGhostCar.id)
		{
			var childIndex:UInt = container.group.members.indexOf(playerGhostCar);
			container.remove(playerGhostCar);

			playerGhostCar = new GhostCar(CarDatas.getData(levelInfo.replayCarId), 1);
			playerGhostCar.alpha = .3;
			container.insert(childIndex, playerGhostCar);
		}

		resetReplayKit();

		openStartLevelPanelRequest();
		pause();
		isPhysicsEnabled = true;
	}

	function resetReplayKit():Void
	{
		if (recorder != null) recorder.dispose();
		recorder = new Recorder(car);
		recorder.enableAutoRecording(250);

		if (basePlayback != null) basePlayback.dispose();
		if (playerPlayback != null) playerPlayback.dispose();

		var replayData:String = levelInfo.replay == null ? levelData.replay : levelInfo.replay;

		if (baseReplayData != null)
		{
			basePlayback = new Playback(baseGhostCar, baseReplayData);
			basePlayback.showSnapshot(0);
		}

		if (levelInfo.replay != null)
		{
			playerPlayback = new Playback(playerGhostCar, levelInfo.replay);
			playerPlayback.showSnapshot(0);
		}

		baseGhostCar.visible = false;
		playerGhostCar.visible = false;
	}

	function resetCrates():Void
	{
		for(i in 0...crates.length)
		{
			crates[ i ].resetToDefault();
		}
	}

	function start():Void
	{
		isGameStarted = true;

		now = gameStartTime = Date.now().getTime();

		resumeRequest();

		isPhysicsEnabled = true;
		persistentUpdate = true;
	}

	function resumeRequest(target:HPPButton = null):Void
	{
		closeSubState();

		if (!isGamePaused) pause();

		gameGui.resumeGameRequest();
	}

	function pauseRequest(target:HPPButton = null):Void
	{
		if (subState == null)
		{
			openSubState(pausePanel);
			pause();
		}
	}

	function resume():Void
	{
		isGamePaused = false;
		isPhysicsEnabled = true;

		totalPausedTime += now - pauseStartTime;

		baseGhostCar.visible = AppConfig.SHOW_3_STAR_REPLAY;
		playerGhostCar.visible = AppConfig.SHOW_PLAYER_REPLAY;

		if (recorder != null)
		{
			recorder.resume();
		}
	}

	function pause():Void
	{
		isGamePaused = true;
		isPhysicsEnabled = false;

		gameGui.pause();
		pauseStartTime = now;

		if (recorder != null)
		{
			recorder.pause();
		}
	}

	function createCamera():Void
	{
		camera = new HPPCamera();
		/*cast(camera, HPPCamera).speedZoomEnabled = true;
		cast(camera, HPPCamera).maxSpeedZoom = 2;
		cast(camera, HPPCamera).speedZoomRatio = 100;*/
		camera.bgColor = FlxColor.BLACK;
		camera.targetOffset.set(200, -50);
		camera.setScrollBoundsRect(levelData.cameraBounds.x, levelData.cameraBounds.y, levelData.cameraBounds.width, levelData.cameraBounds.height);

		FlxG.cameras.remove(FlxG.cameras.list[0], false);
		FlxG.camera = camera;
		FlxG.cameras.add(camera);
		FlxCamera.defaultCameras = [ camera ];
	}

	function createPhysicsWorld():Void
	{
		space = new Space(new Vec2(0, CPhysicsValue.GRAVITY));

		var walls:Body = new Body(BodyType.STATIC);
		walls.shapes.add(new Polygon(Polygon.rect(0, 0, 1, levelData.cameraBounds.height)));
		walls.shapes.add(new Polygon(Polygon.rect(levelData.cameraBounds.width, 0, 1, levelData.cameraBounds.height)));
		walls.space = space;
	}

	function createGroundGraphics():Void
	{
		container.add(terrainContainer = new FlxSpriteGroup());

		var generatedTerrain:BrushTerrain = new BrushTerrain(
			levelData.cameraBounds,
			levelData.groundPoints,
			HPPAssetManager.getGraphic("terrain_ground_texture_" + worldId + "0000"),
			HPPAssetManager.getGraphic("terrain_fill_texture_" + worldId + "0000"),
			64,
			24
		);

		terrainContainer.add(generatedTerrain);
	}

	function createGroundPhysics():Void
	{
		groundBodies = [];

		var filter:InteractionFilter = new InteractionFilter();
		filter.collisionGroup = CPhysicsValue.GROUND_FILTER_CATEGORY;
		filter.collisionMask = CPhysicsValue.GROUND_FILTER_MASK;

		for (i in 0...levelData.groundPoints.length - 1)
		{
			var angle:Float = Math.atan2(levelData.groundPoints[ i + 1 ].y - levelData.groundPoints[ i ].y, levelData.groundPoints[ i + 1 ].x - levelData.groundPoints[ i ].x);
			var distance:Float = Math.sqrt(
				Math.pow(Math.abs(levelData.groundPoints[ i + 1 ].x - levelData.groundPoints[ i ].x), 2) +
				Math.pow(Math.abs(levelData.groundPoints[ i + 1 ].y - levelData.groundPoints[ i ].y), 2)
			);

			var body:Body = new Body(BodyType.STATIC);

			body.shapes.add(new Polygon(Polygon.box(distance, 1)));
			body.setShapeMaterials(worldId == 1 ? CPhysicsValue.MATERIAL_SNOWY_GROUND : CPhysicsValue.MATERIAL_NORMAL_GROUND);
			body.setShapeFilters(filter);
			body.position.x = levelData.groundPoints[ i ].x + (levelData.groundPoints[ i + 1 ].x - levelData.groundPoints[ i ].x) / 2;
			body.position.y = levelData.groundPoints[ i ].y + (levelData.groundPoints[ i + 1 ].y - levelData.groundPoints[ i ].y) / 2;
			body.rotation = angle;

			body.space = space;

			groundBodies.push(body);
		}
	}

	function createBridges():Void
	{
		bridgeBodies = [];
		bridgeBlocks = [];

		var index:UInt = 0;
		for (i in 0...levelData.bridgePoints.length)
		{
			createBridge(
				new FlxPoint(levelData.bridgePoints[i].bridgeAX, levelData.bridgePoints[i].bridgeAY),
				new FlxPoint(levelData.bridgePoints[i].bridgeBX, levelData.bridgePoints[i].bridgeBY)
			);
		}
	}

	function createBridge(pointA:FlxPoint, pointB:FlxPoint):Void
	{
		var filter:InteractionFilter = new InteractionFilter();
		filter.collisionGroup = CPhysicsValue.BRIDGE_FILTER_CATEGORY;
		filter.collisionMask = CPhysicsValue.BRIDGE_FILTER_MASK;

		var bridgeAngle:Float = Math.atan2(pointB.y - pointA.y, pointB.x - pointA.x);
		var bridgeElementWidth:UInt = 60;
		var bridgeElementHeight:UInt = 30;
		var bridgeDistance:Float = pointA.distanceTo(pointB);
		var pieces:UInt = Math.floor(bridgeDistance / bridgeElementWidth) + 1;

		if (bridgeDistance % bridgeElementWidth == 0)
		{
			pieces++;
		}

		bridgeBlocks.push([]);
		bridgeBodies.push([]);

		for (i in 0...pieces)
		{
			var isLockedBridgeElement:Bool = false;
			if (i == 0 || i == cast(pieces - 1))
			{
				isLockedBridgeElement = true;
			}

			var body:Body = new Body(isLockedBridgeElement ? BodyType.STATIC : BodyType.DYNAMIC);
			body.shapes.add(new Polygon(Polygon.box(bridgeElementWidth, bridgeElementHeight)));
			body.setShapeMaterials(CPhysicsValue.MATERIAL_BRIDGE);
			body.setShapeFilters(filter);
			body.allowRotation = !isLockedBridgeElement;
			body.position.x = pointA.x + i * bridgeElementWidth * Math.cos(bridgeAngle);
			body.position.y = pointA.y + i * bridgeElementWidth * Math.sin(bridgeAngle);
			body.rotation = bridgeAngle;
			body.space = space;
			bridgeBodies[bridgeBodies.length - 1].push(body);

			var bridgeBlock:FlxSprite = HPPAssetManager.getSprite("bridge");
			container.add(bridgeBlock);
			bridgeBlocks[bridgeBlocks.length - 1].push(bridgeBlock);

			if (i > 0)
			{
				var anchorA:Vec2 = new Vec2(bridgeElementWidth / 2, 0);
				var anchorB:Vec2 = new Vec2(-bridgeElementWidth / 2, 0);

				var pivotJointLeftLeftWheel:PivotJoint = new PivotJoint(bridgeBodies[bridgeBodies.length - 1][i - 1], bridgeBodies[bridgeBodies.length - 1][i], anchorA, anchorB);
				pivotJointLeftLeftWheel.damping = 1;
				pivotJointLeftLeftWheel.frequency = 20;
				pivotJointLeftLeftWheel.space = space;
			}
		}
	}

	function createGhostCar():Void
	{
		baseGhostCar = new GhostCar(CarDatas.getData(worldId == 0 ? 0 : 1), 1);
		baseGhostCar.color = 0x00000000;
		baseGhostCar.alpha = .3;
		container.add(baseGhostCar);

		playerGhostCar = new GhostCar(CarDatas.getData(levelInfo.replayCarId), 1);
		playerGhostCar.alpha = .3;
		container.add(playerGhostCar);
	}

	function createCar():Void
	{
		car = new Car(space, levelData.startPoint.x, levelData.startPoint.y, CarDatas.getData(PlayerInfo.selectedCarId), 1, CPhysicsValue.CAR_FILTER_CATEGORY, CPhysicsValue.CAR_FILTER_MASK);
		container.add(car);
	}

	function createGameObjects():Void
	{
		gameObjects = [];

		if (levelData.gameObjects != null)
		{
			for (i in 0...levelData.gameObjects.length)
			{
				var selectedObject:FlxSprite = HPPAssetManager.getSprite(levelData.gameObjects[ i ].texture);

				selectedObject.setPosition(levelData.gameObjects[ i ].x, levelData.gameObjects[ i ].y);
				selectedObject.origin.set(levelData.gameObjects[ i ].pivotX, levelData.gameObjects[ i ].pivotY);
				selectedObject.scale.set(levelData.gameObjects[ i ].scaleX, levelData.gameObjects[ i ].scaleY);
				selectedObject.angle = levelData.gameObjects[ i ].rotation;

				container.add(selectedObject);
				gameObjects.push(selectedObject);
			}
		}
	}

	function createCoins():Void
	{
		coins = [];

		container.add(coinContainer = new FlxSpriteGroup());

		for (i in 0...levelData.starPoints.length)
		{
			coins.push(cast coinContainer.add(new Coin(levelData.starPoints[ i ].x, levelData.starPoints[ i ].y)));
		}
	}

	function createSmallRocks():Void
	{
		smallRocks = [];
		usedSmallRocks = [];

		for (i in 0...30)
		{
			var smallRock:SmallRock = new SmallRock("small_rock_" + worldId + "_" + Math.floor(Math.random() * 3 + 1), releaseSmallRock);
			container.add(smallRock);
			smallRocks.push(smallRock);
		}
	}

	function createLibraryElements():Void
	{
		if (levelData.libraryElements != null)
		{
			container.add(libraryElementContainer = new FlxSpriteGroup());

			for(i in 0...levelData.libraryElements.length)
			{
				var libraryElement:LibraryElement = levelData.libraryElements[ i ];
				var crate:AbstractCrate;

				switch(libraryElement.className)
				{
					case CLibraryElement.CRATE_0:
						crate = new SmallCrate(space, libraryElement.x, libraryElement.y, libraryElement.scale);
						libraryElementContainer.add(crate);
						crates.push(crate);

					case CLibraryElement.CRATE_1:
						crate = new Crate(space, libraryElement.x, libraryElement.y, libraryElement.scale);
						libraryElementContainer.add(crate);
						crates.push(crate);

					case CLibraryElement.CRATE_2:
						crate = new LongCrate(space, libraryElement.x, libraryElement.y, libraryElement.scale);
						libraryElementContainer.add(crate);
						crates.push(crate);

					case CLibraryElement.CRATE_3:
						crate = new SmallLongCrate(space, libraryElement.x, libraryElement.y, libraryElement.scale);
						libraryElementContainer.add(crate);
						crates.push(crate);

					case CLibraryElement.CRATE_4:
						crate = new RampCrate(space, libraryElement.x, libraryElement.y, libraryElement.scale);
						libraryElementContainer.add(crate);
						crates.push(crate);

					case CLibraryElement.CRATE_5:
						crate = new SmallRampCrate(space, libraryElement.x, libraryElement.y, libraryElement.scale);
						libraryElementContainer.add(crate);
						crates.push(crate);
				}
			}
		}
	}

	override public function update(elapsed:Float):Void
	{
		now = Date.now().getTime();

		super.update(elapsed);

		if (isPhysicsEnabled)
		{
			space.step(CPhysicsValue.STEP);
		}

		if (isGamePaused)
		{
			return;
		}

		calculateGameTime();

		if (!isLost && !isWon)
		{
			gameGui.updateRemainingTime(Math.max(0, CGameTimeValue.MAXIMUM_GAME_TIME - gameTime));
			gameGui.updateCoinCount(collectedCoin);

			up = FlxG.keys.anyPressed([UP, W]) || gameGui.controlUpState;
			down = FlxG.keys.anyPressed([DOWN, S]) || gameGui.controlDownState;
			right = FlxG.keys.anyPressed([RIGHT, D]) || gameGui.controlRightState;
			left = FlxG.keys.anyPressed([LEFT, A]) || gameGui.controlLeftState;
		}
		else
		{
			up = down = right = left = false;
		}

		if (up)
		{
			car.accelerateToRight();
		}
		else if (down)
		{
			car.accelerateToLeft();
		}

		if (right)
		{
			car.rotateRight();
		}
		else if (left)
		{
			car.rotateLeft();
		}

		updateBridges();
		updateSmallRocks();

		if (!isLost)
		{
			checkCoinPickUp();
			checkWheelieState();
			checkFlipAndNiceAirTimeState();
			checkLoose();
			checkWin();

			if (AppConfig.IS_DESKTOP_DEVICE && (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.P))
				pauseRequest(null);
		}

		if (AppConfig.SHOW_3_STAR_REPLAY && basePlayback != null)
			basePlayback.showSnapshot(recorder.getElapsedTime());

		if (AppConfig.SHOW_PLAYER_REPLAY && playerPlayback != null)
			playerPlayback.showSnapshot(recorder.getElapsedTime());
	}

	function calculateGameTime():Void
	{
		if (isGameStarted)
		{
			gameTime = now - gameStartTime - totalPausedTime;
		}
		else
		{
			gameTime = 0;
		}
	}

	function updateBridges():Void
	{
		for (i in 0...bridgeBlocks.length)
		{
			for (j in 0...bridgeBlocks[i].length)
			{
				var block:FlxSprite = bridgeBlocks[i][j];
				var body:Body = bridgeBodies[i][j];

				block.x = body.position.x - block.origin.x;
				block.y = body.position.y - block.origin.y;
				block.angle = body.rotation * FlxAngle.TO_DEG;
			}
		}
	}

	function updateSmallRocks():Void
	{
		var leftAngularVelocity:Float = Math.abs(car.wheelLeftPhysics.angularVel);
		var rightAngularVelocity:Float = Math.abs(car.wheelRightPhysics.angularVel);
		var carDirection:Int = car.wheelLeftPhysics.velocity.x >= 0 ? 1 : -1;

		if (!car.leftWheelOnAir && (up || down) && smallRocks.length > 0 && leftAngularVelocity > 5 && Math.random() > .8)
		{
			usedSmallRocks.push(smallRocks[ smallRocks.length - 1 ]);
			smallRocks.pop();

			var selectedSmallRock:SmallRock = usedSmallRocks[ usedSmallRocks.length - 1 ];
			selectedSmallRock.visible = true;
			selectedSmallRock.alpha = 1;
			selectedSmallRock.x = car.wheelLeftGraphics.x + car.wheelLeftGraphics.width / 2 + -carDirection * car.wheelLeftGraphics.width / 4;
			selectedSmallRock.y = car.wheelLeftGraphics.y + car.wheelLeftGraphics.height - selectedSmallRock.height;
			selectedSmallRock.startAnim(-carDirection, car.carBodyGraphics.angle * FlxAngle.TO_RAD);
		}

		if (!car.rightWheelOnAir && (up || down) && smallRocks.length > 0 && rightAngularVelocity > 5 && Math.random() > .8)
		{
			usedSmallRocks.push(smallRocks[ smallRocks.length - 1 ]);
			smallRocks.pop();

			var selectedSmallRock:SmallRock = usedSmallRocks[ usedSmallRocks.length - 1 ];
			selectedSmallRock.visible = true;
			selectedSmallRock.alpha = 1;
			selectedSmallRock.x = car.wheelRightGraphics.x + car.wheelRightGraphics.width / 2 + -carDirection * car.wheelRightGraphics.width / 4;
			selectedSmallRock.y = car.wheelRightGraphics.y + car.wheelRightGraphics.height - selectedSmallRock.height;
			selectedSmallRock.startAnim(-carDirection, car.carBodyGraphics.angle * FlxAngle.TO_RAD);
		}
	}

	function releaseSmallRock(target:SmallRock):Void
	{
		smallRocks.push(target);
		usedSmallRocks.remove(target);
	}

	function checkCoinPickUp():Void
	{
		for (i in 0...coins.length)
		{
			var coin:Coin = coins[ i ];

			if (!coin.isCollected && coin.overlaps(car.carBodyGraphics))
			{
				coin.collect();
				collectedCoin++;
			}
		}
	}

	function checkWheelieState():Void
	{
		var isWheelieInProgress:Bool = (car.rightWheelOnAir && !car.leftWheelOnAir) || (!car.rightWheelOnAir && car.leftWheelOnAir);

		if(!isWheelieInProgress && car.isOnWheelie && gameTime - car.onWheelieStartGameTime > CGameTimeValue.MINIMUM_TIME_TO_NICE_WHEELIE_IN_MS)
		{
			startNiceWheelieTimeRutin();
		}

		if(isWheelieInProgress && !car.isOnWheelie)
		{
			car.onWheelieStartGameTime = gameTime;
		}

		car.isOnWheelie = isWheelieInProgress;
	}

	function checkFlipAndNiceAirTimeState():Void
	{
		var newIsOnAirValue:Bool = car.leftWheelOnAir && car.rightWheelOnAir;

		if(car.leftWheelOnAir && car.rightWheelOnAir)
		{
			var currentAngle:Float = Math.atan2(car.wheelLeftGraphics.y - car.wheelRightGraphics.y, car.wheelLeftGraphics.x - car.wheelRightGraphics.x);
			currentAngle = car.wheelLeftGraphics.x - car.wheelRightGraphics.x < 0 ? (Math.PI * 2 + currentAngle) : currentAngle;

			while(currentAngle > Math.PI * 2)
			{
				currentAngle -= Math.PI * 2;
			}

			if(!car.isOnAir)
			{
				car.onAirStartGameTime = gameTime;
				car.isOnAir = true;
				car.jumpAngle = 0;
				car.lastAngleOnGround = currentAngle;
			}

			var angleDiff:Float = currentAngle - car.lastAngleOnGround;

			if(angleDiff < -Math.PI)
			{
				angleDiff += Math.PI * 2;
				angleDiff *= -1;
			}
			else if(angleDiff > Math.PI)
			{
				angleDiff -= Math.PI * 2;
				angleDiff *= -1;
			}

			car.lastAngleOnGround = currentAngle;
			car.jumpAngle += angleDiff;
		}
		else if(car.isOnAir)
		{
			var angleInDeg:Float = car.jumpAngle * (180 / Math.PI);

			car.isOnAir = false;
			car.jumpAngle = 0;
			car.lastAngleOnGround = 0;

			if(angleInDeg > 200)
			{
				startFrontFlipRutin();
			}
			else if(angleInDeg < -200)
			{
				startBackFlipRutin();
			}

			if(gameTime - car.onAirStartGameTime > CGameTimeValue.MINIMUM_TIME_TO_NICE_AIR_IN_MS)
			{
				startNiceAirTimeRutin();
			}
		}
	}

	function checkLoose():Void
	{
		if (!isLost && !isWon && (car.isCarCrashed || gameTime >= CGameTimeValue.MAXIMUM_GAME_TIME))
		{
			isLost = true;

			if (car.isCarCrashed)
			{
				camera.shake(.02, .2);
				addEffect(car.carBodyGraphics.x - 30, car.carBodyGraphics.y - 20, GameEffect.TYPE_CRUSHED);
			}
			else
			{
				addEffect(car.carBodyGraphics.x - 30, car.carBodyGraphics.y - 20, GameEffect.TYPE_TIME_OUT);
			}

			if (!levelInfo.isCompleted || levelInfo.replay == null || !levelInfo.isFullReplay)
			{
				levelInfo.replay = recorder.toString();
				levelInfo.replayCarId = PlayerInfo.selectedCarId;
			}

			Timer.delay(restartRutin, 1500);
		}
	}

	function checkWin():Void
	{
		if (!isLost && !isWon && car.carBodyGraphics.x >= levelData.finishPoint.x)
		//if (!isLost && !isWon && gameTime > 2000) // temporary for instant win
		{
			isWon = true;

			addEffect(car.carBodyGraphics.x - 30, car.carBodyGraphics.y - 20, GameEffect.TYPE_LEVEL_COMPLETED);

			Timer.delay(winRutin, 500);
		}
	}

	function winRutin():Void
	{
		recorder.takeSnapshot();

		var score:UInt = calculateScore();

		var starCount:UInt = scoreToStarCount(score);

		if (score >= levelInfo.score || levelInfo.replay == null || !levelInfo.isCompleted || !levelInfo.isFullReplay)
		{
			levelInfo.replay = recorder.toString();
			levelInfo.replayCarId = PlayerInfo.selectedCarId;
			levelInfo.isFullReplay = true;
		}

		// Temporary for save base replays
		//trace(recorder.toString());

		levelInfo.time = (levelInfo.time > gameTime || levelInfo.time == 0) ? gameTime : levelInfo.time;
		levelInfo.score = levelInfo.score < score ? score : levelInfo.score;
		levelInfo.isCompleted = true;
		levelInfo.starCount = levelInfo.starCount < starCount ? starCount : levelInfo.starCount;
		levelInfo.collectedCoins = levelInfo.collectedCoins < collectedCoin ? collectedCoin : levelInfo.collectedCoins;

		var nextLevelInfo:LevelInfo;
		if (levelId < 23)
		{
			nextLevelInfo = SavedDataUtil.getLevelInfo(worldId, levelId + 1);
			nextLevelInfo.isEnabled = true;
		}
		if (levelId == 23)
		{
			nextLevelInfo = SavedDataUtil.getLevelInfo(worldId + 1, 0);
			nextLevelInfo.isEnabled = true;
		}

		SavedDataUtil.save();

		persistentUpdate = false;
		openSubState(endLevelPanel);
		endLevelPanel.updateView(score, gameTime, collectedCoin, starCount);
	}

	function calculateScore():UInt
	{
		var result = 0;

		result = Math.floor(AppConfig.MAXIMUM_GAME_TIME_BONUS - gameTime / 10);
		result += collectedCoin * AppConfig.COIN_SCORE_MULTIPLIER;
		result += collectedExtraCoins;
		result += levelData.starPoints.length == collectedCoin ? AppConfig.ALL_COINS_COLLECTED_BONUS : 0;

		return result;
	}

	public function scoreToStarCount(value:UInt):UInt
	{
		var starCount:UInt = 0;

		for(i in 0...levelData.starValues.length)
		{
			if(value >= levelData.starValues[i])
			{
				starCount = i + 1;
			}
			else
			{
				return starCount;
			}
		}

		return starCount;
	}

	function startFrontFlipRutin():Void
	{
		countOfFrontFlip++;

		collectedExtraCoins += CScore.SCORE_FRONT_FLIP;

		//checkFrontFlipTasks();

		gameGui.addNotification(Notification.FRONT_FLIP);
	}

	function startBackFlipRutin():Void
	{
		countOfBackFlip++;

		collectedExtraCoins += CScore.SCORE_BACK_FLIP;

		//checkBackFlipTasks();

		gameGui.addNotification(Notification.BACK_FLIP);
	}

	function startNiceAirTimeRutin():Void
	{
		countOfNiceAirTime++;

		collectedExtraCoins += CScore.SCORE_NICE_AIR_TIME;

		//checkNiceAirTimeTasks();

		gameGui.addNotification(Notification.NICE_AIR);
	}


	function startNiceWheelieTimeRutin():Void
	{
		countOfNiceWheelie++;

		collectedExtraCoins += CScore.SCORE_NICE_WHEELIE_TIME;

		//checkNiceWheelieTimeTasks();

		gameGui.addNotification(Notification.NICE_WHEELIE);
	}

	function addEffect(x:Float, y:Float, effectType:GameEffect):Void
	{
		var effect:FlxSprite = HPPAssetManager.getSprite(cast effectType);

		effect.origin.set(effect.width / 2, effect.height / 2);
		effect.x = x;
		effect.y = y;
		effect.scale.set(.5, .5);
		effect.alpha = AppConfig.IS_ALPHA_ANIMATION_ENABLED ? 0 : 1;

		if (AppConfig.IS_ALPHA_ANIMATION_ENABLED)
		{
			FlxTween.tween(
				effect,
				{ alpha: 1 },
				.5
			);
			FlxTween.tween(
				effect,
				{ alpha: 0 },
				.3,
				{ startDelay: 1 }
			);
		}

		FlxTween.tween(
			effect.scale,
			{
				x: 1,
				y: 1,
			},
			.3
		);

		FlxTween.tween(
			effect.scale,
			{
				x: 0,
				y: 0,
			},
			.2,
			{ startDelay: 1, onComplete: function(_) { disposeEffect(effect); } }
		);

		container.add(effect);
		effects.push(effect);
	}

	function disposeEffect(target:FlxSprite):Void
	{
		for (effect in effects)
		{
			if (effect == target)
			{
				effects.remove(effect);
				effect.destroy();
				effect = null;

				return;
			}
		}
	}

	function restartRutin():Void
	{
		reset();
	}

	function restartRequest(target:HPPButton = null):Void
	{
		restartRutin();
	}

	function exitRequest(target:HPPButton = null):Void
	{
		FlxG.switchState(new MenuState(MenuSubStateType.LEVEL_SELECTOR, {worldId: worldId}));
	}

	function nextLevelRequest(target:HPPButton = null):Void
	{
		FlxG.switchState(new GameState(worldId, levelId + 1));
	}

	function prevLevelRequest(target:HPPButton = null):Void
	{
		FlxG.switchState(new GameState(worldId, levelId - 1));
	}

	override public function onFocusLost():Void
	{
		if (isGameStarted)
		{
			pauseRequest();
		}

		super.onFocusLost();
	}

	override public function destroy():Void
	{
		HPPAssetManager.clear();

		super.destroy();
	}
}

@:enum
abstract GameEffect(String)
{
	var TYPE_LEVEL_COMPLETED = "effect_level_completed";
	var TYPE_CRUSHED = "effect_crushed";
	var TYPE_TIME_OUT = "effect_time_out";
}