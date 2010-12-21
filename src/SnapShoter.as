package {
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	/**
	 * @author tamt
	 */
	public class SnapShoter {

		public static function snap(dp : DisplayObject, transparent:Boolean = true) : BitmapData {
			var bmd : BitmapData;
			var bounds : Rectangle = dp.getBounds(dp);
			bmd = new BitmapData(bounds.width, bounds.height, transparent, 0x00ff0000);
			bmd.draw(dp, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y));
			return bmd;
		}
	}
}
