package hpp.flixel.ui;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween;

/**
 * ...
 * @author Krisztian Somoracz
 */
class HPPScrollContainer extends FlxSpriteGroup
{
	public static var MINIMUM_MOUSE_MOVE_TO_CHANGE_PAGE:Float = 200;
	public static var MAX_OVER_DRAG_SIZE:Float = 200;
	public static var CHANGE_PAGE_MAX_SPEED:Float = .6;
	public static var CHANGE_PAGE_EASING_TYPE:Float->Float = FlxEase.quadOut;
	
	var direction:ScrollDirection;
	var snapToPages:Bool;
	var pageHeight:Float;
	var pageWidth:Float;
	
	var isTouchDragActivated:Bool;
	var touchStartPosition:FlxPoint;
	var containerTouchStartPosition:FlxPoint;
	
	var tween:VarTween;
	var pageIndex:UInt = 0;
	
	public function new( pageWidth:Float, pageHeight:Float, direction:ScrollDirection = ScrollDirection.HORIZONTAL, snapToPages:Bool = false ) 
	{
		super();
		
		this.pageWidth = pageWidth;
		this.pageHeight = pageHeight;
		this.direction = direction;
		this.snapToPages = snapToPages;
		
		build();
	}
	
	function build() 
	{
	}
	
	override public function update( elapsed:Float ):Void 
	{
		super.update( elapsed );
		
		if ( FlxG.mouse.pressed )
		{
			if ( !isTouchDragActivated )
			{
				touchStartPosition = new FlxPoint( FlxG.mouse.getPosition().x, FlxG.mouse.getPosition().y );
				containerTouchStartPosition = new FlxPoint( x, y );
			}
			
			isTouchDragActivated = true;
			
			if ( direction == ScrollDirection.HORIZONTAL )
			{
				x = containerTouchStartPosition.x + FlxG.mouse.getPosition().x - touchStartPosition.x;
			}
			else
			{
				y = containerTouchStartPosition.y + FlxG.mouse.getPosition().y - touchStartPosition.y;
			}
			
			normalizePosition();
		}
		else if ( FlxG.mouse.justReleased && snapToPages )
		{
			var dragDistance:Float = containerTouchStartPosition.distanceTo( new FlxPoint( x, y ) );
			
			if ( dragDistance > MINIMUM_MOUSE_MOVE_TO_CHANGE_PAGE && containerTouchStartPosition.x > x && pageIndex < Math.ceil( width / pageWidth ) - 1 )
			{
				moveToPage( pageIndex + 1 );
			} else if ( dragDistance >= MINIMUM_MOUSE_MOVE_TO_CHANGE_PAGE && containerTouchStartPosition.x < x && pageIndex > 0 )
			{
				moveToPage( pageIndex - 1 );
			}
			else
			{
				moveToPage( pageIndex );
			}
		}
		else
		{
			isTouchDragActivated = false;
		}
	}
	
	function normalizePosition() 
	{
		if ( direction == ScrollDirection.HORIZONTAL )
		{
			x = Math.min( x, MAX_OVER_DRAG_SIZE );
			x = Math.max( x, -width + pageWidth - MAX_OVER_DRAG_SIZE );
		}
		else
		{
			y = Math.min( y, MAX_OVER_DRAG_SIZE );
			y = Math.max( y, -height + pageHeight - MAX_OVER_DRAG_SIZE );
		}
	}
	
	function moveToPage( pageIndex:UInt ) 
	{
		this.pageIndex = pageIndex;
		
		disposeTween();
		
		var speedBasedOnDistance:Float;
		var tweenValues:Dynamic;
		if ( direction == ScrollDirection.HORIZONTAL )
		{
			tweenValues = { x: pageIndex * -pageWidth };
			speedBasedOnDistance = Math.abs( ( x - pageIndex * -pageWidth ) / pageWidth * CHANGE_PAGE_MAX_SPEED );
		}
		else
		{
			tweenValues = { y: pageIndex * -pageHeight };
			speedBasedOnDistance = Math.abs( ( y - pageIndex * -pageHeight ) / pageHeight * CHANGE_PAGE_MAX_SPEED );
		}
		
		tween = FlxTween.tween( 
			this,
			tweenValues,
			speedBasedOnDistance,
			{ ease: CHANGE_PAGE_EASING_TYPE }
		);
	}
	
	function disposeTween():Void
	{
		if ( tween != null )
		{
			tween.cancel();
			tween.destroy();
			tween = null;
		}
	}
}

@:enum
abstract ScrollDirection( String ) {
	var HORIZONTAL = "horizontal";
	var VERTICAL = "vertical";
}