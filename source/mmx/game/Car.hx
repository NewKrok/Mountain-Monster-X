package mmx.game;

import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSpace;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import hpp.flixel.util.AssetManager;
import nape.constraint.DistanceJoint;
import nape.constraint.PivotJoint;
import nape.constraint.WeldJoint;
import nape.dynamics.InteractionFilter;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;

import mmx.datatype.CarData;

/**
 * ...
 * @author Krisztian Somoracz
 */
class Car extends FlxSpriteGroup
{	
	var graphicJoinHertz:Float = 20;
	
	var firstWheelXOffset:Float = 55;
	var firstWheelYOffset:Float = 35;
	var firstWheelRadius:Float = 20;
	var backWheelXOffset:Float = -52;
	var backWheelYOffset:Float = 35;
	var backWheelRadius:Float = 20;
	var bodyWidth:Float = 150;
	var bodyHeight:Float = 30;
	var hitAreaHeight:Float = 10;
	
	var carData:CarData;
	
	public var carBodyGraphics:FlxSprite;
	public var wheelRightGraphics:FlxSprite;
	public var wheelLeftGraphics:FlxSprite;
	
	var hitArea:Body;
	public var carBodyPhysics:Body;
	public var wheelRightPhysics:Body;
	public var wheelLeftPhysics:Body;
	
	var direction:Int = 1;
	
	public function new( x:Float, y:Float, carData:CarData, scale:Float = 1, filterCategory:UInt = 0, filterMask:UInt = 0 )
	{
		super();
		
		this.carData = carData;
		
		firstWheelXOffset += Math.isNaN( carData.carBodyXOffset ) ? 0 : carData.carBodyXOffset;
		firstWheelYOffset += Math.isNaN( carData.carBodyYOffset ) ? 0 : carData.carBodyYOffset;
		backWheelXOffset += Math.isNaN( carData.carBodyXOffset ) ? 0 : carData.carBodyXOffset;
		backWheelYOffset += Math.isNaN( carData.carBodyYOffset ) ? 0 : carData.carBodyYOffset;
		
		firstWheelXOffset *= scale;
		firstWheelYOffset *= scale;
		firstWheelRadius *= scale;
		backWheelXOffset *= scale;
		backWheelYOffset *= scale;
		backWheelRadius *= scale;
		bodyWidth *= scale;
		bodyHeight *= scale;
		hitAreaHeight *= scale;
		
		buildGraphics();
		buildPhysics( x, y, filterCategory, filterMask );
		
		carBodyGraphics.scale = new FlxPoint( scale, scale );
		wheelRightGraphics.scale = new FlxPoint( scale, scale );
		wheelLeftGraphics.scale = new FlxPoint( scale, scale );
	}
	
	function buildGraphics():Void
	{
		add( carBodyGraphics = AssetManager.getSprite( "car_body_" + carData.graphicId ) );
		carBodyGraphics.antialiasing = true;
		
		add( wheelRightGraphics = AssetManager.getSprite( "wheel_" + carData.graphicId ) );
		wheelRightGraphics.antialiasing = true;
		
		add( wheelLeftGraphics = AssetManager.getSprite( "wheel_" + carData.graphicId ) );
		wheelLeftGraphics.antialiasing = true;
	}
	
	function buildPhysics( x:Float, y:Float, filterCategory:UInt = 0, filterMask:UInt = 0 ):Void
	{
		var filter:InteractionFilter = new InteractionFilter();
		filter.collisionGroup = filterCategory;
		filter.collisionMask = filterMask;
		
		wheelRightPhysics = new Body();
		wheelRightPhysics.shapes.add( new Circle( firstWheelRadius ) );
		wheelRightPhysics.setShapeMaterials( new Material( .5, .5, .5, 2, 0.001 ) );
		wheelRightPhysics.setShapeFilters( filter );
		wheelRightPhysics.position.x = x + firstWheelXOffset;
		wheelRightPhysics.position.y = y + firstWheelYOffset;
		wheelRightPhysics.space = FlxNapeSpace.space;
		
		wheelLeftPhysics = new Body();
		wheelLeftPhysics.shapes.add( new Circle( firstWheelRadius ) );
		wheelLeftPhysics.setShapeMaterials( new Material( .5, .5, .5, 2, 0.001 ) );
		wheelLeftPhysics.setShapeFilters( filter );
		wheelLeftPhysics.position.x = x + backWheelXOffset;
		wheelLeftPhysics.position.y = y + backWheelYOffset;
		wheelLeftPhysics.space = FlxNapeSpace.space;
		
		carBodyPhysics = new Body();
		carBodyPhysics.shapes.add( new Polygon( Polygon.box( bodyWidth, bodyHeight ) ) );
		carBodyPhysics.setShapeMaterials( new Material( .5, .5, .5, 2, 0.001 ) );
		carBodyPhysics.setShapeFilters( filter );
		carBodyPhysics.position.x = x;
		carBodyPhysics.position.y = y;
		carBodyPhysics.space = FlxNapeSpace.space;
		
		hitArea = new Body();
		hitArea.shapes.add( new Polygon( Polygon.box( bodyWidth * .7, hitAreaHeight ) ) );
		hitArea.setShapeMaterials( new Material( .5, .5, .5, 2, 0.001 ) );
		hitArea.space = FlxNapeSpace.space;
		
		var hitAreaAnchor:Vec2 = hitArea.localCOM.copy();
		hitAreaAnchor.y += hitAreaHeight;
		var hitJoin:WeldJoint = new WeldJoint( carBodyPhysics, hitArea, carBodyPhysics.localCOM, hitAreaAnchor );
		hitJoin.space = FlxNapeSpace.space;
		
		var bodyLeftAnchor:Vec2 = new Vec2( firstWheelXOffset, firstWheelYOffset );
		var pivotJointLeftLeftWheel:PivotJoint = new PivotJoint( wheelLeftPhysics, carBodyPhysics, wheelLeftPhysics.localCOM, bodyLeftAnchor );
		pivotJointLeftLeftWheel.damping = 1;
		pivotJointLeftLeftWheel.frequency = graphicJoinHertz;
		pivotJointLeftLeftWheel.space = FlxNapeSpace.space;
		
		var bodyRightAnchor:Vec2 = new Vec2( backWheelXOffset, backWheelYOffset );
		var pivotJointRightRightWheel:PivotJoint = new PivotJoint( wheelRightPhysics, carBodyPhysics, wheelRightPhysics.localCOM, bodyRightAnchor );
		pivotJointRightRightWheel.damping = 1;
		pivotJointRightRightWheel.frequency = graphicJoinHertz;
		pivotJointRightRightWheel.space = FlxNapeSpace.space;
	}
	
	public function getMidXPosition():Float
	{
		return carBodyGraphics.x;
	}
	
	public function getMidYPosition():Float
	{
		return carBodyGraphics.y;
	}
	
	override public function update( elapsed:Float ):Void
	{
		super.update( elapsed );
		
		carBodyGraphics.x = carBodyPhysics.position.x - carBodyGraphics.origin.x;
		carBodyGraphics.y = carBodyPhysics.position.y - carBodyGraphics.origin.y;
		carBodyGraphics.angle = carBodyPhysics.rotation * FlxAngle.TO_DEG;
		
		wheelRightGraphics.x = wheelRightPhysics.position.x - wheelRightGraphics.origin.x;
		wheelRightGraphics.y = wheelRightPhysics.position.y - wheelRightGraphics.origin.y;
		wheelRightGraphics.angle = wheelRightPhysics.rotation * FlxAngle.TO_DEG;
		
		wheelLeftGraphics.x = wheelLeftPhysics.position.x - wheelLeftGraphics.origin.x;
		wheelLeftGraphics.y = wheelLeftPhysics.position.y - wheelLeftGraphics.origin.y;
		wheelLeftGraphics.angle = wheelLeftPhysics.rotation * FlxAngle.TO_DEG;
	}
	
	public function accelerateToLeft():Void
	{
		direction = -1;

		wheelLeftPhysics.applyAngularImpulse( -carData.speed / 2 );
		wheelRightPhysics.applyAngularImpulse( -carData.speed / 2 );
	}

	public function accelerateToRight():Void
	{
		direction = 1;
		
		wheelLeftPhysics.applyAngularImpulse( carData.speed );
		wheelRightPhysics.applyAngularImpulse( carData.speed );
	}

	public function rotateLeft():Void
	{
		carBodyPhysics.applyAngularImpulse( -carData.rotation );
	}

	public function rotateRight():Void
	{
		carBodyPhysics.applyAngularImpulse( carData.rotation );
	}
}