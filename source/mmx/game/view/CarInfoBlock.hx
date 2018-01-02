package mmx.game.view;

import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import hpp.flixel.ui.HPPHUIBox;
import hpp.flixel.ui.PlaceHolder;
import hpp.flixel.util.HPPAssetManager;
import hpp.ui.VAlign;
import mmx.assets.Fonts;
import mmx.datatype.CarData;
import openfl.display.BitmapData;
import openfl.geom.Matrix;

/**
 * ...
 * @author Krisztian Somoracz
 */
class CarInfoBlock extends HPPHUIBox
{
	public function new(carData:CarData)
	{
		super(10, VAlign.TOP);

		createCarName(carData.name);
		add(new PlaceHolder(10, 1));
		createCarPreview(carData.graphicId);
	}

	function createCarName(carName:String)
	{
		var checkboxLabel:FlxText = new FlxText(0, 0, 0, carName, 21);
		checkboxLabel.color = FlxColor.YELLOW;
		checkboxLabel.alignment = "left";
		checkboxLabel.font = Fonts.AACHEN_MEDIUM;
		add(checkboxLabel);
	}

	function createCarPreview(graphicId:UInt):Void
	{
		var preview:FlxSprite = HPPAssetManager.getSprite("car_info_car_" + graphicId);

		var previewScale:Float = .75;
		var scaleMatrix:Matrix = new Matrix();
		scaleMatrix.scale(previewScale, previewScale);
		var previewPic:BitmapData = new BitmapData(cast preview.width * previewScale, cast preview.height * previewScale, true, 0x00);
		previewPic.draw(preview.framePixels, scaleMatrix);

		var container:FlxSprite = new FlxSprite();
		container.loadGraphic(previewPic);

		add(container);
	}
}