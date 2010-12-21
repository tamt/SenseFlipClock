package {
	import BitmapTransformer;
	import flash.geom.ColorTransform;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;

	/**
	 * @author itamt@qq.com
	 */
	public class SenseFlipper extends Sprite {
		//frame number
		public function get frames():uint {
			return transFrames.length;
		}

		private var transFrames : Array;
		private var _duration : uint = 20;
		public function set duration(val:Number):void {
			_duration = val;
			build();
		}
		public function get duration():Number {
			return _duration;
		}
		
		public var bright:Boolean = true;

		public function SenseFlipper(bmd : BitmapData, duration:uint = 20) {
			this._duration = duration;
			transFrames = [new TransitionFrame(1, null, bmd), new TransitionFrame(0, bmd, null)];
			build();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		public function next(bmd : BitmapData) : void {
			var lastFrame : TransitionFrame = transFrames[transFrames.length - 1] as TransitionFrame;
			lastFrame.setNextFrame(bmd);
			lastFrame.play();
			transFrames.push(new TransitionFrame(0, bmd, null));
		}
		
		/**
		 * replace one frame's bitmapdata
		 * @param	i			frame index, which frame will be update
		 * @param	bmd			the new bitmapdata
		 */
		public function replace(i:int, bmd:BitmapData):void {
			if (i < 0) {
				for (var i:int = 0;  i < transFrames.length; i++) {
					(transFrames[i] as TransitionFrame).setNextFrame(bmd);
					(transFrames[i] as TransitionFrame).setPrevFrame(bmd);
				}	
			}else {
				var lastFrame : TransitionFrame = transFrames[transFrames.length - 1] as TransitionFrame;				
				if (lastFrame) {
					lastFrame.setNextFrame(bmd);
					lastFrame.setPrevFrame(bmd);
				}
			}
			
			this.build();
		}

		private function onEnterFrame(event : Event = null) : void {
			var needRender : Boolean = false;
			var turnStop : Boolean = false;
			var i : int;
			var c : int;
			var trans : TransitionFrame;
			for( i = 0; i < transFrames.length; i++) {
				trans = transFrames[i];
				if(trans.playing) {
					needRender = true;
					
					if((trans.timePercent+=1/_duration) >= 1) {
						turnStop = true;
						trans.stop();
						c += 1;
					}
				}
			}

			if (turnStop) {
				while(c--){
					trans = transFrames.shift();
					trans.dispose();
				}
			}

			if(needRender)
				build();
		}

		private function build() : void {
			var frames : Array = transFrames.slice();
			frames.sort(this.sortTimeOnMiddle);

			this.graphics.clear();
			for(var i : int = 0; i < frames.length; i++) {
				var frame : TransitionFrame = frames[i];
				
				var ratio:Number = Math.sin((.5 - Math.abs(frame.timePercent - .5)) / (.5));
				//var ratio:Number = Math.cos(frame.time / duration);
				var distX : Number = frame.width * .1 * ratio;
				var tl : Point = new Point(-distX, frame.timePercent * frame.height);
				var tr : Point = new Point(frame.width + distX, frame.timePercent * frame.height);
				var br : Point = new Point(frame.width, frame.height / 2);
				var bl : Point = new Point(0, frame.height / 2);
				
				var tfm : BitmapTransformer = new BitmapTransformer(frame.width, frame.height / 2, 1, 1);
				tfm.smoothOn = true;
				var bmd:BitmapData;
				if (frame.timePercent < .5) {
					bmd = frame.getPrevHalfFrame();
					if(bright)bmd.colorTransform(bmd.rect, new ColorTransform(1-ratio, 1-ratio, 1-ratio));
					tfm.mapBitmapData(bmd, tl, tr, br, bl, this);
				} else {
					bmd = frame.getNextHalfFrame();
					if(bright)bmd.colorTransform(bmd.rect, new ColorTransform(1-ratio, 1-ratio, 1-ratio));
					tfm.mapBitmapData(bmd, bl, br, tr, tl, this);
				}
			}
		}

		private function sortTimeOnMiddle(a : TransitionFrame, b : TransitionFrame):Number {
			var ad : Number = Math.abs(a.timePercent - .5);
			var bd : Number = Math.abs(b.timePercent - .5);
			if(ad > bd) {
				return -1;
			} else if(ad < bd) {
				return 1;
			} else {
				if(a.timePercent < b.timePercent) {
					return -1;
				} else if(a.timePercent > b.timePercent) {
					return 1;
				}
				return 0;
			}
		}
	}
}
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

class TransitionFrame {

	public var timePercent : Number;
	public var frame : BitmapData;

	private var _playing : Boolean = false;

	public function TransitionFrame(timePercent : Number, prevFrame : BitmapData = null, nextFrame : BitmapData = null):void {
		this.timePercent = timePercent;

		// build frame
		if(prevFrame) {
			frame = new BitmapData(prevFrame.width, prevFrame.height);
			this.setPrevFrame(prevFrame);
		}
		if(nextFrame) {
			if(frame == null)
				frame = new BitmapData(nextFrame.width, nextFrame.height);
			this.setNextFrame(nextFrame);
		}
	}

	public function setNextFrame(nextFrame : BitmapData):void {
		frame.copyPixels(nextFrame, new Rectangle(0, nextFrame.height / 2, nextFrame.width, nextFrame.height / 2), new Point(0, nextFrame.height / 2));
	}

	public function setPrevFrame(prevFrame : BitmapData):void {
		frame.copyPixels(prevFrame, new Rectangle(0, 0, prevFrame.width, prevFrame.height / 2), new Point(0, 0));
	}

	public function getPrevHalfFrame():BitmapData {
		var bmd : BitmapData;
		bmd = new BitmapData(frame.width, frame.height / 2);
		bmd.copyPixels(frame, bmd.rect, new Point());
		return bmd;
	}

	public function getNextHalfFrame():BitmapData {
		var bmd : BitmapData;
		bmd = new BitmapData(frame.width, frame.height / 2);
		bmd.copyPixels(frame, new Rectangle(0, bmd.height, bmd.width, bmd.height), new Point());
		return bmd;
	}

	public function play():void {
		_playing = true;
	}

	public function stop():void {
		_playing = false;
	}

	public function dispose():void {
		this.frame.dispose();
	}

	public function get playing() : Boolean {
		return _playing;
	}

	public function toString():String {
		return timePercent.toString();
	}

	public function get width():Number {
		return frame.width;
	}

	public function get height():Number {
		return frame.height;
	}
}