package shop.view
{
   import com.pickgliss.ui.UICreatShortcut;
   import com.pickgliss.ui.controls.BaseButton;
   import com.pickgliss.ui.controls.Frame;
   import com.pickgliss.ui.controls.SelectedButtonGroup;
   import com.pickgliss.ui.image.Scale9CornerImage;
   import com.pickgliss.ui.text.FilterFrameText;
   import com.pickgliss.utils.ObjectUtils;
   import ddt.data.goods.ShopItemInfo;
   import ddt.data.player.PlayerInfo;
   import ddt.events.CrazyTankSocketEvent;
   import ddt.events.PlayerPropertyEvent;
   import ddt.manager.LanguageMgr;
   import ddt.manager.MessageTipManager;
   import ddt.manager.PlayerManager;
   import ddt.manager.ShopManager;
   import ddt.manager.SocketManager;
   import ddt.manager.TimeManager;
   import ddt.utils.PositionUtils;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import road7th.comm.PackageIn;
   import road7th.utils.DateUtils;
   import shop.ShopEvent;
   import shop.manager.ShopSaleManager;
   
   public class ShopSaleFrame extends Frame
   {
      
      private static const CELL_COUNT:int = 9;
      
      private static const MIN_PAGE:int = 1;
       
      
      private var _bg:Bitmap;
      
      private var _currentPage:int = 1;
      
      private var _maxPage:int;
      
      private var _timeText:FilterFrameText;
      
      private var _firstPage:BaseButton;
      
      private var _prePageBtn:BaseButton;
      
      private var _nextPageBtn:BaseButton;
      
      private var _endPageBtn:BaseButton;
      
      private var _currentPageTxt:FilterFrameText;
      
      private var currentPage:int = 1;
      
      private var _currentPageTxtBg:Scale9CornerImage;
      
      private var _cellGroup:SelectedButtonGroup;
      
      private var _cellList:Vector.<ShopSaleItemCell>;
      
      private var _cellContainer:Sprite;
      
      private var _moneyText:FilterFrameText;
      
      private var _surplusTime:Number;
      
      private var _timer:Timer;
      
      public function ShopSaleFrame()
      {
         super();
      }
      
      override protected function init() : void
      {
         var _loc1_:int = 0;
         super.init();
         titleText = LanguageMgr.GetTranslation("asset.ddtshop.saleShopTitle");
         this._bg = UICreatShortcut.creatAndAdd("asset.ddtshop.SaleBg",_container);
         this._moneyText = UICreatShortcut.creatTextAndAdd("ddtshop.saleFrameMoneyText",PlayerManager.Instance.Self.Money.toString(),_container);
         this._timeText = UICreatShortcut.creatAndAdd("ddtshop.view.saleTimeText",_container);
         this._firstPage = UICreatShortcut.creatAndAdd("shop.BtnFirstPage",_container);
         PositionUtils.setPos(this._firstPage,"ddtshop.firstPagePos");
         this._prePageBtn = UICreatShortcut.creatAndAdd("shop.BtnPrePage",_container);
         PositionUtils.setPos(this._prePageBtn,"ddtshop.prePageBtnPos");
         this._nextPageBtn = UICreatShortcut.creatAndAdd("shop.BtnNextPage",_container);
         PositionUtils.setPos(this._nextPageBtn,"ddtshop.nextPageBtnPos");
         this._endPageBtn = UICreatShortcut.creatAndAdd("shop.BtnEndPage",_container);
         PositionUtils.setPos(this._endPageBtn,"ddtshop.endPageBtnPos");
         this._currentPageTxtBg = UICreatShortcut.creatAndAdd("shop.CurrentPageInput",_container);
         PositionUtils.setPos(this._currentPageTxtBg,"ddtshop.currentPageTxtBgPos");
         this._currentPageTxt = UICreatShortcut.creatAndAdd("shop.CurrentPage",_container);
         PositionUtils.setPos(this._currentPageTxt,"ddtshop.currentPageTxtPagePos");
         this._cellList = new Vector.<ShopSaleItemCell>(CELL_COUNT);
         this._cellContainer = new Sprite();
         PositionUtils.setPos(this._cellContainer,"ddtshop.cellContainerPos");
         addToContent(this._cellContainer);
         this._cellGroup = new SelectedButtonGroup();
         _loc1_ = 0;
         while(_loc1_ < CELL_COUNT)
         {
            this._cellList[_loc1_] = new ShopSaleItemCell();
            this._cellList[_loc1_].x = (this._cellList[_loc1_].width + 11) * int(_loc1_ % 3);
            this._cellList[_loc1_].y = (this._cellList[_loc1_].height + 11) * int(_loc1_ / 3);
            this._cellGroup.addSelectItem(this._cellList[_loc1_]);
            this._cellContainer.addChild(this._cellList[_loc1_]);
            _loc1_++;
         }
         this.initEvent();
         this.updateSaleGoods();
         this.setTimeView();
      }
      
      private function __pageBtnClick(param1:MouseEvent) : void
      {
         switch(param1.currentTarget)
         {
            case this._firstPage:
               if(this._currentPage != MIN_PAGE)
               {
                  this._currentPage = MIN_PAGE;
                  this.updateSaleGoods();
               }
               break;
            case this._prePageBtn:
               if(--this._currentPage < MIN_PAGE)
               {
                  this._currentPage = this._maxPage;
               }
               this.updateSaleGoods();
               break;
            case this._nextPageBtn:
               if(++this._currentPage > this._maxPage)
               {
                  this._currentPage = MIN_PAGE;
               }
               this.updateSaleGoods();
               break;
            case this._endPageBtn:
               if(this._currentPage != this._maxPage)
               {
                  this._currentPage = this._maxPage;
                  this.updateSaleGoods();
               }
         }
      }
      
      public function updateSaleGoods() : void
      {
         if(!ShopSaleManager.Instance.isOpen)
         {
            MessageTipManager.getInstance().show(LanguageMgr.GetTranslation("asset.ddtshop.saleActivityFinish"));
            this.activityEnd();
            return;
         }
         this._maxPage = int(Math.ceil(ShopSaleManager.Instance.shopSaleList.length / CELL_COUNT));
         this._currentPageTxt.text = this._currentPage + "/" + this._maxPage;
         var _loc1_:Vector.<ShopItemInfo> = ShopManager.Instance.getValidSortedGoodsByList(ShopSaleManager.Instance.shopSaleList,this._currentPage,CELL_COUNT);
         var _loc2_:int = 0;
         while(_loc2_ < CELL_COUNT)
         {
            if(_loc1_.length > _loc2_)
            {
               this._cellList[_loc2_].info = _loc1_[_loc2_];
            }
            else
            {
               this._cellList[_loc2_].info = null;
            }
            _loc2_++;
         }
         SocketManager.Instance.out.sendUpdateGoodsCount();
      }
      
      private function setTimeView() : void
      {
         if(ShopSaleManager.Instance.isOpen)
         {
            this._surplusTime = (DateUtils.decodeDated(this._cellList[0].info.EndDate).time - TimeManager.Instance.Now().time) / 1000;
            this._timeText.text = LanguageMgr.GetTranslation("asset.ddtshop.surplusTime",this.transSecond(this._surplusTime));
            if(this._surplusTime <= 0)
            {
               return;
            }
            this._timer = new Timer(1000);
            this._timer.addEventListener(TimerEvent.TIMER,this.__onUpdateTime);
            this._timer.start();
         }
      }
      
      private function __onUpdateTime(param1:TimerEvent) : void
      {
         this._surplusTime--;
         if(this._surplusTime > 0)
         {
            this._timeText.text = LanguageMgr.GetTranslation("asset.ddtshop.surplusTime",this.transSecond(this._surplusTime));
         }
         else if(this._timer)
         {
            this._timer.stop();
            this._timer.removeEventListener(TimerEvent.TIMER,this.__onUpdateTime);
            this._timer = null;
            this.activityEnd();
         }
      }
      
      private function activityEnd() : void
      {
         var _loc1_:ShopSaleItemCell = null;
         ShopSaleManager.Instance.removeEnterIcon();
         for each(_loc1_ in this._cellList)
         {
            _loc1_.limitNum = 0;
         }
      }
      
      private function transSecond(param1:Number) : String
      {
         var _loc2_:int = Math.floor(param1 / 3600);
         if(_loc2_ > 24)
         {
            return String(Math.ceil(_loc2_ / 24)) + LanguageMgr.GetTranslation("day");
         }
         var _loc3_:int = Math.floor((param1 - _loc2_ * 3600) / 60);
         var _loc4_:int = param1 - _loc2_ * 3600 - _loc3_ * 60;
         return String("0" + _loc2_).substr(-2) + ":" + String("0" + _loc3_).substr(-2) + ":" + String("0" + _loc4_).substr(-2);
      }
      
      private function __onUpdateMoney(param1:PlayerPropertyEvent) : void
      {
         if(param1.changedProperties[PlayerInfo.MONEY])
         {
            this._moneyText.text = PlayerManager.Instance.Self.Money.toString();
         }
      }
      
      private function __updataLimitAreaCountHandler(param1:ShopEvent) : void
      {
         this.updateSaleGoods();
      }
      
      private function __onUpdateLimitCount(param1:CrazyTankSocketEvent) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:PackageIn = param1.pkg;
         var _loc3_:int = _loc2_.readInt();
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(_loc3_ > 0)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc3_)
            {
               _loc4_ = _loc2_.readInt();
               _loc5_ = _loc2_.readInt();
               _loc7_ = 0;
               while(_loc7_ < CELL_COUNT)
               {
                  if(this._cellList[_loc7_].info && _loc4_ == this._cellList[_loc7_].info.TemplateID)
                  {
                     this._cellList[_loc7_].limitNum = this._cellList[_loc7_].info.LimitPersonalCount - _loc5_;
                  }
                  _loc7_++;
               }
               _loc6_++;
            }
         }
      }
      
      private function initEvent() : void
      {
         SocketManager.Instance.addEventListener(CrazyTankSocketEvent.UPDATE_SHOPLIMIT_COUNT,this.__onUpdateLimitCount);
         this._firstPage.addEventListener(MouseEvent.CLICK,this.__pageBtnClick);
         this._prePageBtn.addEventListener(MouseEvent.CLICK,this.__pageBtnClick);
         this._nextPageBtn.addEventListener(MouseEvent.CLICK,this.__pageBtnClick);
         this._endPageBtn.addEventListener(MouseEvent.CLICK,this.__pageBtnClick);
         PlayerManager.Instance.Self.addEventListener(PlayerPropertyEvent.PROPERTY_CHANGE,this.__onUpdateMoney);
         ShopManager.Instance.addEventListener(ShopEvent.UPDATA_LIMITAREACOUNT,this.__updataLimitAreaCountHandler);
      }
      
      private function removeEvent() : void
      {
         SocketManager.Instance.removeEventListener(CrazyTankSocketEvent.UPDATE_SHOPLIMIT_COUNT,this.__onUpdateLimitCount);
         this._firstPage.removeEventListener(MouseEvent.CLICK,this.__pageBtnClick);
         this._prePageBtn.removeEventListener(MouseEvent.CLICK,this.__pageBtnClick);
         this._nextPageBtn.removeEventListener(MouseEvent.CLICK,this.__pageBtnClick);
         this._endPageBtn.removeEventListener(MouseEvent.CLICK,this.__pageBtnClick);
         PlayerManager.Instance.Self.removeEventListener(PlayerPropertyEvent.PROPERTY_CHANGE,this.__onUpdateMoney);
         ShopManager.Instance.removeEventListener(ShopEvent.UPDATA_LIMITAREACOUNT,this.__updataLimitAreaCountHandler);
      }
      
      override public function dispose() : void
      {
         this.removeEvent();
         ShopSaleManager.Instance.goodsBuyMaxNum = 0;
         if(this._timer)
         {
            this._timer.stop();
            this._timer.removeEventListener(TimerEvent.TIMER,this.__onUpdateTime);
            this._timer = null;
         }
         while(this._cellList.length)
         {
            this._cellList.pop();
         }
         this._cellList = null;
         this._cellGroup.dispose();
         this._cellGroup = null;
         ObjectUtils.disposeObject(this._bg);
         this._bg = null;
         ObjectUtils.disposeObject(this._moneyText);
         this._moneyText = null;
         ObjectUtils.disposeObject(this._timeText);
         this._timeText = null;
         ObjectUtils.disposeObject(this._firstPage);
         this._firstPage = null;
         ObjectUtils.disposeObject(this._prePageBtn);
         this._prePageBtn = null;
         ObjectUtils.disposeObject(this._nextPageBtn);
         this._nextPageBtn = null;
         ObjectUtils.disposeObject(this._endPageBtn);
         this._endPageBtn = null;
         super.dispose();
      }
   }
}
