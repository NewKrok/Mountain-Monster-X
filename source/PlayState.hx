package;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.tile.FlxTileblock;
import hpp.flixel.display.FPPMovieClip;
import mmx.assets.CarDatas;
import mmx.datatype.BackgroundData;
import mmx.datatype.CarData;
import mmx.datatype.LevelData;
import mmx.game.Car;
import mmx.game.constant.CPhysicsValues;
import mmx.util.LevelUtil;
import hpp.flixel.util.AssetManager;
import nape.dynamics.InteractionFilter;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;

import openfl.Assets;

class PlayState extends FlxState
{
	var container:FlxSpriteGroup;
	var terrainContainer:FlxSpriteGroup;
	var coinContainer:FlxSpriteGroup;
	var libraryElementContainer:FlxSpriteGroup;
	
	var lastCameraStepOffset:FlxPoint;
	
	var groundBodies:Array<Body>;
	var groundBlocks:Array<FlxSprite>;

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

	var smallRocks:Vector.<Image> = new Vector.<Image>;
	var usedSmallRocks:Vector.<Image> = new Vector.<Image>;
	var gameObjects:Vector.<Image> = new Vector.<Image>;
	var terrains:Vector.<Image> = new Vector.<Image>;
	var effects:Vector.<Image> = new Vector.<Image>;

	var coins:Vector.<Coin> = new Vector.<Coin>;
	var crates:Vector.<BaseCrate> = new Vector.<BaseCrate>;
*/
	var backgroundDatas:Array<BackgroundData> = [];

	var levelData:LevelData;
	var levelId:UInt;
	var worldId:UInt;

	// controllers
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
		levelId = 1;
		
		FlxG.scaleMode = new RatioScaleMode();
		
		levelData = LevelUtil.LevelDataFromJson( Assets.getText( "assets/data/level_" + worldId + "_" + levelId + ".json" ) );
		
		CarDatas.loadData( Assets.getText( "assets/data/car_datas.json" ) );
		
		AssetManager.loadAtlas( "assets/images/atlas1.png", "assets/images/atlas1.xml" );
		AssetManager.loadAtlas( "assets/images/atlas2.png", "assets/images/atlas2.xml" );
		AssetManager.loadAtlas( "assets/images/atlas3.png", "assets/images/atlas3.xml" );
		
		build();
	}
	
	function build():Void
	{
		lastCameraStepOffset = new FlxPoint();
		
		add( container = new FlxSpriteGroup() );
		
		addBackground( 'back_world_' + worldId + '_a00', 50, new FlxPoint( .1, .1 ), -.5 );
		addBackground( 'back_world_' + worldId + '_b00', 100, new FlxPoint( .35, .35 ), -.5 );
		
		FlxNapeSpace.init();
		FlxNapeSpace.space.gravity.setxy( 0, CPhysicsValues.GRAVITY );
		FlxNapeSpace.drawDebug = true;
		
		createGroundPhysics();
		
		car = new Car( levelData.startPoint.x + 200, levelData.startPoint.y - 150, CarDatas.getData( 0 ), CPhysicsValues.CAR_FILTER_CATEGORY, CPhysicsValues.CAR_FILTER_MASK );
		container.add( car );
		
		camera.follow( car.carBodyGraphics, FlxCameraFollowStyle.PLATFORMER, 5 / FlxG.updateFramerate );
/*

		// generate small rocks
		for( i = 0; i < 30; i++ )
		{
			_smallRocks.push( _container.addChild( new Image( StaticAssetManager.instance.getTexture( "small_rock_" + _worldID + '_' + Math.floor( Math.random() * 3 + 1 ) ) ) as Image ) );
			_smallRocks[ _smallRocks.length - 1 ].visible = false;
			_smallRocks[ _smallRocks.length - 1 ].pivotX = _smallRocks[ _smallRocks.length - 1 ].width / 2;
			_smallRocks[ _smallRocks.length - 1 ].pivotY = _smallRocks[ _smallRocks.length - 1 ].height / 2;
			_smallRocks[ _smallRocks.length - 1 ].touchable = false;
		}
		// create game objects
		for( i = 0; i < _levelData.gameObjects.length; i++ )
		{
			_gameObjects.push( _container.addChild( new Image( StaticAssetManager.instance.getTexture( _levelData.gameObjects[ i ].texture ) ) as Image ) );
			_gameObjects[ _gameObjects.length - 1 ].pivotX = _levelData.gameObjects[ i ].pivotX;
			_gameObjects[ _gameObjects.length - 1 ].pivotY = _levelData.gameObjects[ i ].pivotY;
			_gameObjects[ _gameObjects.length - 1 ].x = _levelData.gameObjects[ i ].x;
			_gameObjects[ _gameObjects.length - 1 ].y = _levelData.gameObjects[ i ].y;
			_gameObjects[ _gameObjects.length - 1 ].rotation = _levelData.gameObjects[ i ].rotation;
			_gameObjects[ _gameObjects.length - 1 ].touchable = false;
		}

		// process map terrain
		_mapElements.push( createBox( "WALL", 0, 0, 10, 1200, false, true, 1, 1, 0 ) );
		_mapElements.push( createBox( "WALL", _levelData.maxWidth, 0, 10, 1200, false, true, 1, 1, 0 ) );

		this.createBridges();
		this.addLibraryElements();

		var terrainGroundTexture:BitmapData = TerrainTextures.getLevelPackTerrainGroundTexture( _worldID );
		var terrainFillTexture:BitmapData = TerrainTextures.getLevelPackTerrainFillTexture( _worldID );

		try
		{
			// Create world pieces
			_container.addChild( _terrainContainer = new Sprite );
			_terrainContainer.touchable = false;
			var generatedTerrain:BrushPattern = new BrushPattern( _levelData.groundPoints, terrainGroundTexture, terrainFillTexture, 64, 24 );
			var maxBlockSize:uint = 2048;
			var pieces:uint = Math.ceil( generatedTerrain.width / maxBlockSize );
			for( var i:uint = 0; i < pieces; i++ )
			{
				var tmpBitmapData:BitmapData = new BitmapData( maxBlockSize, maxBlockSize, true, 0x60 );
				var offsetMatrix:Matrix = new Matrix;
				offsetMatrix.tx = -i * maxBlockSize;
				tmpBitmapData.draw( generatedTerrain, offsetMatrix );
				_terrains.push( new Image( Texture.fromBitmap( new Bitmap( tmpBitmapData ), false, false, 2 ) ) );
				_terrains[ i ].x = i * maxBlockSize / 2;
				_terrains[ i ].touchable = false;
				_terrainContainer.addChild( _terrains[ i ] );
				tmpBitmapData.dispose();
				tmpBitmapData = null;
			}
		}catch( e:Error )
		{
			if( MountainMonsterIOSMain.LOG_ENABLED )
			{
				LogModule.add( 'Terrain generation error: ' + e.getStackTrace() );
			}

			this.dispatchEvent( new GameEvent( GameEvent.RESOURCE_LIMIT_ERROR ) );
			return;
		}

		terrainGroundTexture.dispose();
		terrainGroundTexture = null;
		terrainFillTexture.dispose();
		terrainFillTexture = null;

		generatedTerrain.dispose();
		generatedTerrain = null;

		// Add coins
		_container.addChild( _coinContainer = new Sprite );
		for( i = 0; i < _levelData.coinPoints.length; i++ )
		{
			addCoinToWorld( _levelData.coinPoints[ i ].x, _levelData.coinPoints[ i ].y );
		}

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

		reset();*/
	}
	
	function createGroundPhysics():Void
	{
		groundBodies = [];
		groundBlocks = [];

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
			
			var block = AssetManager.getSprite( "car_info_car_0" );
			block.x = body.position.x - block.origin.x;
			block.y = body.position.y - block.origin.y;
			block.angle = body.rotation * FlxAngle.TO_DEG;
			container.add( block );
			groundBlocks.push( block );
		}
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
			var backgroundPiece:FPPMovieClip = AssetManager.getMovieClip( assetId );
			backgroundData.container.add( backgroundPiece );
			backgroundData.elements.push( backgroundPiece );
			
			backgroundPiece.gotoAndStop( i == 4 ? 0 : i );
			backgroundPiece.x = i * ( backgroundPiece.width + xOverlap );
			backgroundPiece.y = baseYOffset;
		}
	}
	
	override public function update( elapsed:Float ):Void
	{
		super.update( elapsed );
		
		car.accelerateToRight();
		
		camera.zoom = .8 + Math.max( 700 - car.carBodyPhysics.velocity.x, 0 ) / 700 * .2;
		
		/*lastCameraStepOffset.set( camera.scroll.x - lastCameraStepOffset.x, camera.scroll.y - lastCameraStepOffset.y );
		updateBackgrounds();
		lastCameraStepOffset.set( camera.scroll.x, camera.scroll.y );*/
	}
	
	function updateBackgrounds():Void
	{
		for( i in 0...backgroundDatas.length )
		{
			var backgroundData:BackgroundData = backgroundDatas[i];

			backgroundData.container.x -= lastCameraStepOffset.x * backgroundData.easing.x;

			while( backgroundData.container.x > 0 )
			{
				for( j in 0...backgroundData.elements.length )
				{
					backgroundData.elements[j].currentFrame = backgroundData.elements[j].currentFrame == 0 ? backgroundData.elements[j].numFrames - 1 : backgroundData.elements[j].currentFrame - 1;
				}
				backgroundData.container.x -= backgroundData.elements[ 0 ].width;
			}

			while( backgroundData.container.x < -backgroundData.elements[ 0 ].width )
			{
				for( j in 0...backgroundData.elements.length )
				{
					backgroundData.elements[j].currentFrame = backgroundData.elements[j] .currentFrame == backgroundData.elements[j].numFrames - 1 ? 0 : backgroundData.elements[j].currentFrame + 1;
				}
				backgroundData.container.x += backgroundData.elements[ 0 ].width;
			}

			backgroundData.container.y = 640 - backgroundData.container.height + container.y * backgroundData.easing.y;
		}
	}
}