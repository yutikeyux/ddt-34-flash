package ddt.view.chat
{
	import com.pickgliss.ui.ComponentFactory;
	import com.pickgliss.ui.core.Disposeable;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class ChatScrollBar extends Sprite implements Disposeable
	{
		private var _currentIndex:int;
		private var _rowsOfScreen:int = 16;
		private var _length:int;
		private var _height:Number;
		private var _moveBtn:Sprite;
		private var _bitDB:BitmapData;
		private var _isDrag:Boolean = false;
		private var _backFun:Function;
		
		public function ChatScrollBar(param1:Function)
		{
			super();
			this._backFun = param1;
			this.initView();
			this.initEvent();
		}
		
		private function initView() : void
		{
			this._bitDB = ComponentFactory.Instance.creatBitmapData("asset.core.scroll.thumbV2");
			this._moveBtn = new Sprite();
			this._moveBtn.buttonMode = true;
			this._moveBtn.filters = [new GlowFilter(6705447,0.9)];
			addChild(this._moveBtn);
		}
		
		private function initEvent() : void
		{
			this._moveBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.__mouseDown);
		}
		
		private function removeEvent() : void
		{
			if(this._moveBtn)
			{
				this._moveBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.__mouseDown);
			}
			if(stage)
			{
				if(stage.hasEventListener(MouseEvent.MOUSE_UP))
				{
					stage.removeEventListener(MouseEvent.MOUSE_UP,this.__mouseUp);
				}
				if(stage.hasEventListener(MouseEvent.MOUSE_MOVE))
				{
					stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.__mouseMove);
				}
			}
		}
		
		private function __mouseDown(param1:MouseEvent) : void
		{
			this._isDrag = true;
			if(!stage) return;
			
			stage.addEventListener(MouseEvent.MOUSE_UP,this.__mouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE,this.__mouseMove);
			
			var maxY:Number = this._height - this._moveBtn.height;
			if(maxY < 0) maxY = 0;
			
			this._moveBtn.startDrag(false,new Rectangle(0,0,0,maxY));
		}
		
		private function __mouseUp(param1:MouseEvent) : void
		{
			this._isDrag = false;
			if(stage)
			{
				stage.removeEventListener(MouseEvent.MOUSE_UP,this.__mouseUp);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.__mouseMove);
			}
			this._moveBtn.stopDrag();
		}
		
		private function __mouseMove(param1:MouseEvent) : void
		{
			if(this._length <= this._rowsOfScreen) return;
			
			var denom:Number = (this._height - this._moveBtn.height);
			if(denom <= 0) return;
			
			var step:Number = denom / (this._length - this._rowsOfScreen);
			if(step <= 0) return;
			
			var idx:int = this._length - this._rowsOfScreen - int(this._moveBtn.y / step);
			
			if(idx < 0) idx = 0;
			var maxIdx:int = this._length - this._rowsOfScreen;
			if(idx > maxIdx) idx = maxIdx;
			
			if(idx != this._currentIndex)
			{
				this._backFun(this._moveBtn.y + this._moveBtn.height + 1 >= this._height ? 0 : idx);
			}
		}
		
		private function drawBackground() : void
		{
			graphics.clear();
			graphics.beginFill(0,0.5);
			graphics.drawRoundRect(4,1,4,this._height,4,4);
			graphics.endFill();
		}
		
		private function draw() : void
		{
			if(this._rowsOfScreen < 1) this._rowsOfScreen = 1;
			if(this._length < 0) this._length = 0;
			
			if(this._length > this._rowsOfScreen)
			{
				var thumbH:Number = (this._rowsOfScreen / this._length) * this._height;
				
				if(thumbH < 16) thumbH = 16;
				if(thumbH > this._height) thumbH = this._height;
				
				this.drawThumb(thumbH);
				
				var maxY:Number = this._height - this._moveBtn.height;
				if(maxY < 0) maxY = 0;
				
				var maxIdx:int = this._length - this._rowsOfScreen;
				if(maxIdx < 1) maxIdx = 1;
				
				this._moveBtn.y = maxY - (this._currentIndex * (maxY / maxIdx));
			}
			else
			{
				this._moveBtn.graphics.clear();
			}
		}
		
		private function drawThumb(param1:Number) : void
		{
			var m:Matrix = new Matrix();
			var topBD:BitmapData = new BitmapData(12,8,true,0);
			var midBD:BitmapData = new BitmapData(12,8,true,0);
			var botBD:BitmapData = new BitmapData(12,8,true,0);
			
			topBD.copyPixels(this._bitDB,new Rectangle(0,0,12,8),new Point(0,0));
			midBD.copyPixels(this._bitDB,new Rectangle(0,8,12,8),new Point(0,0));
			botBD.copyPixels(this._bitDB,new Rectangle(0,this._bitDB.height - 8,12,8),new Point(0,0));
			
			this._moveBtn.graphics.clear();
			
			this._moveBtn.graphics.beginBitmapFill(topBD,m,false);
			this._moveBtn.graphics.drawRect(0,0,12,8);
			
			var midH:Number = param1 - 16;
			if(midH < 0) midH = 0;
			
			this._moveBtn.graphics.beginBitmapFill(midBD,m);
			this._moveBtn.graphics.drawRect(0,8,12,midH);
			
			m.ty = param1 - 9;
			this._moveBtn.graphics.beginBitmapFill(botBD,m,false);
			this._moveBtn.graphics.drawRect(0,param1 - 9,12,8);
			
			this._moveBtn.graphics.endFill();
		}
		
		public function set rowsOfScreen(param1:int) : void
		{
			if(param1 < 1) param1 = 1;
			if(this._rowsOfScreen != param1)
			{
				this._rowsOfScreen = param1;
				this.draw();
			}
		}
		
		public function set length(param1:int) : void
		{
			if(this._length != param1)
			{
				this._length = param1;
				this.draw();
			}
		}
		
		public function set currentIndex(param1:int) : void
		{
			if(this._isDrag) return;
			
			if(this._currentIndex != param1)
			{
				var maxIdx:int = this._length - this._rowsOfScreen;
				if(maxIdx < 0) maxIdx = 0;
				
				var v:int = param1;
				if(v < 0) v = 0;
				if(v > maxIdx) v = maxIdx;
				
				this._currentIndex = v;
				this.draw();
			}
		}
		
		public function set Height(param1:Number) : void
		{
			if(this._height != param1)
			{
				this._height = param1;
				this.drawBackground();
				this.draw();
			}
		}
		
		public function dispose() : void
		{
			this.removeEvent();
			this._moveBtn = null;
			this._bitDB = null;
			if(parent)
			{
				parent.removeChild(this);
			}
		}
	}
}
