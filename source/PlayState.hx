package;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.util.FlxColor;
import hpp.flixel.display.HPPMovieClip;
import hpp.flixel.util.AssetManager;
import mmx.assets.CarDatas;
import mmx.datatype.BackgroundData;
import mmx.datatype.LevelData;
import mmx.game.terrain.BrushTerrain;
import mmx.game.Car;
import mmx.game.Coin;
import mmx.game.SmallRock;
import mmx.game.constant.CPhysicsValues;
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


class PlayState extends FlxState
{
	inline static var LEVEL_DATA_SCALE:Float = 2;
	
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

	//var gameGui:GameGui;
	/*var controlLeft:Image;
	var controlRight:Image;
	var controlUp:Image;
	var controlDown:Image;*/
	var car:Car;
/*
	var snowModule:SnowModule;

	var startCounter:StartCounter;

	var achievementManager:AchievementManager;

	var terrains:Vector.<Image> = new Vector.<Image>;
	var effects:Vector.<Image> = new Vector.<Image>;

	var crates:Vector.<BaseCrate> = new Vector.<BaseCrate>;
*/
	var backgroundDatas:Array<BackgroundData> = [];

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
	
	override public function create():Void
	{
		super.create();
		
		worldId = 0;
		levelId = 0;
		
		FlxG.scaleMode = new RatioScaleMode();
		
		levelData = LevelUtil.LevelDataFromJson( Assets.getText( "assets/data/level_" + worldId + "_" + levelId + ".json" ) );
		setLevelDataScale();
		
		CarDatas.loadData( Assets.getText( "assets/data/car_datas.json" ) );
		
		AssetManager.loadXMLAtlas( "assets/images/atlas1.png", "assets/images/atlas1.xml" );
		AssetManager.loadXMLAtlas( "assets/images/atlas2.png", "assets/images/atlas2.xml" );
		AssetManager.loadXMLAtlas( "assets/images/atlas3.png", "assets/images/atlas3.xml" );
		AssetManager.loadJsonAtlas( "assets/images/terrain_textures.png", "assets/images/terrain_textures.json" );
		
		build();
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
		
		for ( i in 0...levelData.bridgePoints.length )
		{
			levelData.bridgePoints[i].bridgeAX *= LEVEL_DATA_SCALE;
			levelData.bridgePoints[i].bridgeAY *= LEVEL_DATA_SCALE;
			levelData.bridgePoints[i].bridgeBX *= LEVEL_DATA_SCALE;
			levelData.bridgePoints[i].bridgeBY *= LEVEL_DATA_SCALE;
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
		
		add( container = new FlxSpriteGroup() );
		
		addBackground( 'back_world_' + worldId + '_a00', 100, new FlxPoint( .1, .1 ), -.5 );
		addBackground( 'back_world_' + worldId + '_b00', 200, new FlxPoint( .35, .35 ), -.5 );
		
		FlxNapeSpace.init();
		FlxNapeSpace.space.gravity.setxy( 0, CPhysicsValues.GRAVITY );
		FlxNapeSpace.createWalls( 0, 0, levelData.cameraBounds.width, levelData.cameraBounds.height );
		FlxNapeSpace.drawDebug = true;

		createGroundPhysics();
		createCar();
		createBridges();
		createGroundGraphics();
		
		camera.follow( car.carBodyGraphics, FlxCameraFollowStyle.PLATFORMER, 5 / FlxG.updateFramerate );
		camera.targetOffset.set( 200 );
		camera.setScrollBoundsRect( levelData.cameraBounds.x, levelData.cameraBounds.y, levelData.cameraBounds.width, levelData.cameraBounds.height );
		
		createCoins();
		createSmallRocks();
		createGameObjects();
		
/*
		this.addLibraryElements();

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

		switch( _worldID )
		{
			case 1:
				this._snowModule = new SnowModule();
				this.addChild( this._snowModule.getView() );
				break;
		}

		// add gui
		addChild( _gameGui = new GameGui( _levelID, _worldID ) );
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
		collectedCoin = 0;
		collectedExtraCoins = 0;
		countOfFrontFlip = 0;
		countOfBackFlip = 0;
		countOfNiceAirTime = 0;
		countOfNiceWheelie = 0;
		
		for( i in 0...coins.length )
		{
			coins[ i ].reset( levelData.starPoints[ i ].x, levelData.starPoints[ i ].y );
		}
		
		for( i in 0...smallRocks.length )
		{
			smallRocks[ i ].reset( 0, 0 );
		}
		
		car.teleportTo( levelData.startPoint.x, levelData.startPoint.y );
		
		camera.bgColor = FlxColor.BLACK;
		camera.focusOn( levelData.startPoint );
		
		/*
		
		switch( _worldID )
		{
			case 1:
				_car.wheelLeft.SetLinearDamping( _car.damping + .3 );
				_car.wheelRight.SetLinearDamping( _car.damping + .3 );
				break;
		}

		// Reset camera
		_lastCameraStepOffset.setTo( 0, 0 );
		updateCamera( false );

		this.resetCrates();

		// Start level
		onUpdate( new Event( Event.ENTER_FRAME ) );

		this._gameGui.showStartGamePanel( exit );
		this._gameGui.enable();*/
	}
	
	function createGroundGraphics():Void
	{
		container.add( terrainContainer = new FlxSpriteGroup() );
		
		var generatedTerrain:BrushTerrain = new BrushTerrain(
			levelData.cameraBounds,
			levelData.groundPoints,
			AssetManager.getGraphic( "terrain_ground_texture_00000" ),
			AssetManager.getGraphic( "terrain_fill_texture_00000" ),
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
		filter.collisionGroup = CPhysicsValues.GROUND_FILTER_CATEGORY;
		filter.collisionMask = CPhysicsValues.GROUND_FILTER_MASK;
		
		for( i in 0...levelData.groundPoints.length - 1 )
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
		for( i in 0...levelData.bridgePoints.length )
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
		filter.collisionGroup = CPhysicsValues.BRIDGE_FILTER_CATEGORY;
		filter.collisionMask = CPhysicsValues.BRIDGE_FILTER_MASK;
			
		var bridgeAngle:Float = Math.atan2( pointB.y - pointA.y, pointB.x - pointA.x );
		var bridgeElementWidth:UInt = 60;
		var bridgeElementHeight:UInt = 30;
		var bridgeDistance:Float = pointA.distanceTo( pointB );
		var pieces:UInt = Math.floor( bridgeDistance / bridgeElementWidth ) + 1;

		if( bridgeDistance % bridgeElementWidth == 0 )
		{
			pieces++;
		}

		bridgeBlocks.push( [] );
		bridgeBodies.push( [] );

		for( i in 0...pieces )
		{
			var isLockedBridgeElement:Bool = false;
			if( i == 0 || i == cast( pieces - 1 ) )
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
			
			var bridgeBlock:FlxSprite = AssetManager.getSprite( "bridge" );
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
		car = new Car( levelData.startPoint.x, levelData.startPoint.y, CarDatas.getData( 0 ), 1, CPhysicsValues.CAR_FILTER_CATEGORY, CPhysicsValues.CAR_FILTER_MASK );
		container.add( car );
	}
	
	function addBackground( assetId:String, baseYOffset:Float, easing:FlxPoint, xOverlap:Float ):Void
	{
		var backgroundData:BackgroundData = {
			easing: easing,
			container: new FlxSpriteGroup(),
			elements: []
		};
		backgroundDatas.push( backgroundData );
		
		container.add( backgroundData.container );
		
		for( i in 0...5 )
		{
			var backgroundPiece:HPPMovieClip = AssetManager.getMovieClip( assetId );
			backgroundData.container.add( backgroundPiece );
			backgroundData.elements.push( backgroundPiece );
			
			backgroundPiece.gotoAndStop( i == 4 ? 0 : i );
			backgroundPiece.x = i * ( backgroundPiece.width + xOverlap );
			backgroundPiece.y = baseYOffset;
		}
	}
	
	function createCoins():Void
	{
		coins = [];
		
		container.add( coinContainer = new FlxSpriteGroup() );
		
		for( i in 0...levelData.starPoints.length )
		{
			coins.push( cast coinContainer.add( new Coin( levelData.starPoints[ i ].x, levelData.starPoints[ i ].y ) ) );
		}
	}
	
	function createSmallRocks():Void
	{
		smallRocks = [];
		usedSmallRocks = [];
		
		for( i in 0...30 )
		{
			var smallRock:SmallRock = new SmallRock( "small_rock_" + worldId + "_" + Math.floor( Math.random() * 3 + 1 ), releaseSmallRock );
			container.add( smallRock );
			smallRocks.push( smallRock );
		}
	}
	
	function createGameObjects():Void
	{
		if ( levelData.gameObjects != null )
		{
			for( i in 0...levelData.gameObjects.length )
			{
				var selectedObject:FlxSprite = AssetManager.getSprite( levelData.gameObjects[ i ].texture );
				container.add( selectedObject );
				
				selectedObject.origin.set( levelData.gameObjects[ i ].pivotX, levelData.gameObjects[ i ].pivotY );
				selectedObject.setPosition( levelData.gameObjects[ i ].x, levelData.gameObjects[ i ].y );
				selectedObject.angle = levelData.gameObjects[ i ].rotation;
				
				gameObjects.push( selectedObject );
			}
		}
	}
	
	override public function update( elapsed:Float ):Void
	{
		super.update( elapsed );
		
		car.accelerateToRight();
		
		//camera.zoom = .8 + Math.max( 700 - car.carBodyPhysics.velocity.x, 0 ) / 700 * .2;
		
		lastCameraStepOffset.set( camera.scroll.x - lastCameraStepOffset.x, camera.scroll.y - lastCameraStepOffset.y );
		updateBackgrounds();
		lastCameraStepOffset.set( camera.scroll.x, camera.scroll.y );
		
		updateBridges();
		updateSmallRocks();
		checkCoinPickUp();
		checkLoose();
		checkWin();
	}
	
	function updateBackgrounds():Void
	{
		for( i in 0...backgroundDatas.length )
		{
			var backgroundData:BackgroundData = backgroundDatas[i];

			backgroundData.container.x -= lastCameraStepOffset.x * backgroundData.easing.x;

			while( backgroundData.container.x > 0 + camera.scroll.x )
			{
				for( j in 0...backgroundData.elements.length )
				{
					backgroundData.elements[j].currentFrame = backgroundData.elements[j].currentFrame == 0 ? backgroundData.elements[j].numFrames - 1 : backgroundData.elements[j].currentFrame - 1;
				}
				backgroundData.container.x -= backgroundData.elements[ 0 ].width;
			}

			while( backgroundData.container.x < -backgroundData.elements[ 0 ].width + camera.scroll.x )
			{
				for( j in 0...backgroundData.elements.length )
				{
					backgroundData.elements[j].currentFrame = ( backgroundData.elements[j] .currentFrame == cast( backgroundData.elements[j].numFrames - 1 ) ) ? 0 : backgroundData.elements[j].currentFrame + 1;
				}
				backgroundData.container.x += backgroundData.elements[ 0 ].width;
			}

			backgroundData.container.y = 640 - backgroundData.container.height + container.y * backgroundData.easing.y;
		}
	}
	
	function updateBridges():Void
	{
		for( i in 0...bridgeBlocks.length )
		{
			for( j in 0...bridgeBlocks[i].length )
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
		var leftAngularVelocity:Float = Math.abs( car.wheelRightPhysics.angularVel );
		var rightAngularVelocity:Float = Math.abs( car.wheelLeftPhysics.angularVel );
		var carDirection:Int = car.wheelLeftPhysics.velocity.x >= 0 ? 1 : -1;
		
		if( !car.leftWheelOnAir /*&& ( _up || _down )*/ && smallRocks.length > 0 && leftAngularVelocity > 5 && Math.random() > .8 )
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
		
		if( !car.rightWheelOnAir /*&& ( _up || _down )*/ && smallRocks.length > 0 && rightAngularVelocity > 5 && Math.random() > .8 )
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
		for( i in 0...coins.length )
		{
			var coin:Coin = coins[ i ];
			
			if( !coin.isCollected && coin.overlaps( car.carBodyGraphics ) )
			{
				coin.collect();
			}
		}
	}
	
	function checkLoose():Void
	{
		if( !isLost && !isWon && car.isCarCrashed )
		{
			camera.shake( .02, .2 );
			reset();
		}
	}
	
	function checkWin():Void
	{
		if( !isLost && !isWon && car.carBodyGraphics.x >= levelData.finishPoint.x )
		{
			reset();
		}
	}
	
	function restartRutin():Void
	{
		reset();
	}
}