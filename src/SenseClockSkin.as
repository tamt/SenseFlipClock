package {
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.text.TextField;

	/**
	 * @author itamt
	 */
	public class SenseClockSkin extends Sprite {
		public var time_tf : TextField;
		public var bg:DisplayObject;

		private var _time : uint;
		
		private var _bgColor:uint;
		public function set bgColor(val:uint ):void {
			_bgColor = val;
			
			if (bg == null) {
				bg = this.getChildAt(0);
			}
			
			if (bg) {
				var tfm:ColorTransform = bg.transform.colorTransform;
				tfm.color = _bgColor;
				bg.transform.colorTransform = tfm;
				
			}
		}
		public function get bgColor():uint {
			return _bgColor;
		}

		public function SenseClockSkin() {
			super();
		}

		public function set time(val : uint):void {
			_time = val;
			if(time_tf)time_tf.text = (val < 10 ? ("0" + val) : ("" + val));
		}
		
		

		public function get time():uint {
			return _time;
		}
	}
}
