package store.fineStore.view
{
	import com.pickgliss.ui.ComponentFactory;
	import com.pickgliss.ui.controls.SelectedButton;
	import com.pickgliss.ui.controls.SelectedButtonGroup;
	import com.pickgliss.ui.controls.container.VBox;
	import com.pickgliss.ui.core.Disposeable;
	import com.pickgliss.ui.core.ITipedDisplay;
	import com.pickgliss.ui.image.ScaleFrameImage;
	import com.pickgliss.utils.ObjectUtils;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import ddt.manager.SocketManager;
	import ddt.manager.SoundManager;
	import ddt.utils.AssetModuleLoader;
	import ddt.utils.HelpBtnEnable;
	import ddt.utils.PositionUtils;
	
	import store.FineBringUpController;
	import store.StoreController;
	import store.fineStore.view.pageBringUp.FineBringUpView;
	
	public class FineStoreView extends Sprite implements Disposeable
	{
		private static const _forgeGroupType:Array = ["storeFineForge","storeFineBringUp","equipGhost"];
		
		private var _tabVbox:VBox;
		
		private var _btnGroup:SelectedButtonGroup;
		
		private var _forgeBtn:SelectedButton;
		
		private var _forgeView:FineForgeView;
		
		private var _bringUpBtn:SelectedButton;
		
		private var _bringUpView:FineBringUpView;
		
		private var _ghostBtn:SelectedButton;
		
		private var _ghostView:FineGhostView;
		
		private var _content:Sprite;
		
		private var _index:int;
		
		private var _controller:StoreController;
		
		private var bg:ScaleFrameImage;
		
		public function FineStoreView(param1:StoreController, param2:int)
		{
			super();
			_index = param2;
			_controller = param1;
			init();
			setIndex();
		}
		
		private function setIndex() : void
		{
			var _loc1_:* = null;
			var _loc3_:int = 0;
			var _loc2_:int = _btnGroup.length();
			_loc3_ = _index;
			while(_loc3_ < _loc2_)
			{
				_loc1_ = _btnGroup.getItemByIndex(_loc3_) as ITipedDisplay;
				if(HelpBtnEnable.getInstance().isForbidden(_loc1_) == false)
				{
					_btnGroup.selectIndex = _loc3_;
					break;
				}
				_loc3_++;
			}
		}
		
		private function init() : void
		{
			_content = new Sprite();
			addChild(_content);
			_forgeBtn = ComponentFactory.Instance.creatComponentByStylename("ddtstore.fineStore.forgeBtn");
			_bringUpBtn = ComponentFactory.Instance.creatComponentByStylename("ddtstore.fineStore.bringUpBtn");
			_ghostBtn = ComponentFactory.Instance.creatComponentByStylename("ddtstore.equipGhost.ghost");
			HelpBtnEnable.getInstance().addMouseOverTips(_forgeBtn,15);
			HelpBtnEnable.getInstance().addMouseOverTips(_bringUpBtn,15);
			HelpBtnEnable.getInstance().addMouseOverTips(_ghostBtn,15);
			_tabVbox = ComponentFactory.Instance.creatComponentByStylename("ddtstore.BagStoreFrame.TabSelectedBtnContainer");
			PositionUtils.setPos(_tabVbox,"ddtstore.FineStore.VboxPos");
			addChild(_tabVbox);
			_tabVbox.addChild(_forgeBtn);
			_tabVbox.addChild(_bringUpBtn);
			_tabVbox.addChild(_ghostBtn);
			_btnGroup = new SelectedButtonGroup();
			_btnGroup.addEventListener("change",__changeHandler,false,0,true);
			_btnGroup.addSelectItem(_forgeBtn);
			_btnGroup.addSelectItem(_bringUpBtn);
			_btnGroup.addSelectItem(_ghostBtn);
		}
		
		private function __changeHandler(param1:Event) : void
		{
			SoundManager.instance.playButtonSound();
			var _loc2_:String = _forgeGroupType[_btnGroup.selectIndex];
			_tabVbox.arrange();
			if(_btnGroup.selectIndex == 4)
			{
				AssetModuleLoader.addModelLoader(_loc2_,5);
				AssetModuleLoader.addModelLoader("uigeneral",7);
			}
			else
			{
				AssetModuleLoader.addModelLoader(_loc2_,6);
			}
			AssetModuleLoader.startCodeLoader(showView);
		}
		
		private function showView() : void
		{
			if(_forgeView)
			{
				_forgeView.visible = false;
			}
			if(_ghostView)
			{
				_ghostView.visible = false;
			}
			if(_bringUpView)
			{
				ObjectUtils.disposeObject(_bringUpView);
				_bringUpView = null;
				FineBringUpController.getInstance().dispose();
				SocketManager.Instance.out.sendClearStoreBag();
			}
			switch(int(_btnGroup.selectIndex))
			{
				case 0:
					if(!_forgeView)
					{
						_forgeView = new FineForgeView();
						PositionUtils.setPos(_forgeView,"ddtstore.FineStore.ItemViewPos");
						_content.addChild(_forgeView);
					}
					_forgeView.visible = true;
					break;
				case 1:
					if(!_bringUpView)
					{
						_bringUpView = new FineBringUpView();
						PositionUtils.setPos(_bringUpView,"ddtstore.FineStore.ItemViewPos");
						_content.addChild(_bringUpView);
						FineBringUpController.getInstance().setup();
					}
					FineBringUpController.getInstance().usingLock = false;
					SocketManager.Instance.out.sendClearStoreBag();
					_bringUpView.visible = true;
					break;
				case 2:
					SocketManager.Instance.out.sendClearStoreBag();
					if(!_ghostView)
					{
						_ghostView = new FineGhostView(_controller);
						PositionUtils.setPos(_ghostView,"ddtstore.FineStore.ghostViewPos");
						_content.addChild(_ghostView);
					}
					_ghostView.show();
					break;
			}
		}
		
		
		public function dispose() : void
		{
			FineBringUpController.getInstance().dispose();
			_controller = null;
			_bringUpBtn && HelpBtnEnable.getInstance().removeMouseOverTips(_bringUpBtn);
			_forgeBtn && HelpBtnEnable.getInstance().removeMouseOverTips(_forgeBtn);
			_ghostBtn && HelpBtnEnable.getInstance().removeMouseOverTips(_ghostBtn);
			if(this._btnGroup)
			{
				this._btnGroup.removeEventListener("change",this.__changeHandler);
				this._btnGroup.dispose();
				this._btnGroup = null;
			}
			ObjectUtils.disposeAllChildren(_content);
			ObjectUtils.disposeAllChildren(this);
			_tabVbox = null;
		}
	}
}
