package mmx.state;

import flixel.FlxCamera;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import hpp.flixel.HPPCamera;
import hpp.flixel.util.HPPAssetManager;
import mmx.assets.CarDatas;
import mmx.datatype.LevelData;
import mmx.game.Background;
import mmx.game.Car;
import mmx.game.Coin;
import mmx.game.GameGui;
import mmx.game.SmallRock;
import mmx.game.constant.CGameTimeValue;
import mmx.game.constant.CLibraryElement;
import mmx.game.constant.CPhysicsValue;
import mmx.game.library.crate.AbstractCrate;
import mmx.game.library.crate.Crate;
import mmx.game.library.crate.LongCrate;
import mmx.game.library.crate.RampCrate;
import mmx.game.library.crate.SmallCrate;
import mmx.game.library.crate.SmallLongCrate;
import mmx.game.library.crate.SmallRampCrate;
import mmx.game.snow.Snow;
import mmx.game.terrain.BrushTerrain;
import mmx.util.LevelUtil;
import nape.constraint.PivotJoint;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import openfl.Assets;
import openfl.geom.Rectangle;

class GameState extends FlxState
{
	inline static var LEVEL_DATA_SCALE:Float = 2;

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

	/*var controlLeft:Image;
	var controlRight:Image;
	var controlUp:Image;
	var controlDown:Image;*/
	var car:Car;
	var snow:Snow;
	/*

		var achievementManager:AchievementManager;

		var effects:Vector.<Image> = new Vector.<Image>;
	*/
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

	public function new( worldId:UInt, levelId:UInt ):Void
	{
		this.worldId = worldId;
		this.levelId = levelId;
		
		super();
	}
	
	override public function create():Void
	{
		super.create();

		loadAssets();
		
		levelData = LevelUtil.LevelDataFromJson( Assets.getText( "assets/data/level/world_" + worldId + "/level_" + worldId + "_" + levelId + ".json" ) );
		setLevelDataScale();

		build();
	}
	
	function loadAssets():Void
	{
		CarDatas.loadData( Assets.getText( "assets/data/car_datas.json" ) );
		
		HPPAssetManager.loadXMLAtlas( "assets/images/atlas1.png", "assets/images/atlas1.xml" );
		HPPAssetManager.loadXMLAtlas( "assets/images/atlas2.png", "assets/images/atlas2.xml" );
		HPPAssetManager.loadXMLAtlas( "assets/images/atlas3.png", "assets/images/atlas3.xml" );
		
		HPPAssetManager.loadJsonAtlas( "assets/images/terrain_textures.png", "assets/images/terrain_textures.json" );
		
		HPPAssetManager.loadXMLBitmapFont( "assets/fonts/aachen-light.png", "assets/fonts/aachen-light.fnt.xml" );
	}

	function setLevelDataScale():Void
	{
		for ( i in 0...levelData.groundPoints.length )
		{
			levelData.groundPoints[i] = new FlxPoint( levelData.groundPoints[i].x * LEVEL_DATA_SCALE, levelData.groundPoints[i].y * LEVEL_DATA_SCALE );
		}

		for ( i in 0...levelData.starPoints.length )
		{
			levelData.starPoints[i] = new FlxPoint( levelData.starPoints[i].x * LEVEL_DATA_SCALE, levelData.starPoints[i].y * LEVEL_DATA_SCALE );
		}

		if ( levelData.bridgePoints != null )
		{
			for ( i in 0...levelData.bridgePoints.length )
			{
				levelData.bridgePoints[i].bridgeAX *= LEVEL_DATA_SCALE;
				levelData.bridgePoints[i].bridgeAY *= LEVEL_DATA_SCALE;
				levelData.bridgePoints[i].bridgeBX *= LEVEL_DATA_SCALE;
				levelData.bridgePoints[i].bridgeBY *= LEVEL_DATA_SCALE;
			}
		}
		
		if ( levelData.gameObjects != null )
		{
			for ( i in 0...levelData.gameObjects.length )
			{
				levelData.gameObjects[i].x *= LEVEL_DATA_SCALE;
				levelData.gameObjects[i].y *= LEVEL_DATA_SCALE;
				levelData.gameObjects[i].pivotX *= LEVEL_DATA_SCALE;
				levelData.gameObjects[i].pivotY *= LEVEL_DATA_SCALE;
			}
		}
		
		if ( levelData.libraryElements != null )
		{
			for ( i in 0...levelData.libraryElements.length )
			{
				levelData.libraryElements[i].x *= LEVEL_DATA_SCALE;
				levelData.libraryElements[i].y *= LEVEL_DATA_SCALE;
			}
		}
		
		levelData.startPoint = new FlxPoint( levelData.startPoint.x * LEVEL_DATA_SCALE, levelData.startPoint.y * LEVEL_DATA_SCALE );
		levelData.finishPoint = new FlxPoint( levelData.finishPoint.x * LEVEL_DATA_SCALE, levelData.finishPoint.y * LEVEL_DATA_SCALE );

		levelData.cameraBounds = new Rectangle(
			levelData.cameraBounds.x * LEVEL_DATA_SCALE,
			levelData.cameraBounds.y * LEVEL_DATA_SCALE,
			levelData.cameraBounds.width * LEVEL_DATA_SCALE,
			levelData.cameraBounds.height * LEVEL_DATA_SCALE
		);
	}

	function build():Void
	{
		lastCameraStepOffset = new FlxPoint();

		add( background = new Background( worldId ) );
		add( container = new FlxSpriteGroup() );

		createCamera();
		createPhysicsWorld();
		createGroundPhysics();
		createCar();
		createGameObjects();
		createBridges();
		createGroundGraphics();
		createCoins();
		createSmallRocks();
		createLibraryElements();

		camera.follow( car.carBodyGraphics, FlxCameraFollowStyle.PLATFORMER, 5 / FlxG.updateFramerate );

		/*
				

				// add control buttons
				addChild( _controlLeft = new Image( StaticAssetManager.instance.getTexture( "control_left" ) ) );
				_controlLeft.x = 10;
				_controlLeft.y = stage.stageHeight - 10 - _controlLeft.height;
				addChild( _controlRight = new Image( StaticAssetManager.instance.getTexture( "control_right" ) ) );
				_controlRight.x = _controlLeft.x + _controlLeft.width + 10;
				_controlRight.y = _controlLeft.y;
				addChild( _controlUp = new Image( StaticAssetManager.instance.getTexture( "control_up" ) ) );
				_controlUp.x = stage.stageWidth - 10 - _controlUp.width;
				_controlUp.y = _controlLeft.y;
				addChild( _controlDown = new Image( StaticAssetManager.instance.getTexture( "control_down" ) ) );
				_controlDown.x = _controlUp.x - _controlUp.width - 10;
				_controlDown.y = _controlLeft.y;
		*/
		switch ( worldId )
		{
			case 1:
				snow = new Snow();
				add( snow );
		}
		/*
				_gameGui.addEventListener( GameGuiEvent.INGAME_RESTART_REQUEST, restartRequest );
				_gameGui.addEventListener( GameGuiEvent.PAUSE_REQUEST, pauseRequest );
				_gameGui.addEventListener( GameGuiEvent.RESUME_REQUEST, resumeRequest );
				_gameGui.addEventListener( GameGuiEvent.GAME_END_REQUEST, gameEndRequest );
				_gameGui.addEventListener( GameGuiEvent.NEXT_LEVEL_REQUEST, nextLevelRequest );

				if( !CONFIG::IS_IOS_VERSION && !CONFIG::IS_ANDROID_VERSION )
				{
					stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeydown );
					stage.addEventListener( KeyboardEvent.KEY_UP, onKeyup );
				}
				addEventListener( TouchEvent.TOUCH, onTouch );
		*/
		add( gameGui = new GameGui( resume, pause ) );
		
		//cast( camera, HPPCamera ).addZoomResistanceToSprite( gameGui );
		//cast( camera, HPPCamera ).addZoomResistanceToSprite( background );

		reset();
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

		gameGui.updateCoinCount( collectedCoin );
		gameGui.updateRemainingTime( CGameTimeValue.MAXIMUM_GAME_TIME );

		for ( i in 0...coins.length )
		{
			coins[ i ].reset( levelData.starPoints[ i ].x, levelData.starPoints[ i ].y );
		}

		for ( i in 0...smallRocks.length )
		{
			smallRocks[ i ].reset( 0, 0 );
		}

		car.teleportTo( levelData.startPoint.x, levelData.startPoint.y );

		cast( camera, HPPCamera ).resetPosition();
		camera.focusOn( car.carBodyGraphics.getPosition() );
		lastCameraStepOffset.set( camera.scroll.x, camera.scroll.y );

		resetCrates();
		
		/*

		switch( _worldID )
		{
			case 1:
				_car.wheelLeft.SetLinearDamping( _car.damping + .3 );
				_car.wheelRight.SetLinearDamping( _car.damping + .3 );
				break;
		}

		this._gameGui.showStartGamePanel( exit );
		this._gameGui.enable();*/

		start();
	}
	
	function resetCrates():Void
	{
		for( i in 0...crates.length )
		{
			crates[ i ].resetToDefault();
		}
	}

	function start():Void
	{
		isGameStarted = true;

		gameStartTime = Date.now().getTime();

		resumeRequest();
		update( 0 );
	}

	function resumeRequest():Void
	{
		if ( !isGamePaused )
		{
			pause();
		}

		gameGui.resumeGameRequest();
	}

	function resume():Void
	{
		isGamePaused = false;
		
		totalPausedTime += Date.now().getTime() - pauseStartTime;
	}

	function pause():Void
	{
		isGamePaused = true;
		
		pauseStartTime = Date.now().getTime();
	}

	function createCamera():Void
	{
		camera = new HPPCamera();
		/*cast( camera, HPPCamera ).speedZoomEnabled = true;
		cast( camera, HPPCamera ).maxSpeedZoom = 2;
		cast( camera, HPPCamera ).speedZoomRatio = 100;*/
		camera.bgColor = FlxColor.BLACK;
		camera.targetOffset.set( 200, -50 );
		camera.setScrollBoundsRect( levelData.cameraBounds.x, levelData.cameraBounds.y, levelData.cameraBounds.width, levelData.cameraBounds.height );

		FlxG.cameras.remove( FlxG.cameras.list[0], false );
		FlxG.camera = camera;
		FlxG.cameras.add( camera );
		FlxCamera.defaultCameras = [ camera ];
	}

	function createPhysicsWorld():Void
	{
		FlxNapeSpace.init();
		FlxNapeSpace.space.gravity.setxy( 0, CPhysicsValue.GRAVITY );
		FlxNapeSpace.createWalls( 0, -500, levelData.cameraBounds.width, levelData.cameraBounds.height );

		#if debug
			FlxNapeSpace.drawDebug = true;
		#end
	}

	function createGroundGraphics():Void
	{
		container.add( terrainContainer = new FlxSpriteGroup() );

		var generatedTerrain:BrushTerrain = new BrushTerrain(
			levelData.cameraBounds,
			levelData.groundPoints,
			HPPAssetManager.getGraphic( "terrain_ground_texture_" + worldId + "0000" ),
			HPPAssetManager.getGraphic( "terrain_fill_texture_" + worldId + "0000" ),
			64,
			24,
			.5
		);
		generatedTerrain.origin.set( 0, 0 );
		generatedTerrain.scale.set( 2, 2 );

		terrainContainer.add( generatedTerrain );
	}

	function createGroundPhysics():Void
	{
		groundBodies = [];

		var filter:InteractionFilter = new InteractionFilter();
		filter.collisionGroup = CPhysicsValue.GROUND_FILTER_CATEGORY;
		filter.collisionMask = CPhysicsValue.GROUND_FILTER_MASK;

		for ( i in 0...levelData.groundPoints.length - 1 )
		{
			var angle:Float = Math.atan2( levelData.groundPoints[ i + 1 ].y - levelData.groundPoints[ i ].y, levelData.groundPoints[ i + 1 ].x - levelData.groundPoints[ i ].x );
			var distance:Float = Math.sqrt(
				Math.pow( Math.abs( levelData.groundPoints[ i + 1 ].x - levelData.groundPoints[ i ].x ), 2 ) +
				Math.pow( Math.abs( levelData.groundPoints[ i + 1 ].y - levelData.groundPoints[ i ].y ), 2 )
			);

			var body:Body = new Body( BodyType.STATIC );

			body.shapes.add( new Polygon( Polygon.box( distance, 1 ) ) );
			body.setShapeMaterials( new Material( .5, .5, .5, 2, 0.001 ) );

			body.position.x = levelData.groundPoints[ i ].x + ( levelData.groundPoints[ i + 1 ].x - levelData.groundPoints[ i ].x ) / 2;
			body.position.y = levelData.groundPoints[ i ].y + ( levelData.groundPoints[ i + 1 ].y - levelData.groundPoints[ i ].y ) / 2;
			body.rotation = angle;

			body.space = FlxNapeSpace.space;

			groundBodies.push( body );
		}
	}

	function createBridges():Void
	{
		bridgeBodies = [];
		bridgeBlocks = [];

		var index:UInt = 0;
		for ( i in 0...levelData.bridgePoints.length )
		{
			createBridge(
				new FlxPoint( levelData.bridgePoints[i].bridgeAX, levelData.bridgePoints[i].bridgeAY ),
				new FlxPoint( levelData.bridgePoints[i].bridgeBX, levelData.bridgePoints[i].bridgeBY )
			);
		}
	}

	function createBridge( pointA:FlxPoint, pointB:FlxPoint ):Void
	{
		var filter:InteractionFilter = new InteractionFilter();
		filter.collisionGroup = CPhysicsValue.BRIDGE_FILTER_CATEGORY;
		filter.collisionMask = CPhysicsValue.BRIDGE_FILTER_MASK;

		var bridgeAngle:Float = Math.atan2( pointB.y - pointA.y, pointB.x - pointA.x );
		var bridgeElementWidth:UInt = 60;
		var bridgeElementHeight:UInt = 30;
		var bridgeDistance:Float = pointA.distanceTo( pointB );
		var pieces:UInt = Math.floor( bridgeDistance / bridgeElementWidth ) + 1;

		if ( bridgeDistance % bridgeElementWidth == 0 )
		{
			pieces++;
		}

		bridgeBlocks.push( [] );
		bridgeBodies.push( [] );

		for ( i in 0...pieces )
		{
			var isLockedBridgeElement:Bool = false;
			if ( i == 0 || i == cast( pieces - 1 ) )
			{
				isLockedBridgeElement = true;
			}

			var body:Body = new Body( isLockedBridgeElement ? BodyType.STATIC : BodyType.DYNAMIC );
			body.shapes.add( new Polygon( Polygon.box( bridgeElementWidth, bridgeElementHeight ) ) );
			body.setShapeMaterials( new Material( .5, .5, .5, 2, 0.001 ) );
			body.setShapeFilters( filter );
			body.allowRotation = !isLockedBridgeElement;
			body.position.x = pointA.x + i * bridgeElementWidth * Math.cos( bridgeAngle );
			body.position.y = pointA.y + i * bridgeElementWidth * Math.sin( bridgeAngle );
			body.rotation = bridgeAngle;
			body.space = FlxNapeSpace.space;
			bridgeBodies[bridgeBodies.length - 1].push( body );

			var bridgeBlock:FlxSprite = HPPAssetManager.getSprite( "bridge" );
			container.add( bridgeBlock );
			bridgeBlocks[bridgeBlocks.length - 1].push( bridgeBlock );

			if ( i > 0 )
			{
				var anchorA:Vec2 = new Vec2( bridgeElementWidth / 2, 0 );
				var anchorB:Vec2 = new Vec2( -bridgeElementWidth / 2, 0 );

				var pivotJointLeftLeftWheel:PivotJoint = new PivotJoint( bridgeBodies[bridgeBodies.length - 1][i - 1], bridgeBodies[bridgeBodies.length - 1][i], anchorA, anchorB );
				pivotJointLeftLeftWheel.damping = 1;
				pivotJointLeftLeftWheel.frequency = 20;
				pivotJointLeftLeftWheel.space = FlxNapeSpace.space;
			}
		}
	}

	function createCar():Void
	{
		car = new Car( levelData.startPoint.x, levelData.startPoint.y, CarDatas.getData( 0 ), 1, CPhysicsValue.CAR_FILTER_CATEGORY, CPhysicsValue.CAR_FILTER_MASK );
		container.add( car );
	}
	
	function createGameObjects():Void
	{
		gameObjects = [];

		if ( levelData.gameObjects != null )
		{
			for ( i in 0...levelData.gameObjects.length )
			{
				var selectedObject:FlxSprite = HPPAssetManager.getSprite( levelData.gameObjects[ i ].texture );

				selectedObject.setPosition( levelData.gameObjects[ i ].x, levelData.gameObjects[ i ].y );
				selectedObject.origin.set( levelData.gameObjects[ i ].pivotX, levelData.gameObjects[ i ].pivotY );
				selectedObject.scale.set( levelData.gameObjects[ i ].scaleX, levelData.gameObjects[ i ].scaleY );
				selectedObject.angle = levelData.gameObjects[ i ].rotation;

				container.add( selectedObject );
				gameObjects.push( selectedObject );
			}
		}
	}

	function createCoins():Void
	{
		coins = [];

		container.add( coinContainer = new FlxSpriteGroup() );

		for ( i in 0...levelData.starPoints.length )
		{
			coins.push( cast coinContainer.add( new Coin( levelData.starPoints[ i ].x, levelData.starPoints[ i ].y ) ) );
		}
	}

	function createSmallRocks():Void
	{
		smallRocks = [];
		usedSmallRocks = [];

		for ( i in 0...30 )
		{
			var smallRock:SmallRock = new SmallRock( "small_rock_" + worldId + "_" + Math.floor( Math.random() * 3 + 1 ), releaseSmallRock );
			container.add( smallRock );
			smallRocks.push( smallRock );
		}
	}

	function createLibraryElements():Void
	{
		if ( levelData.libraryElements != null )
		{
			container.add( libraryElementContainer = new FlxSpriteGroup() );

			for( i in 0...levelData.libraryElements.length )
			{
				var libraryElement:LibraryElement = levelData.libraryElements[ i ];
				var crate:AbstractCrate;
				
				switch( libraryElement.className )
				{
					case CLibraryElement.CRATE_0:
						crate = new SmallCrate( libraryElement.x, libraryElement.y, libraryElement.scale );
						libraryElementContainer.add( crate );
						crates.push( crate );

					case CLibraryElement.CRATE_1:
						crate = new Crate( libraryElement.x, libraryElement.y, libraryElement.scale );
						libraryElementContainer.add( crate );
						crates.push( crate );

					case CLibraryElement.CRATE_2:
						crate = new LongCrate( libraryElement.x, libraryElement.y, libraryElement.scale );
						libraryElementContainer.add( crate );
						crates.push( crate );

					case CLibraryElement.CRATE_3:
						crate = new SmallLongCrate( libraryElement.x, libraryElement.y, libraryElement.scale );
						libraryElementContainer.add( crate );
						crates.push( crate );

					case CLibraryElement.CRATE_4:
						crate = new RampCrate( libraryElement.x, libraryElement.y, libraryElement.scale );
						libraryElementContainer.add( crate );
						crates.push( crate );

					case CLibraryElement.CRATE_5:
						crate = new SmallRampCrate( libraryElement.x, libraryElement.y, libraryElement.scale );
						libraryElementContainer.add( crate );
						crates.push( crate );
				}
			}
		}
	}

	override public function update( elapsed:Float ):Void
	{
		super.update( elapsed );
		
		if ( isGamePaused )
		{
			return;
		}
		
		calculateGameTime();
		gameGui.updateRemainingTime( Math.max( 0, CGameTimeValue.MAXIMUM_GAME_TIME - gameTime ) );

		car.accelerateToRight();

		updateBridges();
		updateSmallRocks();

		checkCoinPickUp();
		checkLoose();
		checkWin();
	}

	function calculateGameTime():Void
	{
		if ( isGameStarted )
		{
			var now:Float = Date.now().getTime();
			gameTime = now - gameStartTime - totalPausedTime;
		}
		else
		{
			gameTime = 0;
		}
	}

	function updateBridges():Void
	{
		for ( i in 0...bridgeBlocks.length )
		{
			for ( j in 0...bridgeBlocks[i].length )
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
		var leftAngularVelocity:Float = Math.abs( car.wheelLeftPhysics.angularVel );
		var rightAngularVelocity:Float = Math.abs( car.wheelRightPhysics.angularVel );
		var carDirection:Int = car.wheelLeftPhysics.velocity.x >= 0 ? 1 : -1;

		if ( !car.leftWheelOnAir /*&& ( _up || _down )*/ && smallRocks.length > 0 && leftAngularVelocity > 5 && Math.random() > .8 )
		{
			usedSmallRocks.push( smallRocks[ smallRocks.length - 1 ] );
			smallRocks.pop();

			var selectedSmallRock:SmallRock = usedSmallRocks[ usedSmallRocks.length - 1 ];
			selectedSmallRock.visible = true;
			selectedSmallRock.alpha = 1;
			selectedSmallRock.x = car.wheelLeftGraphics.x + car.wheelLeftGraphics.width / 2 + -carDirection * car.wheelLeftGraphics.width / 4;
			selectedSmallRock.y = car.wheelLeftGraphics.y + car.wheelLeftGraphics.height - selectedSmallRock.height;
			selectedSmallRock.startAnim( -carDirection, car.carBodyGraphics.angle * FlxAngle.TO_RAD );
		}

		if ( !car.rightWheelOnAir /*&& ( _up || _down )*/ && smallRocks.length > 0 && rightAngularVelocity > 5 && Math.random() > .8 )
		{
			usedSmallRocks.push( smallRocks[ smallRocks.length - 1 ] );
			smallRocks.pop();

			var selectedSmallRock:SmallRock = usedSmallRocks[ usedSmallRocks.length - 1 ];
			selectedSmallRock.visible = true;
			selectedSmallRock.alpha = 1;
			selectedSmallRock.x = car.wheelRightGraphics.x + car.wheelRightGraphics.width / 2 + -carDirection * car.wheelRightGraphics.width / 4;
			selectedSmallRock.y = car.wheelRightGraphics.y + car.wheelRightGraphics.height - selectedSmallRock.height;
			selectedSmallRock.startAnim( -carDirection, car.carBodyGraphics.angle * FlxAngle.TO_RAD );
		}
	}

	function releaseSmallRock( target:SmallRock ):Void
	{
		smallRocks.push( target );
		usedSmallRocks.remove( target );
	}

	function checkCoinPickUp():Void
	{
		for ( i in 0...coins.length )
		{
			var coin:Coin = coins[ i ];

			if ( !coin.isCollected && coin.overlaps( car.carBodyGraphics ) )
			{
				coin.collect();
				collectedCoin++;
				gameGui.updateCoinCount( collectedCoin );
			}
		}
	}

	function checkLoose():Void
	{
		if ( !isLost && !isWon && car.isCarCrashed )
		{
			camera.shake( .02, .2 );
			restartRutin();
		}
	}

	function checkWin():Void
	{
		if ( !isLost && !isWon && car.carBodyGraphics.x >= levelData.finishPoint.x )
		{
			restartRutin();
		}
	}

	function restartRutin():Void
	{
		reset();
	}
}