package {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.utils.getQualifiedClassName;
	import flash.utils.Timer;

	/**
	 * @author itamt@qq.com
	 */
	public class SenseFlipClock extends Sprite {
		protected var _inited:Boolean = false;
		
		//flip time mode. default: flip on every second.
		private var _flipOn:String = "second";
		[Inspectable(defaultValue = "second", type = "String", enumeration="hour,minute,second,1/10 second,custom")]
		public function set flipOn(val:String):void {
			if (isLivePreview) val = "custom";
			_flipOn = val;
			switch(_flipOn) {
				case "hour":
					this.interval = 1000;
					onTimer();
					break;
				case "minute":
					this.interval = 1000;
					onTimer();
					break;
				case "second":
					this.interval = 100;
					onTimer();
					break;
				case "1/10 second":
					this.interval = 100;
					break;
				case "custom":
					this.interval = 0;
					break;
			}
		}
		public function get flipOn():String {
			return _flipOn;
		}
				
		//flip transition duration, in frames
		private var _duration:uint = 20;
		[Inspectable(defaultValue =20, type = "Number")]
		public function set duration(val:Number):void {
			_duration = val;
			this._hFlipper.duration = _duration;
		}
		public function get duration():Number {
			return _duration;
		}
		
		//flip interval
		private var _interval:uint = 100;
		public function set interval(val:uint):void {
			//if (_flipOn != "custom") {
				//throw new Error('Set the "flipOn" option as "custom" first');
			//}
			_interval = val;
			_timer.delay = val;
			if (_timer.delay == 0) {
				_timer.stop();
			}else {
				if(!_timer.running)_timer.start();
			}
		}
		public function get interval():uint {
			return _interval;
		}
		
		//clock color style
		//clock text color
		private var _textColor:uint = 0x000000;
		[Inspectable(defaultValue = "#000000", type = "Color")]
		public function set textColor(val:uint):void {
			_textColor = val;
			
			setSkinTextColor(_textColor);
			
			invalidateUpdate();
		}
		public function get textColor():uint {
			return _textColor;
		}
		
		//clock bg color
		private var _bgColor:uint = 0xffffff;
		[Inspectable(defaultValue = "#ffffff", type = "Color")]
		public function set bgColor(val:uint):void {
			_bgColor = val;
			setSkinBgColor(_bgColor);
			
			invalidateUpdate();
		}
		public function get bgColor():uint {
			return _bgColor;
		}
		//paper become dark when flipping.
		private var _darken:Boolean = true;
		[Inspectable(defaultValue = true, type = "Boolean")]
		public function set darken(val:Boolean):void {
			_darken = val;
			_hFlipper.bright = _darken;
			
			invalidateUpdate();
		}
		public function get darken():Boolean {
			return _darken;
		}
		
		//return the value of SenseFlipClock
		private var _value:uint;
		public function get value():uint {
			return _value;
		}
		public function set value(val:uint):void {
			_value = val;
			setSkinValue(_value.toString());
		}
		
		private var _skin:String = "SenseClockSkin";
		[Inspectable(defaultValue = "SenseClockSkin", type = "String")]
		public function get skin():String { return _skin; }
		public function set skin(value:String):void 
		{
			_skin = value;
			if (!this.loaderInfo.applicationDomain.hasDefinition(_skin)) {
				trace("SenseFlipClock can't find the skin class name: " + value + ", will use default built-in skin class: SenseClockSkin");
				_skin = "SenseClockSkin";
			}
			if (_inited) {
				this.onAdded();
			}
		}

		public var hSkin : DisplayObject;
		private var _hFlipper : SenseFlipper;
		private var _timer : Timer;

		public function SenseFlipClock() {
			super();
			
			if (stage) onInterAdded();
			else addEventListener(Event.ADDED_TO_STAGE, onInterAdded);
			addEventListener(Event.REMOVED_FROM_STAGE, onInterRemoved);
			
		}
		
		private function onInterAdded(e:Event = null):void 
		{
			if (_inited) return;
			_inited = true;
			this.onAdded(e);
		}
		
		protected function onRemoved(e:Event = null):void {
		}
		
		private function onInterRemoved(e:Event):void {
			if (!_inited) return;
			_inited = false;
			this.onInterRemoved(e);
		}
		
		protected function onAdded(e:Event = null):void 
		{
			if (!this.loaderInfo.applicationDomain.hasDefinition(_skin))_skin = "SenseClockSkin";
			var skinClass:Class = this.loaderInfo.applicationDomain.getDefinition(_skin) as Class;
			if (skinClass) {
				if(hSkin && hSkin.parent)hSkin.parent.removeChild(hSkin);
				hSkin = new skinClass();
			}
				
			var hasFilters:Boolean = hSkin.filters.length > 0;
			var filters:Array;
			if(hasFilters){
				filters = new Array();
				for (var i:int = 0; i < hSkin.filters.length; i++) {
					filters.push(hSkin.filters[i].clone());
				}
				hSkin.filters = null;
			}
			
			this.textColor = _textColor;
			this.bgColor = _bgColor;
			this.value = _value;

			//create the flipper
			if(_hFlipper == null){
				_hFlipper = new SenseFlipper(SnapShoter.snap(hSkin), _duration);
			}
			_hFlipper.duration = this._duration;
			_hFlipper.bright = this._darken;
			
			//replace skin use flipper.
			_hFlipper.x = hSkin.x;
			_hFlipper.y = hSkin.y;
            if(hasFilters)_hFlipper.filters = filters;
			if(_hFlipper.parent == null)addChild(_hFlipper);
			if(hSkin.parent)hSkin.parent.removeChild(hSkin);
			
			//listner timer
			if(_timer == null){
				_timer = new Timer(_interval);
				_timer.addEventListener(TimerEvent.TIMER, onTimer);
			}
			_timer.start();
			
			//set default flipOn
			//this.flipOn = _flipOn;
		}
		
		/**
		 * dispose this object completely
		 */
		public function dispose():void {
			onRemoved();
			this.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
		}
		
		private function onTimer(event : TimerEvent = null) : void {
			var date : Date = new Date();
			var h : uint = date.getHours();
			var m : uint = date.getMinutes();
			var s : uint = date.getSeconds();
			var t : uint = _timer.currentCount % 10;
				
			if (_flipOn == "hour" && h != _value) {
				value = h;
				flip();
			}else if (_flipOn == "minute" && m != _value) {
				value = m;
				flip();
			}else if (_flipOn == "second" && s != _value) {
				value = s;
				flip();
			}else if (_flipOn == "1/10 second" && t != _value) {
				value = t;
				flip();
			}
		}
		
		private function invalidateUpdate():void {
			if (this.stage) {
				this.stage.invalidate();
				this.stage.removeEventListener(Event.RENDER, updateLater);
				this.stage.addEventListener(Event.RENDER, updateLater);
			}
		}
		
		private function updateLater(evt:Event):void {
			stage.removeEventListener(Event.RENDER, update);
			this.update();
		}
		
		private function setSkinTextColor(color:uint):void {
			if (hSkin is DisplayObjectContainer) {
				var _this:DisplayObjectContainer = hSkin as DisplayObjectContainer;
				var tf:TextField = _this.getChildByName("time_tf") as TextField;
				if (tf == null) {
					for (var i:int = 0; i < _this.numChildren; i++) {
						if ((_this.getChildAt[i] is TextField)) {
							tf = _this.getChildAt[i] as TextField;
							break;
						}
					}
				}
				
				if (tf) {
					tf.textColor = color;
				}
			}
		}
		
		private function setSkinBgColor(color:uint):void {
			if (hSkin is DisplayObjectContainer) {
				var _this:DisplayObjectContainer = hSkin as DisplayObjectContainer;
				var bg:DisplayObject = _this.getChildByName("bg");
				if (bg == null) {
					bg = _this.getChildAt(0);
				}
				
				if (bg) {
					var tfm:ColorTransform = bg.transform.colorTransform;
					tfm.color = _bgColor;
					bg.transform.colorTransform = tfm;
					
				}
			}
		}
		
		private function setSkinValue(val:String):void {
			if (hSkin is DisplayObjectContainer) {
				var _this:DisplayObjectContainer = hSkin as DisplayObjectContainer;
				var tf:TextField = _this.getChildByName("time_tf") as TextField;
				if (tf == null) {
					for (var i:int = 0; i < _this.numChildren; i++) {
						if ((_this.getChildAt[i] is TextField)) {
							tf = _this.getChildAt[i] as TextField;
							break;
						}
					}
				}
				
				if (tf) {
					if (val.length == 1) val = "0" + val;
					tf.text = val;
				}
			}
		}
		
		public function flip():void {
			_hFlipper.next(SnapShoter.snap(hSkin));
		}
		
		/**
		 * update the capture of skin
		 */
		public function update():void {
			_hFlipper.replace(-1, SnapShoter.snap(hSkin));
		}
		
		public function get isLivePreview() : Boolean {
			return (parent != null && getQualifiedClassName(parent) == "fl.livepreview::LivePreviewParent");
		}
	}
}
