package christmas.view.makingSnowmenView
{
   import christmas.info.ChristmasSystemItemsInfo;
   import christmas.items.ChristmasListItem;
   import christmas.manager.ChristmasManager;
   import com.pickgliss.ui.ComponentFactory;
   import com.pickgliss.ui.controls.ScrollPanel;
   import com.pickgliss.ui.controls.container.VBox;
   import com.pickgliss.ui.core.Disposeable;
   import com.pickgliss.utils.ObjectUtils;
   import ddt.events.CrazyTankSocketEvent;
   import ddt.manager.LanguageMgr;
   import flash.display.Sprite;
   import road7th.comm.PackageIn;
   
   public class ChristmasMakingSnowmenRightFrame extends Sprite implements Disposeable
   {
      
      public static var specialItemId:int = 201156;
      
      public static var packsReceiveOK:Boolean;
       
      
      private var _list:VBox;
      
      private var _panel:ScrollPanel;
      
      private var _itemList:Array;
      
      private var SHOP_ITEM_NUM:int = 9;
      
      private var CURRENT_PAGE:int = 1;
      
      private var _shopItemArr:Array;
      
      public function ChristmasMakingSnowmenRightFrame()
      {
         super();
         this.initView();
         this.loadList();
         this.initEvent();
      }
      
      public function get shopItemArr() : Array
      {
         return this._shopItemArr;
      }
      
      public function set itemList(_arg_1:Array) : void
      {
         this._itemList = _arg_1;
      }
      
      public function get itemList() : Array
      {
         return this._itemList;
      }
      
      private function initView() : void
      {
         var _local_2:ChristmasListItem = null;
         var _local_3:int = 0;
         var _local_1:int = 0;
         this._list = ComponentFactory.Instance.creatComponentByStylename("christmas.goodsListBox");
         this._list.spacing = 5;
         this._panel = ComponentFactory.Instance.creatComponentByStylename("christmas.right.scrollpanel");
         this._panel.x = 286;
         this._panel.y = 133;
         this._panel.width = 400;
         this._panel.height = 260;
         this._shopItemArr = new Array();
         this.SHOP_ITEM_NUM = ChristmasManager.instance.model.packsLen;
         this.itemList = new Array();
         while(_local_1 < this.SHOP_ITEM_NUM)
         {
            _local_2 = ComponentFactory.Instance.creatCustomObject("christmas.view.christmasShopItem");
            this.itemList.push(_local_2);
            this.itemList[_local_1].initView(_local_1);
            if(_local_1 <= this.SHOP_ITEM_NUM - 2)
            {
               if(ChristmasManager.instance.CanGetGift(_local_1) && ChristmasManager.instance.model.count >= ChristmasManager.instance.model.snowPackNum[_local_1])
               {
                  this.itemList[_local_1].specialButton();
               }
            }
            else if(ChristmasManager.instance.model.lastPacks > ChristmasManager.instance.model.count)
            {
               this.itemList[_local_1].grayButton();
            }
            else
            {
               this.itemList[_local_1].specialButton();
               if(ChristmasManager.instance.model.count - ChristmasManager.instance.model.snowPackNum[this.SHOP_ITEM_NUM - 2] >= ChristmasManager.instance.model.snowPackNum[this.SHOP_ITEM_NUM - 1] * (ChristmasManager.instance.model.packsNumber + 1))
               {
                  this.itemList[_local_1]._poorTxt.text = LanguageMgr.GetTranslation("christmas.poortTxt.OK.LG");
               }
               else
               {
                  _local_3 = ChristmasManager.instance.model.snowPackNum[this.SHOP_ITEM_NUM - 1] - (ChristmasManager.instance.model.count - (ChristmasManager.instance.model.snowPackNum[ChristmasManager.instance.model.packsLen - 2] + ChristmasManager.instance.model.snowPackNum[this.SHOP_ITEM_NUM - 1] * ChristmasManager.instance.model.packsNumber));
                  this.itemList[_local_1]._poorTxt.text = LanguageMgr.GetTranslation("christmas.list.poorTxt.LG",_local_3);
               }
            }
            this.itemList[_local_1].initText(ChristmasManager.instance.model.snowPackNum[_local_1],_local_1);
            this.itemList[_local_1].y = (this.itemList[_local_1].height + 1) * _local_1;
            this._shopItemArr.push(this.itemList[_local_1]);
            this._list.addChild(this.itemList[_local_1]);
            _local_1++;
         }
         this._panel.setView(this._list);
         addChild(this._panel);
         this._panel.invalidateViewport();
      }
      
      public function loadList() : void
      {
         this.setList(ChristmasManager.instance.model.myGiftData);
      }
      
      public function setList(_arg_1:Vector.<ChristmasSystemItemsInfo>) : void
      {
         var _local_2:int = 0;
         this.clearitems();
         while(_local_2 < this.SHOP_ITEM_NUM)
         {
            if(!_arg_1)
            {
               break;
            }
            if(_local_2 < _arg_1.length && _arg_1[_local_2])
            {
               this.itemList[_local_2].shopItemInfo = _arg_1[_local_2];
               this.itemList[_local_2].itemID = _arg_1[_local_2].TemplateID;
            }
            _local_2++;
         }
      }
      
      private function initEvent() : void
      {
         ChristmasManager.instance.addEventListener(CrazyTankSocketEvent.CHRISTMAS_PACKS,this.playerIsReceivePacks);
      }
      
      private function playerIsReceivePacks(_arg_1:CrazyTankSocketEvent) : void
      {
         var _local_5:int = 0;
         var _local_4:int = 0;
         var _local_2:PackageIn = _arg_1.pkg;
         ChristmasManager.instance.model.awardState = _local_2.readInt();
         ChristmasManager.instance.model.packsNumber = _local_2.readInt();
         var _local_3:int = _local_2.readInt();
         while(_local_4 < this.SHOP_ITEM_NUM)
         {
            if(this.itemList[_local_4].itemID == _local_3 && _local_4 < this.SHOP_ITEM_NUM - 1)
            {
               this.itemList[_local_4].receiveOK();
               packsReceiveOK = true;
               return;
            }
            if(this.itemList[_local_4].itemID == specialItemId && ChristmasManager.instance.model.lastPacks <= ChristmasManager.instance.model.count)
            {
               this.itemList[_local_4].specialButton();
               if(ChristmasManager.instance.model.count - ChristmasManager.instance.model.snowPackNum[this.SHOP_ITEM_NUM - 2] >= ChristmasManager.instance.model.snowPackNum[this.SHOP_ITEM_NUM - 1] * (ChristmasManager.instance.model.packsNumber + 1))
               {
                  this.itemList[_local_4]._poorTxt.text = LanguageMgr.GetTranslation("christmas.poortTxt.OK.LG");
               }
               else
               {
                  _local_5 = ChristmasManager.instance.model.snowPackNum[this.SHOP_ITEM_NUM - 1] - (ChristmasManager.instance.model.count - (ChristmasManager.instance.model.snowPackNum[ChristmasManager.instance.model.packsLen - 2] + ChristmasManager.instance.model.snowPackNum[this.SHOP_ITEM_NUM - 1] * ChristmasManager.instance.model.packsNumber));
                  this.itemList[_local_4]._poorTxt.text = LanguageMgr.GetTranslation("christmas.list.poorTxt.LG",_local_5);
               }
            }
            _local_4++;
         }
      }
      
      private function clearitems() : void
      {
         var _local_1:int = 0;
         while(_local_1 < this.SHOP_ITEM_NUM)
         {
            this.itemList[_local_1].shopItemInfo = null;
            _local_1++;
         }
      }
      
      private function removeEvent() : void
      {
         ChristmasManager.instance.removeEventListener(CrazyTankSocketEvent.CHRISTMAS_PACKS,this.playerIsReceivePacks);
      }
      
      private function disposeItems() : void
      {
         var _local_1:int = 0;
         if(this.itemList)
         {
            _local_1 = 0;
            while(_local_1 < this.itemList.length)
            {
               ObjectUtils.disposeObject(this.itemList[_local_1]);
               this.itemList[_local_1] = null;
               _local_1++;
            }
            this.itemList = null;
         }
      }
      
      public function dispose() : void
      {
         this.removeEvent();
         this.disposeItems();
         ObjectUtils.disposeAllChildren(this._list);
         ObjectUtils.disposeObject(this._list);
         this._list = null;
         ObjectUtils.disposeAllChildren(this._panel);
         ObjectUtils.disposeObject(this._panel);
         this._panel = null;
         if(parent)
         {
            parent.removeChild(this);
         }
      }
   }
}
