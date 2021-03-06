package mmx.game.constant;
import nape.phys.Material;

/**
 * ...
 * @author Krisztian Somoracz
 */
class CPhysicsValue 
{
	public static inline var GRAVITY:UInt = 600;
	public static inline var STEP:Float = 1 / 60;
	
	public static inline var CAR_FILTER_CATEGORY:UInt = 2;
	public static inline var CAR_FILTER_MASK:UInt = 1;
	public static inline var GROUND_FILTER_CATEGORY:UInt = 1;
	public static inline var GROUND_FILTER_MASK:UInt = 2;
	public static inline var BRIDGE_FILTER_CATEGORY:UInt = 1;
	public static inline var BRIDGE_FILTER_MASK:UInt = 2;
	public static inline var CRATE_FILTER_CATEGORY:UInt = 3;
	public static inline var CRATE_FILTER_MASK:UInt = 3;
	
	public static var MATERIAL_NORMAL_GROUND( get, never ):Material;
	public static var MATERIAL_SNOWY_GROUND( get, never ):Material;
	public static var MATERIAL_BRIDGE( get, never ):Material;
	public static var MATERIAL_WHEEL( get, never ):Material;
	
	static function get_MATERIAL_NORMAL_GROUND():Material { return Material.wood(); }
	static function get_MATERIAL_SNOWY_GROUND():Material { return new Material(0.2, 0.04, 0.12, 5, 0.0005); } // Based on wood material
	static function get_MATERIAL_BRIDGE():Material { return Material.wood(); }
	static function get_MATERIAL_WHEEL():Material { return new Material(0.8, 12, 12, 1.5, 0.01); } // Based on rubber material
}