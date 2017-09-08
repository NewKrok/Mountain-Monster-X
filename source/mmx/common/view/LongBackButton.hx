package mmx.common.view;

import flixel.math.FlxPoint;
import hpp.flixel.ui.HPPButton;
import hpp.flixel.util.HPPAssetManager;
import mmx.assets.Fonts;

/**
 * ...
 * @author Krisztian Somoracz
 */
class LongBackButton extends HPPButton
{
	public function new( callBack:HPPButton->Void = null )
	{
		super( "Back", callBack );
		
		label.font = Fonts.DEFAULT_FONT;
		labelSize = 25;
		labelOffsets = [ new FlxPoint( 0, -7 ), new FlxPoint( 0, -7 ), new FlxPoint( 0, -7 ) ];
		loadGraphic( HPPAssetManager.getGraphic( "base_button" ) );
		overScale = .95;
	}
}