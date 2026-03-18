package road.game.resource
{
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	public class ActionMovie extends MovieClip
	{
		
		public static var LEFT:String = "left";
		
		public static var RIGHT:String = "right";
		
		public static var DEFAULT_ACTION:String = "stand";
		
		public static var STAND_ACTION:String = "stand";
		
		private var _labelLastFrames:Array;
		
		private var _soundControl:SoundTransform;
		
		private var _labelLastFrame:Dictionary;
		
		private var _currentAction:String;
		
		private var lastAction:String = "";
		
		private var _callBacks:Dictionary;
		
		private var _argsDic:Dictionary;
		
		private var _actionEnded:Boolean = true;
		
		protected var _actionRelative:Object;
		
		public var labelMapping:Dictionary;
		
		private var _soundEffectInstance:*;
		
		private var _shouldReplace:Boolean = true;
		
		private var _die:MovieClip;
		
		private var _isMute:Boolean = false;
		
		public function ActionMovie()
		{
			this._labelLastFrames = [];
			this._labelLastFrame = new Dictionary();
			this._argsDic = new Dictionary();
			this.labelMapping = new Dictionary();
			var sClass:* = undefined;
			super();
			try
			{
				sClass = getDefinitionByName("ddt.manager.SoundEffectManager");
				if(sClass)
				{
					this._soundEffectInstance = sClass.Instance;
				}
			}
			catch(e:Error)
			{
			}
			this._callBacks = new Dictionary();
			mouseEnabled = false;
			mouseChildren = false;
			scrollRect = null;
			this._soundControl = new SoundTransform();
			soundTransform = this._soundControl;
			this.initMovie();
			this.addEvent();
		}
		
		public function get shouldReplace() : Boolean
		{
			return this._shouldReplace;
		}
		
		public function set shouldReplace(value:Boolean) : void
		{
			this._shouldReplace = value;
		}
		
		private function initMovie() : void
		{
			var i:int = 0;
			var labels:Array = currentLabels;
			if(labels.length > 0)
			{
				i = 0;
				while(i < labels.length)
				{
					if(i != 0)
					{
						this._labelLastFrame[labels[i - 1].name] = int(labels[i].frame - 1);
					}
					i++;
				}
				this._labelLastFrame[labels[labels.length - 1].name] = int(totalFrames);
			}
		}
		
		private function addEvent() : void
		{
			addEventListener(ActionMovieEvent.ACTION_END,this.__onActionEnd);
		}
		
		public function doAction(_arg_1:String, callBack:Function = null, args:Array = null) : void
		{
			var actionLabel:String = null;
			if(this.labelMapping[_arg_1])
			{
				actionLabel = this.labelMapping[_arg_1];
			}
			else
			{
				actionLabel = _arg_1;
			}
			if(!this.hasThisAction(actionLabel))
			{
				if(callBack != null)
				{
					this.callFun(callBack,args);
				}
				return;
			}
			if(!this._actionEnded)
			{
				if(this._callBacks && this._callBacks[this.currentAction] != null)
				{
					this.callCallBack(this.currentAction);
				}
				this._actionEnded = true;
				dispatchEvent(new ActionMovieEvent(ActionMovieEvent.ACTION_END));
			}
			this._actionEnded = false;
			if(callBack != null && this._callBacks != null && this._callBacks[actionLabel] != callBack)
			{
				this._callBacks[actionLabel] = callBack;
				this._argsDic[actionLabel] = args;
			}
			this.lastAction = this.currentAction;
			this._currentAction = actionLabel;
			if(this._soundControl)
			{
				this._soundControl.volume = !!this._isMute ? Number(0) : Number(1);
			}
			if(soundTransform && this._soundControl)
			{
				soundTransform = this._soundControl;
			}
			addEventListener(Event.ENTER_FRAME,this.loop);
			this.MCGotoAndPlay(this.currentAction);
			dispatchEvent(new ActionMovieEvent(ActionMovieEvent.ACTION_START));
		}
		
		private function hasThisAction(_arg_1:String) : Boolean
		{
			var i:FrameLabel = null;
			var result:Boolean = false;
			for each(i in currentLabels)
			{
				if(i.name == _arg_1)
				{
					result = true;
					break;
				}
			}
			return result;
		}
		
		private function loop(e:Event) : void
		{
			if(currentFrame == this._labelLastFrame[this.currentAction] || currentLabel != this.currentAction)
			{
				removeEventListener(Event.ENTER_FRAME,this.loop);
				this._actionEnded = true;
				if(this._callBacks && this._callBacks[this.currentAction] != null)
				{
					this.callCallBack(this.currentAction);
				}
				dispatchEvent(new ActionMovieEvent(ActionMovieEvent.ACTION_END));
			}
		}
		
		private function callCallBack(key:String) : void
		{
			var args:Array = this._argsDic[key];
			if(this._callBacks[key] == null)
			{
				return;
			}
			this.callFun(this._callBacks[key],args);
			this.deleteFun(key);
		}
		
		private function deleteFun(key:String) : void
		{
			if(this._callBacks)
			{
				this._callBacks[key] = null;
				delete this._callBacks[key];
			}
			if(this._argsDic)
			{
				this._argsDic[key] = null;
				delete this._argsDic[key];
			}
		}
		
		private function callFun(fun:Function, args:Array) : void
		{
			if(args == null || args.length == 0)
			{
				fun();
			}
			else if(args.length == 1)
			{
				fun(args[0]);
			}
			else if(args.length == 2)
			{
				fun(args[0],args[1]);
			}
			else if(args.length == 3)
			{
				fun(args[0],args[1],args[2]);
			}
			else if(args.length == 4)
			{
				fun(args[0],args[1],args[2],args[3]);
			}
		}
		
		public function get currentAction() : String
		{
			return this._currentAction;
		}
		
		public function setActionRelative(value:Object) : void
		{
			this._actionRelative = value;
		}
		
		public function get popupPos() : Point
		{
			if(this["_popPos"])
			{
				return new Point(this["_popPos"].x * scaleX,this["_popPos"].y);
			}
			return null;
		}
		
		public function get popupDir() : Point
		{
			if(this["_popDir"])
			{
				return new Point(this["_popDir"].x,this["_popDir"].y);
			}
			return null;
		}
		
		public function set direction(value:String) : void
		{
			if(ActionMovie.LEFT == value)
			{
				scaleX = 1;
			}
			else if(ActionMovie.RIGHT == value)
			{
				scaleX = -1;
			}
		}
		
		public function get direction() : String
		{
			if(scaleX > 0)
			{
				return ActionMovie.LEFT;
			}
			return ActionMovie.RIGHT;
		}
		
		public function setActionMapping(source:String, target:String) : void
		{
			if(source.length <= 0)
			{
				return;
			}
			this.labelMapping[source] = target;
		}
		
		private function stopMovieClip(mc:MovieClip) : void
		{
			var i:int = 0;
			if(mc)
			{
				mc.gotoAndStop(1);
				if(mc.numChildren > 0)
				{
					i = 0;
					while(i < mc.numChildren)
					{
						this.stopMovieClip(mc.getChildAt(i) as MovieClip);
						i++;
					}
				}
			}
		}
		
		override public function gotoAndStop(frame:Object, scene:String = null) : void
		{
			var s:FrameLabel = null;
			if(frame is String)
			{
				for each(s in currentLabels)
				{
					if(s.name == frame)
					{
						super.gotoAndStop(frame);
						return;
					}
				}
			}
			else
			{
				super.gotoAndStop(frame);
			}
		}
		
		protected function endAction() : void
		{
			dispatchEvent(new ActionMovieEvent("end"));
		}
		
		protected function startAction() : void
		{
			dispatchEvent(new ActionMovieEvent("start"));
		}
		
		protected function send(_arg_1:String) : void
		{
			dispatchEvent(new ActionMovieEvent(_arg_1));
		}
		
		protected function sendCommand(_arg_1:String, data:Object = null) : void
		{
			dispatchEvent(new ActionMovieEvent(_arg_1,data));
		}
		
		override public function gotoAndPlay(frame:Object, scene:String = null) : void
		{
			this.doAction(String(frame));
		}
		
		public function MCGotoAndPlay(frame:Object) : void
		{
			super.gotoAndPlay(frame);
		}
		
		private function __onActionEnd(evt:ActionMovieEvent) : void
		{
			var _local_2:* = undefined;
			if(!this._actionRelative)
			{
				return;
			}
			if(!this._actionRelative[this._currentAction])
			{
				this.doAction(DEFAULT_ACTION);
				return;
			}
			if(this._actionRelative[this._currentAction] is Function)
			{
				_local_2 = this._actionRelative;
				_local_2[this._currentAction]();
			}
			else
			{
				this.doAction(this._actionRelative[this._currentAction]);
			}
		}
		
		public function get versionTag() : String
		{
			return "road.game.resource.ActionMovie version:1.02";
		}
		
		public function doSomethingSpecial() : void
		{
		}
		
		public function mute() : void
		{
			this._soundControl.volume = 0;
			this._isMute = true;
		}
		
		public function dispose() : void
		{
			this._soundControl.volume = 0;
			removeEventListener(Event.ENTER_FRAME,this.loop);
			this.stopMovieClip(this);
			stop();
			this._soundControl = null;
			this._labelLastFrames = null;
			if(parent)
			{
				parent.removeChild(this);
			}
			this._callBacks = null;
		}
	}
}
