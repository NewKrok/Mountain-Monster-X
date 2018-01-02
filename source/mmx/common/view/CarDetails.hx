package mmx.common.view;

import hpp.flixel.ui.HPPVUIBox;
import hpp.ui.HAlign;
import mmx.assets.CarDatas;
import mmx.datatype.CarData;

/**
 * ...
 * @author Krisztian Somoracz
 */
class CarDetails extends HPPVUIBox
{
	public function new(carData:CarData)
	{
		super(5, HAlign.RIGHT);

		add(new CarProperty("SPEED", carData.speed, CarDatas.MIN_SPEED, CarDatas.MAX_SPEED));
		add(new CarProperty("HANDLING", carData.rotation, CarDatas.MIN_ROTATION, CarDatas.MAX_ROTATION));
		add(new CarProperty("WHEEL", carData.elasticity, CarDatas.MAX_ELASTICITY, CarDatas.MIN_ELASTICITY, true));
	}
}