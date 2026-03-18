package christmas.view.makingSnowmenView
{
   import bagAndInfo.cell.BagCell;
   import christmas.event.ChristmasRoomEvent;
   import christmas.info.ChristmasSystemItemsInfo;
   import christmas.items.ExpBar;
   import christmas.manager.ChristmasManager;
   import com.pickgliss.events.FrameEvent;
   import com.pickgliss.ui.ComponentFactory;
   import com.pickgliss.ui.controls.BaseButton;
   import com.pickgliss.ui.controls.Frame;
   import com.pickgliss.ui.text.FilterFrameText;
   import com.pickgliss.utils.ObjectUtils;
   import ddt.data.BagInfo;
   import ddt.data.goods.ItemTemplateInfo;
   import ddt.data.player.SelfInfo;
   import ddt.events.BagEvent;
   import ddt.manager.ItemManager;
   import ddt.manager.LanguageMgr;
   import ddt.manager.MessageTipManager;
   import ddt.manager.PlayerManager;
   import ddt.manager.SocketManager;
   import ddt.manager.SoundManager;
   import flash.display.Bitmap;
   import flash.events.MouseEvent;
   import org.aswing.KeyboardManager;
   
   public class ChristmasMakingSnowmenFrame extends Frame
   {
       
      
      private var _bg:Bitmap;
      
      private var _bagitem:BagCell;
      
      private var _selfInfo:SelfInfo;
      
      private var _completeText:FilterFrameText;
      
      private var _expBar:ExpBar;
      
      private var _addSnowBnt:BaseButton;
      
      private var _addCountText:FilterFrameText;
      
      private var _activeTimeTxt:FilterFrameText;
      
      private var _conditionTxt:FilterFrameText;
      
      private var _rewardTxt:FilterFrameText;
      
      private var _mSnoRight:ChristmasMakingSnowmenRightFrame;
      
      private var _christmasSnowmenView:ChristmasSnowmenView;
      
      public function ChristmasMakingSnowmenFrame()
      {
         this._selfInfo = PlayerManager.Instance.Self;
         super();
         this.initView();
         this.initEvent();
         this.initText();
      }
      
      private function initView() : void
      {
         titleText = LanguageMgr.GetTranslation("christmas.makingSnowmenTiTle");
         this._bg = ComponentFactory.Instance.creatBitmap("asset.christmas.makingSnowmenImg");
         this._mSnoRight = ComponentFactory.Instance.creatCustomObject("christmas.makingSnowmen.mSnoRightFrame");
         this._completeText = ComponentFactory.Instance.creatComponentByStylename("christmas.makingSnowmen.completeTxt");
         this._addSnowBnt = ComponentFactory.Instance.creat("christmas.makingSnowmen.addSnowBnt");
         this._expBar = ComponentFactory.Instance.creatComponentByStylename("christmas.makingSnowmen.expBar");
         this._addCountText = ComponentFactory.Instance.creatComponentByStylename("christmas.makingSnowmen.addCountText");
         this._activeTimeTxt = ComponentFactory.Instance.creatComponentByStylename("christmas.makingSnowmen.activeTimeTxt");
         this._conditionTxt = ComponentFactory.Instance.creatComponentByStylename("christmas.makingSnowmen.conditionTxt");
         this._rewardTxt = ComponentFactory.Instance.creatComponentByStylename("christmas.makingSnowmen.rewardTxt");
         this._christmasSnowmenView = ComponentFactory.Instance.creatCustomObject("christmas.Snowmen.view");
         addToContent(this._bg);
         addToContent(this._completeText);
         addToContent(this._expBar);
         addToContent(this._addSnowBnt);
         addToContent(this._addCountText);
         addToContent(this._activeTimeTxt);
         addToContent(this._conditionTxt);
         addToContent(this._rewardTxt);
         addToContent(this._christmasSnowmenView);
         addToContent(this._mSnoRight);
         this.goodsCell();
      }
      
      public function get expBar() : ExpBar
      {
         return this._expBar;
      }
      
      private function initText() : void
      {
         this._completeText.text = LanguageMgr.GetTranslation("christmas.makingSnowmen.completeTxt.LG");
         this._addCountText.text = ChristmasManager.instance.model.count + "";
         this._activeTimeTxt.text = ChristmasManager.instance.model.activityTime;
         this._conditionTxt.text = LanguageMgr.GetTranslation("christmas.makingSnowmen.conditionTxt.LG");
         this._rewardTxt.text = LanguageMgr.GetTranslation("christmas.makingSnowmen.rewardTxt.LG");
      }
      
      private function goodsCell() : void
      {
         var _local_1:ItemTemplateInfo = ItemManager.Instance.getTemplateById(201144);
         this._bagitem = new BagCell(0,_local_1);
         this._bagitem.x = 30;
         this._bagitem.y = 389;
         this._bagitem.width = this._bagitem.height = 41;
         addToContent(this._bagitem);
         this.upDatafitCount();
      }
      
      protected function updateCount(_arg_1:BagEvent) : void
      {
         this.upDatafitCount();
      }
      
      public function upDatafitCount() : void
      {
         if(!this._bagitem)
         {
            return;
         }
         var _local_1:BagInfo = this._selfInfo.getBag(BagInfo.PROPBAG);
         var _local_2:int = _local_1.getItemCountByTemplateId(201144);
         this._bagitem.setCount(_local_2);
      }
      
      private function initEvent() : void
      {
         addEventListener(FrameEvent.RESPONSE,this.__responseHandler);
         this._addSnowBnt.addEventListener(MouseEvent.CLICK,this.__onClickAddSnowHander);
         ChristmasManager.instance.addEventListener(ChristmasRoomEvent.SCORE_CONVERT,this.__scoreConvertEventHandler);
      }
      
      private function __onClickAddSnowHander(_arg_1:MouseEvent) : void
      {
         ChristmasManager.instance.showTransactionFrame("",this.showIsBuyFrame,null,this,true,true);
      }
      
      private function showIsBuyFrame(_arg_1:int = 1) : void
      {
         if(_arg_1 <= 0)
         {
            MessageTipManager.getInstance().show(LanguageMgr.GetTranslation("christmas.curInfo.notfitNum"));
            return;
         }
         if(ChristmasManager.instance.getCount() <= 0)
         {
            MessageTipManager.getInstance().show(LanguageMgr.GetTranslation("christmas.curInfo.notfit"));
            return;
         }
         this.sendBuyToSnowPackDouble(_arg_1);
      }
      
      private function sendBuyToSnowPackDouble(_arg_1:int = 1) : void
      {
         var _local_2:Boolean = ChristmasManager.instance.model.isSelect;
         if(_local_2)
         {
            if(!ChristmasManager.instance.checkMoney(_arg_1 * ChristmasManager.instance.model.money))
            {
               SocketManager.Instance.out.sendChristmasUpGrade(_arg_1,_local_2);
               KeyboardManager.getInstance().isStopDispatching = true;
               SoundManager.instance.play("170");
            }
            ChristmasManager.instance.model.isSelect = false;
            return;
         }
         SocketManager.Instance.out.sendChristmasUpGrade(_arg_1,_local_2);
         KeyboardManager.getInstance().isStopDispatching = true;
         SoundManager.instance.play("170");
      }
      
      private function clickCallBack(_arg_1:Boolean) : void
      {
         ChristmasManager.instance.setRemindSnowPackDouble(_arg_1);
      }
      
      private function __scoreConvertEventHandler(_arg_1:ChristmasRoomEvent) : void
      {
         var _local_3:int = 0;
         var _local_2:int = 0;
         this._addCountText.text = ChristmasManager.instance.model.count + "";
         if(this._mSnoRight.shopItemArr == null)
         {
            return;
         }
         while(_local_2 < ChristmasManager.instance.model.packsLen - 1)
         {
            if(ChristmasManager.instance.CanGetGift(_local_2) && ChristmasManager.instance.model.count >= this._mSnoRight.shopItemArr[_local_2].snowPackNum)
            {
               this._mSnoRight.shopItemArr[_local_2].specialButton();
            }
            _local_2++;
         }
         if(ChristmasManager.instance.model.lastPacks > ChristmasManager.instance.model.count)
         {
            this._mSnoRight.shopItemArr[ChristmasManager.instance.model.packsLen - 1].grayButton();
         }
         else
         {
            this._mSnoRight.shopItemArr[ChristmasManager.instance.model.packsLen - 1].specialButton();
            if(ChristmasManager.instance.model.count - ChristmasManager.instance.model.snowPackNum[ChristmasManager.instance.model.packsLen - 2] >= ChristmasManager.instance.model.snowPackNum[ChristmasManager.instance.model.packsLen - 1] * (ChristmasManager.instance.model.packsNumber + 1))
            {
               this._mSnoRight.shopItemArr[ChristmasManager.instance.model.packsLen - 1]._poorTxt.text = LanguageMgr.GetTranslation("christmas.poortTxt.OK.LG");
            }
            else
            {
               _local_3 = ChristmasManager.instance.model.snowPackNum[ChristmasManager.instance.model.packsLen - 1] - (ChristmasManager.instance.model.count - (ChristmasManager.instance.model.snowPackNum[ChristmasManager.instance.model.packsLen - 2] + ChristmasManager.instance.model.snowPackNum[ChristmasManager.instance.model.packsLen - 1] * ChristmasManager.instance.model.packsNumber));
               this._mSnoRight.shopItemArr[ChristmasManager.instance.model.packsLen - 1]._poorTxt.text = LanguageMgr.GetTranslation("christmas.list.poorTxt.LG",_local_3);
            }
         }
      }
      
      public function snowmenAction(_arg_1:ChristmasSystemItemsInfo) : void
      {
         this._christmasSnowmenView.upGradeAction(_arg_1);
      }
      
      private function removeEvent() : void
      {
         removeEventListener(FrameEvent.RESPONSE,this.__responseHandler);
         this._addSnowBnt.removeEventListener(MouseEvent.CLICK,this.__onClickAddSnowHander);
         PlayerManager.Instance.removeEventListener(BagEvent.GEMSTONE_BUG_COUNT,this.updateCount);
         ChristmasManager.instance.removeEventListener(ChristmasRoomEvent.SCORE_CONVERT,this.__scoreConvertEventHandler);
      }
      
      private function __responseHandler(_arg_1:FrameEvent) : void
      {
         if(_arg_1.responseCode == FrameEvent.CLOSE_CLICK || _arg_1.responseCode == FrameEvent.ESC_CLICK)
         {
            SoundManager.instance.play("008");
            this.dispose();
         }
      }
      
      override public function dispose() : void
      {
         this.removeEvent();
         ChristmasManager.instance.model.isSelect = false;
         ObjectUtils.disposeAllChildren(this);
         super.dispose();
         if(this._expBar)
         {
            ObjectUtils.disposeObject(this._expBar);
         }
         this._expBar = null;
         if(this._christmasSnowmenView)
         {
            ObjectUtils.disposeObject(this._christmasSnowmenView);
         }
         this._christmasSnowmenView = null;
      }
   }
}
