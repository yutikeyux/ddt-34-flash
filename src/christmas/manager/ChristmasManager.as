package christmas.manager
{
   import christmas.data.ChristmasPackageType;
   import christmas.event.ChristmasRoomEvent;
   import christmas.info.ChristmasSystemItemsInfo;
   import christmas.items.ExpBar;
   import christmas.loader.LoaderChristmasUIModule;
   import christmas.model.ChristmasModel;
   import christmas.player.PlayerVO;
   import christmas.view.ChristmasChooseRoomFrame;
   import christmas.view.makingSnowmenView.ChristmasMakingSnowmenFrame;
   import christmas.view.makingSnowmenView.SnowPackDoubleFrame;
   import com.pickgliss.ui.ComponentFactory;
   import com.pickgliss.ui.LayerManager;
   import com.pickgliss.ui.controls.BaseButton;
   import com.pickgliss.ui.core.Component;
   import ddt.data.BagInfo;
   import ddt.data.goods.ShopItemInfo;
   import ddt.data.player.SelfInfo;
   import ddt.events.CrazyTankSocketEvent;
   import ddt.manager.GameInSocketOut;
   import ddt.manager.LanguageMgr;
   import ddt.manager.LeavePageManager;
   import ddt.manager.MessageTipManager;
   import ddt.manager.PlayerManager;
   import ddt.manager.SharedManager;
   import ddt.manager.ShopManager;
   import ddt.manager.SocketManager;
   import ddt.manager.SoundManager;
   import ddt.manager.StateManager;
   import ddt.states.StateType;
   import flash.display.Sprite;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import hallIcon.HallIconManager;
   import hallIcon.HallIconType;
   import road7th.comm.PackageIn;
   
   public class ChristmasManager extends EventDispatcher
   {
      
      private static var _instance:ChristmasManager;
      
      public static var isFrameChristmas:Boolean;
      
      public static var isToRoom:Boolean;
      
      public static var isComeRoom:Boolean;
       
      
      private var _self:SelfInfo;
      
      private var _model:ChristmasModel;
      
      private var _isShowIcon:Boolean = false;
      
      private var _makingSnoFrame:ChristmasMakingSnowmenFrame;
      
      private var _christmasResourceId:String;
      
      private var _currentPVE_ID:int;
      
      private var _mapPath:String;
      
      private var _appearPos:Array;
      
      private var _christmasInfo:ChristmasSystemItemsInfo;
      
      private var _snowPackDoubleFrame:SnowPackDoubleFrame;
      
      private var _money:int;
      
      private var _outFun:Function;
      
      private var _goods:ShopItemInfo;
      
      private var _chooseRoomFrame:ChristmasChooseRoomFrame;
      
      public function ChristmasManager(_arg_1:PrivateClass)
      {
         this._appearPos = new Array();
         super();
      }
      
      public static function get instance() : ChristmasManager
      {
         if(ChristmasManager._instance == null)
         {
            ChristmasManager._instance = new ChristmasManager(new PrivateClass());
         }
         return ChristmasManager._instance;
      }
      
      public function setup() : void
      {
         this._model = new ChristmasModel();
         this._self = new SelfInfo();
         SocketManager.Instance.addEventListener(CrazyTankSocketEvent.CHRISTMAS_SYSTEM,this.pkgHandler);
      }
      
      private function pkgHandler(_arg_1:CrazyTankSocketEvent) : void
      {
         var _local_4:CrazyTankSocketEvent = null;
         var _local_2:PackageIn = _arg_1.pkg;
         var _local_3:int = _arg_1._cmd;
		 SocketManager.Instance.out.sendErrorMsg("_local_3: " + _local_3);
         switch(_local_3)
         {
            case ChristmasPackageType.CHRISTMAS_OPENORCLOSE:
               this.openOrclose(_local_2);
               break;
            case ChristmasPackageType.CHRISTMAS_PLAYERING_SNOWMAN_ENTER:
               this.enterChristmasGame(_local_2);
               break;
            case ChristmasPackageType.CHRISTMAS_MAKING_SNOWMAN_ENTER:
               this.makingSnowmanEnter(_local_2);
               break;
            case ChristmasPackageType.FIGHT_SPIRIT_LEVELUP:
               this.snowIsUpdata(_local_2);
               break;
            case ChristmasPackageType.CHRISTMAS_PACKS:
               _local_4 = new CrazyTankSocketEvent(CrazyTankSocketEvent.CHRISTMAS_PACKS,_local_2);
               break;
            case ChristmasPackageType.GET_PAKCS_TO_PLAYER:
               _local_4 = new CrazyTankSocketEvent(CrazyTankSocketEvent.GET_PAKCS_TO_PLAYER,_local_2);
               break;
            case ChristmasPackageType.PLAYER_STATUE:
               _local_4 = new CrazyTankSocketEvent(CrazyTankSocketEvent.PLAYER_STATUE,_local_2);
               break;
            case ChristmasPackageType.MOVE:
               _local_4 = new CrazyTankSocketEvent(CrazyTankSocketEvent.CHRISTMAS_MOVE,_local_2);
               break;
            case ChristmasPackageType.ADDPLAYER:
               _local_4 = new CrazyTankSocketEvent(CrazyTankSocketEvent.ADDPLAYER_ROOM,_local_2);
               break;
            case ChristmasPackageType.CHRISTMAS_EXIT:
               _local_4 = new CrazyTankSocketEvent(CrazyTankSocketEvent.CHRISTMAS_EXIT,_local_2);
               break;
            case ChristmasPackageType.CHRISTMAS_MONSTER:
               _local_4 = new CrazyTankSocketEvent(CrazyTankSocketEvent.CHRISTMAS_MONSTER,_local_2);
               break;
            case ChristmasPackageType.CHRISTMAS_ROOM_SPEAK:
               _local_4 = new CrazyTankSocketEvent(CrazyTankSocketEvent.CHRISTMAS_ROOM_SPEAK,_local_2);
               break;
            case ChristmasPackageType.UPDATE_TIMES_ROOM:
               _local_4 = new CrazyTankSocketEvent(CrazyTankSocketEvent.UPDATE_TIMES_ROOM,_local_2);
         }
         if(_local_4)
         {
            dispatchEvent(_local_4);
         }
      }
      
      private function enterChristmasGame(_arg_1:PackageIn) : void
      {
         this._goods = ShopManager.Instance.getGoodsByTemplateID(201145);
         this._model.isEnter = _arg_1.readBoolean();
         if(this._model.isEnter)
         {
            this._model.gameBeginTime = _arg_1.readDate();
            this._model.gameEndTime = _arg_1.readDate();
            this._model.count = _arg_1.readInt();
            this.playingSnowmanEnter();
         }
         else
         {
            this.showTransactionFrame(LanguageMgr.GetTranslation("christmas.buy.playingSnowman.volumes",this._goods.AValue1),this.buyPlayingSnowmanVolumes,null,null,false,false,1);
         }
      }
      
      private function buyPlayingSnowmanVolumes(_arg_1:int = 0) : void
      {
         if(!this.checkMoney(this._goods.AValue1))
         {
            SocketManager.Instance.out.sendBuyPlayingSnowmanVolumes();
         }
      }
      
      public function playingSnowmanEnter() : void
      {
         this._mapPath = LoaderChristmasUIModule.Instance.getChristmasResource() + "/map/ChristmasMap.swf";
         this._christmasInfo.playerDefaultPos = new Point(500,500);
         this._christmasInfo.myPlayerVO.playerPos = this._christmasInfo.playerDefaultPos;
         this._christmasInfo.myPlayerVO.playerStauts = 0;
         LoaderChristmasUIModule.Instance.loadMap();
      }
      
      private function snowIsUpdata(_arg_1:PackageIn) : void
      {
         var _local_2:ChristmasSystemItemsInfo = new ChristmasSystemItemsInfo();
         _local_2.isUp = _arg_1.readBoolean();
         this._model.count = _arg_1.readInt();
         this._model.exp = _arg_1.readInt();
         _local_2.num = _arg_1.readInt();
         _local_2.snowNum = _arg_1.readInt();
         if(this._makingSnoFrame)
         {
            this._makingSnoFrame.upDatafitCount();
            this._makingSnoFrame.snowmenAction(_local_2);
            dispatchEvent(new ChristmasRoomEvent(ChristmasRoomEvent.SCORE_CONVERT));
         }
      }
      
      private function makingSnowmanEnter(_arg_1:PackageIn) : void
      {
         this._model.count = _arg_1.readInt();
         this._model.exp = _arg_1.readInt();
         this._model.totalExp = 10;
         this._model.awardState = _arg_1.readInt();
         this._model.packsNumber = _arg_1.readInt();
         this._makingSnoFrame = ComponentFactory.Instance.creatComponentByStylename("chooseRoom.christmas.ChristmasMakingSnowmenFrame");
         LayerManager.Instance.addToLayer(this._makingSnoFrame,LayerManager.GAME_DYNAMIC_LAYER,true,LayerManager.BLCAK_BLOCKGOUND);
      }
      
      private function openOrclose(_arg_1:PackageIn) : void
      {
         var _local_2:Vector.<ChristmasSystemItemsInfo> = null;
         var _local_3:int = 0;
         var _local_4:ChristmasSystemItemsInfo = null;
         this._model.isOpen = _arg_1.readBoolean();
         if(this._model.isOpen)
         {
            this._model.beginTime = _arg_1.readDate();
            this._model.endTime = _arg_1.readDate();
            this._model.packsLen = _arg_1.readInt();
            this._model.snowPackNum = new Array();
            _local_2 = new Vector.<ChristmasSystemItemsInfo>();
            _local_3 = 0;
            while(_local_3 < this._model.packsLen)
            {
               _local_4 = new ChristmasSystemItemsInfo();
               _local_4.TemplateID = _arg_1.readInt();
               _local_2.push(_local_4);
               this._model.snowPackNum[_local_3] = _arg_1.readInt();
               _local_3++;
            }
            this._model.lastPacks = _arg_1.readInt();
            this._model.money = _arg_1.readInt();
            this._model.myGiftData = _local_2;
         }
		 SocketManager.Instance.out.sendErrorMsg("isOpen: " + this._model.isOpen);
         if(this._model.isOpen)
         {
            this.showEnterIcon();
         }
         else
         {
            this.hideEnterIcon();
            if(StateManager.currentStateType == StateType.CHRISTMAS || StateManager.currentStateType == StateType.CHRISTMAS_ROOM)
            {
               StateManager.setState(StateType.MAIN);
            }
         }
      }
      
      public function getBagSnowPacksCount() : int
      {
         var _local_1:SelfInfo = PlayerManager.Instance.Self;
         var _local_2:BagInfo = _local_1.getBag(BagInfo.PROPBAG);
         return _local_2.getItemCountByTemplateId(201144);
      }
      
      public function showEnterIcon() : void
      {
         this._isShowIcon = true;
         HallIconManager.instance.updateSwitchHandler(HallIconType.CHRISTMAS,true);
         this._christmasInfo = new ChristmasSystemItemsInfo();
         this._christmasInfo.myPlayerVO = new PlayerVO();
      }
      
      public function onClickChristmasIcon(_arg_1:MouseEvent) : void
      {
         SoundManager.instance.playButtonSound();
         if(PlayerManager.Instance.Self.Grade < 10)
         {
            MessageTipManager.getInstance().show(LanguageMgr.GetTranslation("christmas.Icon.NoEnter"));
            return;
         }
         if(StateManager.currentStateType == StateType.MAIN)
         {
            LoaderChristmasUIModule.Instance.loadUIModule(this.doOpenChristmasFrame);
         }
      }
      
      private function doOpenChristmasFrame() : void
      {
         if(this._isShowIcon)
         {
            this._chooseRoomFrame = ComponentFactory.Instance.creatComponentByStylename("chooseRoom.christmas.ChristmasChooseRoomFrame");
            LayerManager.Instance.addToLayer(this._chooseRoomFrame,LayerManager.GAME_DYNAMIC_LAYER,true,LayerManager.BLCAK_BLOCKGOUND);
         }
      }
      
      public function get expBar() : ExpBar
      {
         return this._makingSnoFrame.expBar;
      }
      
      public function get christmasInfo() : ChristmasSystemItemsInfo
      {
         return this._christmasInfo;
      }
      
      public function getCount() : int
      {
         var _local_1:SelfInfo = PlayerManager.Instance.Self;
         var _local_2:BagInfo = _local_1.getBag(BagInfo.PROPBAG);
         return _local_2.getItemCountByTemplateId(201144);
      }
      
      public function showTransactionFrame(_arg_1:String, _arg_2:Function = null, _arg_3:Function = null, _arg_4:Sprite = null, _arg_5:Boolean = true, _arg_6:Boolean = false, _arg_7:int = 0) : void
      {
         this._snowPackDoubleFrame = ComponentFactory.Instance.creatComponentByStylename("christmas.views.SnowPackDoubleFrame");
         this._snowPackDoubleFrame.setTxt(_arg_1);
         this._snowPackDoubleFrame.buyFunction = _arg_2;
         this._snowPackDoubleFrame.clickFunction = _arg_3;
         this._snowPackDoubleFrame.setIsShow(_arg_5,_arg_7);
         this._snowPackDoubleFrame.initAddView(_arg_6);
         this._snowPackDoubleFrame.target = _arg_4;
         LayerManager.Instance.addToLayer(this._snowPackDoubleFrame,LayerManager.GAME_DYNAMIC_LAYER,true,LayerManager.ALPHA_BLOCKGOUND);
      }
      
      public function setRemindSnowPackDouble(_arg_1:Boolean) : void
      {
         SharedManager.Instance.isRemindSnowPackDouble = _arg_1;
      }
      
      public function getRemindSnowPackDouble() : Boolean
      {
         return SharedManager.Instance.isRemindSnowPackDouble;
      }
      
      public function checkMoney(_arg_1:int) : Boolean
      {
         this._money = _arg_1;
         if(PlayerManager.Instance.Self.Money < _arg_1)
         {
            LeavePageManager.showFillFrame();
            return true;
         }
         return false;
      }
      
      private function hideEnterIcon() : void
      {
         this._isShowIcon = false;
         this.disposeEnterIcon();
      }
      
      public function disposeEnterIcon() : void
      {
         if(this._makingSnoFrame)
         {
            this._makingSnoFrame.dispose();
            this._makingSnoFrame = null;
         }
         if(this._chooseRoomFrame)
         {
            this._chooseRoomFrame.dispose();
            this._chooseRoomFrame = null;
         }
         if(this._snowPackDoubleFrame)
         {
            this._snowPackDoubleFrame.dispose();
            this._snowPackDoubleFrame = null;
         }
         HallIconManager.instance.updateSwitchHandler(HallIconType.CHRISTMAS,false);
      }
      
      public function returnComponentBnt(_arg_1:BaseButton, _arg_2:String) : Component
      {
         var _local_3:Component = null;
         _local_3 = new Component();
         _local_3.tipData = _arg_2;
         _local_3.tipDirctions = "0,1,2";
         _local_3.tipStyle = "ddt.view.tips.OneLineTip";
         _local_3.tipGapH = 20;
         _local_3.width = _arg_1.width;
         _local_3.x = _arg_1.x;
         _local_3.y = _arg_1.y;
         _arg_1.x = 0;
         _arg_1.y = 0;
         _local_3.addChild(_arg_1);
         return _local_3;
      }
      
      public function exitGame() : void
      {
         GameInSocketOut.sendGamePlayerExit();
      }
      
      public function CanGetGift(_arg_1:int) : Boolean
      {
         return (ChristmasManager.instance.model.awardState >> _arg_1 & 1) == 0;
      }
      
      public function get model() : ChristmasModel
      {
         return this._model;
      }
      
      public function get mapPath() : String
      {
         return this._mapPath;
      }
   }
}

class PrivateClass
{
    
   
   function PrivateClass()
   {
      super();
   }
}
