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
	var direction:ScrollDirection;
	var snapToPages:Bool;
	var pageHeight:Float;
	var pageWidth:Float;
	
	var isTouchDragActivated:Bool;
	var touchStartPosition:FlxPoint;
	var containerTouchStartPosition:FlxPoint;
	
	var tween:VarTween;
	
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
			moveToPage( Math.round( -x / pageWidth ) );
			FlxG.mouse.
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
			x = Math.min( x, 0 );
			x = Math.max( x, -width + pageWidth );
		}
		else
		{
			y = Math.min( y, 0 );
			y = Math.max( y, -height + pageHeight );
		}
	}
	
	function moveToPage( pageIndex:UInt ) 
	{
		disposeTween();
		
		var tweenValues:Dynamic;
		if ( direction == ScrollDirection.HORIZONTAL )
		{
			tweenValues = { x: pageIndex * -pageWidth };
		}
		else
		{
			tweenValues = { y: pageIndex * -pageHeight };
		}
		tween = FlxTween.tween( 
			this,
			tweenValues,
			.4,
			{ ease: FlxEase.expoOut }
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