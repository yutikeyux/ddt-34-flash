package bagAndInfo.bag
{
	import com.pickgliss.ui.ComponentFactory;
	import com.pickgliss.utils.DoubleClickManager;
	import com.pickgliss.utils.ObjectUtils;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	import bagAndInfo.cell.BagCell;
	import bagAndInfo.cell.CellFactory;
	
	import ddt.data.BagInfo;
	import ddt.data.goods.InventoryItemInfo;
	import ddt.events.BagEvent;
	import ddt.manager.PlayerManager;
	
	public class BankBagListView extends BagListView
	{
		
		
		private var _allBagData:BagInfo;
		
		public var _startIndex:int;
		
		public var _stopIndex:int;
		
		private var _pageBtn:BagPageButton;
		
		private var _pageBtn2:BagPageButton;
		
		public var _maxPage:int;
		
		public function BankBagListView(param1:int, param2:int = 0, param3:int = 99, param4:int = 10, param5:int = 1)
		{
			this._startIndex = param2;
			this._stopIndex = param3;
			this._maxPage = 5;
			_page = param5;
			super(param1,param4,100);
		}
		
		override public function setData(param1:BagInfo) : void
		{
			var _loc3_:* = undefined;
			if(_bagdata != null)
			{
				_bagdata.removeEventListener("update",this.__updateGoods);
			}
			clearDataCells();
			_bagdata = param1;
			var _loc4_:* = _bagdata.items;
			for(_loc3_ in _bagdata.items)
			{
				if(_cells[_loc3_] != null)
				{
					_bagdata.items[_loc3_].isMoveSpace = true;
					_cells[_loc3_].info = _bagdata.items[_loc3_];
				}
			}
			_bagdata.addEventListener("update",this.__updateGoods);
		}
		
		override protected function __updateGoods(param1:BagEvent) : void
		{
			var _loc3_:* = undefined;
			var _loc4_:* = null;
			var _loc2_:* = null;
			_loc4_ = param1.changedSlots;
			var _loc5_:* = _loc4_;
			for each(_loc3_ in _loc4_)
			{
				_loc2_ = _bagdata.getItemAt(_loc3_.Place);
				if(_loc2_)
				{
					this.setCellInfo(_loc2_.Place,_loc2_);
				}
				else
				{
					this.setCellInfo(_loc3_.Place,null);
				}
				dispatchEvent(new Event("change"));
			}
		}
		
		override protected function createCells() : void
		{
			var _loc2_:int = 0;
			var _loc1_:* = null;
			_cells = new Dictionary();
			_cellMouseOverBg = ComponentFactory.Instance.creatBitmap("bagAndInfo.cell.bagCellOverBgAsset");
			_loc2_ = this._startIndex;
			while(_loc2_ < this._stopIndex -1)
			{
				_loc1_ = CellFactory.instance.createBagCell(_loc2_) as BagCell;
				_loc1_.mouseOverEffBoolean = false;
				addChild(_loc1_);
				_loc1_.addEventListener("interactive_click",__clickHandler);
				_loc1_.addEventListener("mouseOver",_cellOverEff);
				_loc1_.addEventListener("mouseOut",_cellOutEff);
				_loc1_.addEventListener("interactive_double_click",__doubleClickHandler);
				DoubleClickManager.Instance.enableDoubleClick(_loc1_);
				_loc1_.addEventListener("lockChanged",__cellChanged);
				_loc1_.bagType = _bagType;
				_loc1_.addEventListener("lockChanged",__cellChanged);
				_cells[_loc1_.place] = _loc1_;
				_cellVec.push(_loc1_);
				_loc2_++;
			}
			
			if(_loc2_ == this._stopIndex - 1)
			{
				if(_page == 1 || _page == _maxPage){
					_loc1_ = CellFactory.instance.createBagCell(_loc2_) as BagCell;
					_loc1_.mouseOverEffBoolean = false;
					addChild(_loc1_);
					_loc1_.addEventListener("interactive_click",__clickHandler);
					_loc1_.addEventListener("mouseOver",_cellOverEff);
					_loc1_.addEventListener("mouseOut",_cellOutEff);
					_loc1_.addEventListener("interactive_double_click",__doubleClickHandler);
					DoubleClickManager.Instance.enableDoubleClick(_loc1_);
					_loc1_.addEventListener("lockChanged",__cellChanged);
					_loc1_.bagType = _bagType;
					_loc1_.addEventListener("lockChanged",__cellChanged);
					_cells[_loc1_.place] = _loc1_;
					_cellVec.push(_loc1_);
					
				} else
				{
					this._pageBtn2 = ComponentFactory.Instance.creatComponentByStylename("core.bag.downBtn");
					this._pageBtn2.addEventListener("click",this.__onPageChange2);
					addChild(this._pageBtn2);
				}
				_loc2_++;
				
			}

			if(_loc2_ == this._stopIndex)
			{
				if(_page < _maxPage)
				{
					this._pageBtn = ComponentFactory.Instance.creatComponentByStylename("core.bag.upBtn");
				}
				else
				{
					this._pageBtn = ComponentFactory.Instance.creatComponentByStylename("core.bag.downBtn");
				}
				this._pageBtn.addEventListener("click",this.__onPageChange);
				addChild(this._pageBtn);
			}
		}
		
		override public function setCellInfo(param1:int, param2:InventoryItemInfo) : void
		{
			if(param1 >= this._startIndex && param1 < this._stopIndex)
			{
				if(param2 == null)
				{
					_cells[param1].info = null;
					return;
				}
				if(param2.Count == 0)
				{
					_cells[param1].info = null;
				}
				else
				{
					_cells[param1].info = param2;
				}
			}
		}
		
		private function __onPageChange(param1:MouseEvent) : void
		{
			var _loc2_:* = undefined;
			var _loc7_:int = 0;
			var _loc6_:* = undefined;
			var _loc3_:* = undefined;
			if(this._pageBtn)
			{
				this._pageBtn.removeEventListener("click",this.__onPageChange);
				ObjectUtils.disposeObject(this._pageBtn);
				this._pageBtn = null;
			}
			if(this._pageBtn2)
			{
				this._pageBtn2.removeEventListener("click",this.__onPageChange2);
				ObjectUtils.disposeObject(this._pageBtn2);
				this._pageBtn2 = null;
			}
			var _loc4_:* = _cells;
			for each(_loc2_ in _cells)
			{
				_loc2_.removeEventListener("interactive_click",__clickHandler);
				_loc2_.removeEventListener("interactive_double_click",__doubleClickHandler);
				DoubleClickManager.Instance.disableDoubleClick(_loc2_);
				_loc2_.removeEventListener("lockChanged",__cellChanged);
			}
			_loc7_ = 0;
			_loc6_ = _cells;
			for each(_loc3_ in _cells)
			{
				_loc3_.removeEventListener("interactive_click",__clickHandler);
				_loc3_.removeEventListener("lockChanged",__cellChanged);
				_loc3_.removeEventListener("mouseOver",_cellOverEff);
				_loc3_.removeEventListener("mouseOut",_cellOutEff);
				_loc3_.removeEventListener("interactive_double_click",__doubleClickHandler);
				DoubleClickManager.Instance.disableDoubleClick(_loc3_);
				_loc3_.dispose();
			}
			_cells = null;
			_cellVec = null;
			_page++;
			if(_page > _maxPage) {
				_page -= 2;
			}
			
			var _minusPageStart:int;
			var _minusPageStop:int;
			if(_page == 1) {
				_minusPageStart = 0;
			} else{
				_minusPageStart = 1;
			}
			
			this._startIndex = (_page - 1) * (100 - _minusPageStart) - (_page - 2) * (_page > 2 ? 1 : 0);
			if(this._startIndex < 0) {
				this._startIndex = 0;
			}
			this._stopIndex = this._startIndex + 99;
			//1 0-99 0 99
			//2 99-198 99
			//3 197-296 197
			//4 295-394 295
			//5 393-492 395
			
			_cellVec = [];
			this.createCells();
			this.setData(PlayerManager.Instance.Self.BankBag);
		}
		
		private function __onPageChange2(param1:MouseEvent) : void
		{
			var _loc2_:* = undefined;
			var _loc7_:int = 0;
			var _loc6_:* = undefined;
			var _loc3_:* = undefined;
			if(this._pageBtn)
			{
				this._pageBtn.removeEventListener("click",this.__onPageChange);
				ObjectUtils.disposeObject(this._pageBtn);
				this._pageBtn = null;
			}
			if(this._pageBtn2)
			{
				this._pageBtn2.removeEventListener("click",this.__onPageChange2);
				ObjectUtils.disposeObject(this._pageBtn2);
				this._pageBtn2 = null;
			}
			var _loc4_:* = _cells;
			for each(_loc2_ in _cells)
			{
				_loc2_.removeEventListener("interactive_click",__clickHandler);
				_loc2_.removeEventListener("interactive_double_click",__doubleClickHandler);
				DoubleClickManager.Instance.disableDoubleClick(_loc2_);
				_loc2_.removeEventListener("lockChanged",__cellChanged);
			}
			_loc7_ = 0;
			_loc6_ = _cells;
			for each(_loc3_ in _cells)
			{
				_loc3_.removeEventListener("interactive_click",__clickHandler);
				_loc3_.removeEventListener("lockChanged",__cellChanged);
				_loc3_.removeEventListener("mouseOver",_cellOverEff);
				_loc3_.removeEventListener("mouseOut",_cellOutEff);
				_loc3_.removeEventListener("interactive_double_click",__doubleClickHandler);
				DoubleClickManager.Instance.disableDoubleClick(_loc3_);
				_loc3_.dispose();
			}
			_cells = null;
			_cellVec = null;
			_page--;
			if(_page == 0){
				_page = 1;
			}

			var _minusPageStart:int;
			var _minusPageStop:int;
			if(_page == 1) {
				_minusPageStart = 0;
			} else{
				_minusPageStart = 1;
			}
			
			this._startIndex = (_page - 1) * (100 - _minusPageStart) - (_page - 2) * (_page > 2 ? 1 : 0);
			if(this._startIndex < 0) {
				this._startIndex = 0;
			}
			this._stopIndex = this._startIndex + 99;
			//1 0-99 0 99
			//2 99-198 99
			//3 197-296 197
			//4 295-394 295
			//5 393-492 395
			
			_cellVec = [];
			this.createCells();
			this.setData(PlayerManager.Instance.Self.BankBag);
		}
		
		public function checkConsortiaStoreCell() : int
		{
			var _loc1_:* = undefined;
			var _loc2_:* = _cells;
			for each(_loc1_ in _cells)
			{
				if(!_loc1_.info)
				{
					return 0;
				}
			}
			return 3;
		}
		
		override public function dispose() : void
		{
			if(this._pageBtn)
			{
				this._pageBtn.removeEventListener("click",this.__onPageChange);
				ObjectUtils.disposeObject(this._pageBtn);
				this._pageBtn = null;
			}
			super.dispose();
			if(this.parent)
			{
				this.parent.removeChild(this);
			}
		}
	}
}
