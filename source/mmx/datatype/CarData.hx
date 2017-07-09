package mmx.datatype;

/**
 * ...
 * @author Krisztian Somoracz
 */
typedef CarData =
{
	var name( default, default ):String;
	
	var id( default, default ):UInt;
	var graphicId( default, default ):UInt;
	
	var speed( default, default ):Float;
	var rotation( default, default ):Float;
	var damping( default, default ):Float;
	
	@:optional var starRequired( default, default ):UInt;
	@:optional var carBodyXOffset( default, default ):UInt;
	@:optional var carBodyYOffset( default, default ):UInt;
	@:optional var carBodyGraphicXOffset( default, default ):UInt;
	@:optional var carBodyGraphicYOffset( default, default ):UInt;
	@:optional var unlockInformation( default, default ):String;
}