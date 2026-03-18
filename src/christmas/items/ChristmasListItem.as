package christmas.items
{
   import bagAndInfo.cell.CellFactory;
   import christmas.info.ChristmasSystemItemsInfo;
   import christmas.manager.ChristmasManager;
   import com.pickgliss.ui.ComponentFactory;
   import com.pickgliss.ui.controls.BaseButton;
   import com.pickgliss.ui.core.Component;
   import com.pickgliss.ui.core.Disposeable;
   import com.pickgliss.ui.text.FilterFrameText;
   import com.pickgliss.utils.ObjectUtils;
   import ddt.manager.LanguageMgr;
   import ddt.manager.MessageTipManager;
   import ddt.manager.SocketManager;
   import ddt.manager.SoundManager;
   import ddt.utils.PositionUtils;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import shop.view.ShopItemCell;
   
   public class ChristmasListItem extends Sprite implements Disposeable
   {
      
      public static var isCreate:Boolean;
       
      
      private var _info:ChristmasSystemItemsInfo;
      
      private var _bg:Bitmap;
      
      private var _countTxt:FilterFrameText;
      
      private var _itemCell:ShopItemCell;
      
      private var _receiveBtn:BaseButton;
      
      private var _shopItemInfo:ChristmasSystemItemsInfo;
      
      public var _poorTxt:FilterFrameText;
      
      private var _itemID:int;
      
      private var _snowPackNum:int;
      
      private var _receiveOK:Bitmap;
      
      public function ChristmasListItem()
      {
         super();
      }
      
      public function initView(_arg_1:int = 0) : void
      {
         var _local_2:Component = null;
         var _local_3:Component = null;
         this._bg = ComponentFactory.Instance.creatBitmap("christmas.list.Back");
         this._receiveOK = ComponentFactory.Instance.creatBitmap("asset.makingSnowmen.receiveOK");
         this._receiveOK.visible = false;
         this._countTxt = ComponentFactory.Instance.creatComponentByStylename("christmas.list.countTxt");
         this._itemCell = this.creatItemCell();
         this._itemCell.buttonMode = true;
         this._itemCell.cellSize = 46;
         PositionUtils.setPos(this._itemCell,"christmasListItem.cellPos");
         addChild(this._bg);
         addChild(this._countTxt);
         addChild(this._itemCell);
         if(_arg_1 >= ChristmasManager.instance.model.packsLen - 1)
         {
            this._poorTxt = ComponentFactory.Instance.creatComponentByStylename("christmas.list.poorTxt");
            this._receiveBtn = ComponentFactory.Instance.creat("christmas.makingSnowmen.lockBtn");
            _local_2 = ChristmasManager.instance.returnComponentBnt(this._receiveBtn,LanguageMgr.GetTranslation("christmas.receiveBtn.tip"));
            addChild(_local_2);
            addChild(this._poorTxt);
         }
         else
         {
            this._receiveBtn = ComponentFactory.Instance.creat("christmas.makingSnowmen.receiveBtn");
            if(ChristmasManager.instance.CanGetGift(_arg_1) && ChristmasManager.instance.model.snowPackNum[_arg_1] > ChristmasManager.instance.model.count)
            {
               _local_3 = ChristmasManager.instance.returnComponentBnt(this._receiveBtn,LanguageMgr.GetTranslation("christmas.listItem.num"));
               addChild(_local_3);
            }
            else if(ChristmasManager.instance.CanGetGift(_arg_1) && ChristmasManager.instance.model.snowPackNum[_arg_1] <= ChristmasManager.instance.model.count)
            {
               addChild(this._receiveBtn);
            }
            else
            {
               this._receiveOK.visible = true;
               if(this._receiveBtn)
               {
                  ObjectUtils.disposeObject(this._receiveBtn);
                  this._receiveBtn = null;
               }
            }
         }
         addChild(this._receiveOK);
         this.grayButton();
         this.initEvent();
      }
      
      private function initEvent() : void
      {
         if(this._receiveBtn)
         {
            this._receiveBtn.addEventListener(MouseEvent.CLICK,this.__shopViewItemBtnClick);
         }
      }
      
      public function initText(_arg_1:int, _arg_2:int) : void
      {
         this._snowPackNum = _arg_1;
         if(_arg_2 >= ChristmasManager.instance.model.packsLen - 1)
         {
            this._countTxt.text = LanguageMgr.GetTranslation("christmas.list.countTxt.last.LG",_arg_1);
         }
         else
         {
            this._countTxt.text = LanguageMgr.GetTranslation("christmas.list.countTxt.LG",_arg_1);
         }
      }
      
      protected function creatItemCell() : ShopItemCell
      {
         var _local_1:Sprite = new Sprite();
         _local_1.graphics.beginFill(16777215,0);
         _local_1.graphics.drawRect(0,0,46,46);
         _local_1.graphics.endFill();
         return CellFactory.instance.createShopItemCell(_local_1,null,true,true) as ShopItemCell;
      }
      
      private function __shopViewItemBtnClick(_arg_1:MouseEvent) : void
      {
         SoundManager.instance.play("008");
         if(ChristmasManager.instance.model.count < this.snowPackNum)
         {
            MessageTipManager.getInstance().show(LanguageMgr.GetTranslation("christmas.listItem.num"));
            return;
         }
         SocketManager.Instance.out.sendButChristmasGoods(this._shopItemInfo.TemplateID);
      }
      
      public function set shopItemInfo(_arg_1:ChristmasSystemItemsInfo) : void
      {
         if(this._shopItemInfo)
         {
            this._shopItemInfo.removeEventListener(Event.CHANGE,this.__updateShopItem);
         }
         this._shopItemInfo = _arg_1;
         if(this._shopItemInfo)
         {
            this._itemID = this._shopItemInfo.TemplateID;
            this._itemCell.info = this._shopItemInfo.TemplateInfo;
            this._itemCell.buttonMode = true;
            this._shopItemInfo.addEventListener(Event.CHANGE,this.__updateShopItem);
         }
         else
         {
            this._itemCell.info = null;
            this._itemCell.buttonMode = false;
         }
      }
      
      private function __updateShopItem(_arg_1:Event) : void
      {
         this._itemCell.info = this._shopItemInfo.TemplateInfo;
      }
      
      public function receiveOK() : void
      {
         this._receiveOK.visible = true;
         if(this._receiveBtn)
         {
            ObjectUtils.disposeObject(this._receiveBtn);
            this._receiveBtn = null;
         }
      }
      
      public function grayButton() : void
      {
         if(this._receiveBtn)
         {
            this._receiveBtn.mouseChildren = false;
            this._receiveBtn.mouseEnabled = false;
            this._receiveBtn.enable = false;
         }
      }
      
      public function recoverButton() : void
      {
         if(this._receiveBtn)
         {
            this._receiveBtn.mouseChildren = true;
            this._receiveBtn.mouseEnabled = true;
            this._receiveBtn.enable = true;
         }
      }
      
      public function specialButton() : void
      {
         if(this._receiveBtn)
         {
            ObjectUtils.disposeObject(this._receiveBtn);
            this._receiveBtn = null;
         }
         this._receiveBtn = ComponentFactory.Instance.creat("christmas.makingSnowmen.receiveBtn");
         addChild(this._receiveBtn);
         this._receiveBtn.addEventListener(MouseEvent.CLICK,this.__shopViewItemBtnClick);
         this._receiveBtn.mouseChildren = true;
         this._receiveBtn.mouseEnabled = true;
         this._receiveBtn.enable = true;
      }
      
      private function removeEvent() : void
      {
         if(this._receiveBtn)
         {
            this._receiveBtn.removeEventListener(MouseEvent.CLICK,this.__shopViewItemBtnClick);
         }
         if(this._shopItemInfo)
         {
            this._shopItemInfo.removeEventListener(Event.CHANGE,this.__updateShopItem);
         }
      }
      
      public function get itemID() : int
      {
         return this._itemID;
      }
      
      public function set itemID(_arg_1:int) : void
      {
         this._itemID = _arg_1;
      }
      
      public function get snowPackNum() : int
      {
         return this._snowPackNum;
      }
      
      public function dispose() : void
      {
         this.removeEvent();
         ObjectUtils.disposeObject(this._bg);
         this._bg = null;
         ObjectUtils.disposeObject(this._itemCell);
         this._itemCell = null;
         ObjectUtils.disposeObject(this._receiveBtn);
         this._receiveBtn = null;
         this._shopItemInfo = null;
         if(parent)
         {
            parent.removeChild(this);
         }
      }
   }
}
