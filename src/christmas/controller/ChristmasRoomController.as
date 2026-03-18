package christmas.controller
{
   import christmas.event.ChristmasRoomEvent;
   import christmas.info.MonsterInfo;
   import christmas.manager.ChristmasManager;
   import christmas.model.ChristmasRoomModel;
   import christmas.player.PlayerVO;
   import christmas.view.playingSnowman.ChristmasRoomView;
   import christmas.view.playingSnowman.WaitingChristmasView;
   import com.pickgliss.loader.BaseLoader;
   import com.pickgliss.loader.LoaderManager;
   import com.pickgliss.loader.QueueLoader;
   import com.pickgliss.manager.CacheSysManager;
   import com.pickgliss.ui.LayerManager;
   import com.pickgliss.utils.ObjectUtils;
   import ddt.constants.CacheConsts;
   import ddt.data.player.PlayerInfo;
   import ddt.events.CrazyTankSocketEvent;
   import ddt.manager.InviteManager;
   import ddt.manager.KeyboardShortcutsManager;
   import ddt.manager.PathManager;
   import ddt.manager.PlayerManager;
   import ddt.manager.SocketManager;
   import ddt.manager.StateManager;
   import ddt.states.BaseStateView;
   import ddt.states.StateType;
   import ddt.view.MainToolBar;
   import flash.events.Event;
   import flash.geom.Point;
   //import hall.GameLoadingManager;
   import road7th.comm.PackageIn;
   import road7th.data.DictionaryData;
   
   public class ChristmasRoomController extends BaseStateView
   {
      
      private static var _instance:ChristmasRoomController;
      
      private static var _isFirstCome:Boolean = true;
      
      public static var isTimeOver:Boolean;
       
      
      private var _sceneModel:ChristmasRoomModel;
      
      private var _view:ChristmasRoomView;
      
      private var _waitingView:WaitingChristmasView;
      
      protected var _monsters:DictionaryData;
      
      private var _monsterCount:int = 0;
      
      private var _callback:Function;
      
      private var _callbackArg:int;
      
      public function ChristmasRoomController()
      {
         super();
      }
      
      public static function get Instance() : ChristmasRoomController
      {
         if(!_instance)
         {
            _instance = new ChristmasRoomController();
         }
         return _instance;
      }
      
      override public function enter(_arg_1:BaseStateView, _arg_2:Object = null) : void
      {
         InviteManager.Instance.enabled = false;
         CacheSysManager.lock(CacheConsts.CHRISTMAS_IN_ROOM);
         KeyboardShortcutsManager.Instance.forbiddenFull();
         //GameLoadingManager.Instance.hide();
         super.enter(_arg_1,_arg_2);
         LayerManager.Instance.clearnGameDynamic();
         LayerManager.Instance.clearnStageDynamic();
         MainToolBar.Instance.hide();
         this.addEvent();
         this.setSelfStatus(0);
         if(ChristmasManager.isToRoom)
         {
            SocketManager.Instance.out.enterChristmasRoom(ChristmasManager.instance.christmasInfo.myPlayerVO.playerPos);
         }
         else
         {
            SocketManager.Instance.out.enterChristmasRoom(ChristmasManager.instance.christmasInfo.playerDefaultPos);
         }
         if(_isFirstCome)
         {
            this.init();
            _isFirstCome = false;
         }
         else if(this._view)
         {
            this._view.setViewAgain();
         }
         if(this._callback != null)
         {
            this._callback(this._callbackArg);
         }
      }
      
      private function init() : void
      {
         this._sceneModel = new ChristmasRoomModel();
         this._view = new ChristmasRoomView(this,this._sceneModel);
         this._view.show();
         this._waitingView = new WaitingChristmasView();
         addChild(this._waitingView);
         this._waitingView.visible = false;
         this._waitingView.addEventListener(ChristmasRoomEvent.ENTER_GAME_TIME_OUT,this.__onTimeOut);
      }
      
      protected function __onTimeOut(_arg_1:Event) : void
      {
         this._waitingView.stop();
         this._waitingView.visible = false;
         ChristmasManager.instance.exitGame();
      }
      
      private function addEvent() : void
      {
         ChristmasManager.instance.addEventListener(CrazyTankSocketEvent.ADDPLAYER_ROOM,this.__addPlayer);
         ChristmasManager.instance.addEventListener(CrazyTankSocketEvent.CHRISTMAS_MOVE,this.__movePlayer);
         ChristmasManager.instance.addEventListener(CrazyTankSocketEvent.PLAYER_STATUE,this.__updatePlayerStauts);
         ChristmasManager.instance.addEventListener(CrazyTankSocketEvent.CHRISTMAS_EXIT,this.__removePlayer);
         ChristmasManager.instance.addEventListener(CrazyTankSocketEvent.CHRISTMAS_MONSTER,this.__monstersEvent);
      }
      
      public function __updatePlayerStauts(_arg_1:CrazyTankSocketEvent) : void
      {
         var _local_2:PackageIn = _arg_1.pkg;
         var _local_3:int = _local_2.readInt();
         var _local_4:int = _local_2.readByte();
         var _local_5:Point = new Point(_local_2.readInt(),_local_2.readInt());
         this._view.updatePlayerStauts(_local_3,_local_4,_local_5);
         this._sceneModel.updatePlayerStauts(_local_3,_local_4,_local_5);
      }
      
      private function __monstersEvent(_arg_1:CrazyTankSocketEvent) : void
      {
         var _local_6:int = 0;
         var _local_7:MonsterInfo = null;
         var _local_8:int = 0;
         var _local_9:MonsterInfo = null;
         var _local_10:int = 0;
         var _local_11:int = 0;
         var _local_12:int = 0;
         var _local_13:int = 0;
         var _local_14:int = 0;
         var _local_15:int = 0;
         var _local_16:int = 0;
         var _local_17:int = 0;
         var _local_2:QueueLoader = new QueueLoader();
         var _local_3:PackageIn = _arg_1.pkg;
         var _local_4:int = _local_3.readByte();
         var _local_5:String = "";
         if(_local_4 == 0)
         {
            this._monsterCount = _local_3.readInt();
            _local_6 = 0;
            while(_local_6 < this._monsterCount)
            {
               _local_7 = new MonsterInfo();
               _local_7.ID = _local_3.readInt();
               _local_7.type = _local_3.readInt();
               switch(_local_7.type)
               {
                  case 0:
                     _local_7.ActionMovieName = "game.living.Living0012";
                     _local_7.MissionID = 3101;
                     _local_5 = "living1";
                     break;
                  case 1:
                     _local_7.ActionMovieName = "game.living.Living0014";
                     _local_7.MissionID = 3102;
                     _local_5 = "living2";
                     break;
                  case 2:
                     _local_7.ActionMovieName = "game.living.Living0013";
                     _local_7.MissionID = 3103;
                     _local_5 = "living3";
                     break;
               }
               _local_7.MonsterName = "";
               _local_7.State = _local_3.readInt();
               _local_7.MonsterPos = new Point(_local_3.readInt(),_local_3.readInt());
               if(_local_7.State != MonsterInfo.DEAD && !this._sceneModel._mapObjects.hasKey(_local_7.ID))
               {
                  _local_2.addLoader(LoaderManager.Instance.creatLoader(PathManager.solveChristmasMonsterPath(_local_5),BaseLoader.MODULE_LOADER));
                  this._sceneModel._mapObjects.add(_local_7.ID,_local_7);
               }
               _local_6++;
            }
            _local_2.addEventListener(Event.COMPLETE,this.__onLoadComplete);
            _local_2.start();
         }
         else if(_local_4 == 1)
         {
            _local_8 = _local_3.readInt();
            for each(_local_9 in this._sceneModel._mapObjects)
            {
               if(_local_9.ID == _local_8)
               {
                  this._sceneModel._mapObjects.remove(_local_9.ID);
               }
            }
         }
         else if(_local_4 == 2)
         {
            _local_10 = _local_3.readInt();
            _local_11 = 0;
            while(_local_11 < _local_10)
            {
               _local_12 = _local_3.readInt();
               _local_13 = _local_3.readInt();
               _local_14 = _local_3.readInt();
               _local_15 = _local_3.readInt();
               if(this._sceneModel._mapObjects && this._sceneModel._mapObjects.hasKey(_local_12) && this._sceneModel._mapObjects[_local_12].State != 1)
               {
                  this._sceneModel._mapObjects[_local_12].State = _local_15;
                  this._sceneModel._mapObjects[_local_12].MonsterNewPos = new Point(_local_13,_local_14);
               }
               _local_11++;
            }
         }
         else if(_local_4 == 3)
         {
            _local_16 = _local_3.readInt();
            _local_17 = _local_3.readInt();
            if(this._sceneModel._mapObjects && this._sceneModel._mapObjects.hasKey(_local_16))
            {
               this._sceneModel._mapObjects[_local_16].State = _local_17;
            }
         }
      }
      
      private function __onLoadComplete(_arg_1:Event) : void
      {
         var _local_2:QueueLoader = _arg_1.currentTarget as QueueLoader;
         if(_local_2.completeCount == this._monsterCount)
         {
            _local_2.removeEvent();
         }
      }
      
      public function setSelfStatus(_arg_1:int) : void
      {
         if(this._view)
         {
            this._view.updateSelfStatus(_arg_1);
         }
         else
         {
            this._callback = this.setSelfStatus;
            this._callbackArg = _arg_1;
         }
      }
      
      private function removeEvent() : void
      {
         ChristmasManager.instance.removeEventListener(CrazyTankSocketEvent.ADDPLAYER_ROOM,this.__addPlayer);
         ChristmasManager.instance.removeEventListener(CrazyTankSocketEvent.CHRISTMAS_MOVE,this.__movePlayer);
         ChristmasManager.instance.removeEventListener(CrazyTankSocketEvent.CHRISTMAS_EXIT,this.__removePlayer);
         ChristmasManager.instance.removeEventListener(CrazyTankSocketEvent.CHRISTMAS_MONSTER,this.__monstersEvent);
         ChristmasManager.instance.removeEventListener(CrazyTankSocketEvent.PLAYER_STATUE,this.__updatePlayerStauts);
         if(this._waitingView)
         {
            this._waitingView.removeEventListener(ChristmasRoomEvent.ENTER_GAME_TIME_OUT,this.__onTimeOut);
         }
      }
      
      override public function getBackType() : String
      {
         return StateType.MAIN;
      }
      
      public function __addPlayer(_arg_1:CrazyTankSocketEvent) : void
      {
         var _local_5:PlayerInfo = null;
         var _local_6:int = 0;
         var _local_7:int = 0;
         var _local_8:PlayerVO = null;
         var _local_4:int = 0;
         var _local_2:PackageIn = _arg_1.pkg;
         var _local_3:int = _local_2.readInt();
         while(_local_4 < _local_3)
         {
            _local_5 = new PlayerInfo();
            _local_5.beginChanges();
            _local_5.Grade = _local_2.readInt();
            _local_5.Hide = _local_2.readInt();
            _local_5.Repute = _local_2.readInt();
            _local_5.ID = _local_2.readInt();
            _local_5.NickName = _local_2.readUTF();
            _local_5.typeVIP = _local_2.readByte();
            _local_5.VIPLevel = _local_2.readInt();
            _local_5.Sex = _local_2.readBoolean();
            _local_5.Style = _local_2.readUTF();
            _local_5.Colors = _local_2.readUTF();
            _local_5.Skin = _local_2.readUTF();
            _local_5.FightPower = _local_2.readInt();
            _local_5.WinCount = _local_2.readInt();
            _local_5.TotalCount = _local_2.readInt();
            _local_5.Offer = _local_2.readInt();
            _local_5.commitChanges();
            _local_6 = _local_2.readInt();
            _local_7 = _local_2.readInt();
            _local_8 = new PlayerVO();
            _local_8.playerInfo = _local_5;
            _local_8.playerPos = new Point(_local_6,_local_7);
            _local_8.playerStauts = _local_2.readByte();
            if(_local_5.ID != PlayerManager.Instance.Self.ID)
            {
               this._sceneModel.addPlayer(_local_8);
            }
            _local_4++;
         }
      }
      
      public function __removePlayer(_arg_1:CrazyTankSocketEvent) : void
      {
         var _local_2:int = _arg_1.pkg.readInt();
         if(_local_2 == PlayerManager.Instance.Self.ID)
         {
            if(StateManager.currentStateType == StateType.CHRISTMAS_ROOM)
            {
               this._view.removeTimer();
               StateManager.setState(StateType.MAIN);
            }
            else
            {
               isTimeOver = true;
               this._view.removeTimer();
            }
         }
         this._sceneModel.removePlayer(_local_2);
      }
      
      public function __movePlayer(_arg_1:CrazyTankSocketEvent) : void
      {
         var _local_9:Point = null;
         var _local_8:uint = 0;
         var _local_2:int = _arg_1.pkg.readInt();
         var _local_3:int = _arg_1.pkg.readInt();
         var _local_4:int = _arg_1.pkg.readInt();
         var _local_5:String = _arg_1.pkg.readUTF();
         if(_local_2 == PlayerManager.Instance.Self.ID)
         {
            return;
         }
         var _local_6:Array = _local_5.split(",");
         var _local_7:Array = [];
         while(_local_8 < _local_6.length)
         {
            _local_9 = new Point(_local_6[_local_8],_local_6[_local_8 + 1]);
            _local_7.push(_local_9);
            _local_8 += 2;
         }
         if(this._view == null)
         {
            if(this._sceneModel == null)
            {
               this._sceneModel = new ChristmasRoomModel();
            }
            this._view = new ChristmasRoomView(this,this._sceneModel);
            this._view.show();
         }
         this._view.movePlayer(_local_2,_local_7);
      }
      
      override public function getType() : String
      {
         return StateType.CHRISTMAS_ROOM;
      }
      
      override public function leaving(_arg_1:BaseStateView) : void
      {
         InviteManager.Instance.enabled = true;
         CacheSysManager.unlock(CacheConsts.CHRISTMAS_IN_ROOM);
         CacheSysManager.getInstance().release(CacheConsts.CHRISTMAS_IN_ROOM);
         KeyboardShortcutsManager.Instance.cancelForbidden();
         super.leaving(_arg_1);
      }
      
      override public function dispose() : void
      {
         this.removeEvent();
         if(this._sceneModel)
         {
            this._sceneModel.dispose();
         }
         ObjectUtils.disposeAllChildren(this);
         this._view = null;
         this._sceneModel = null;
         CacheSysManager.unlock(CacheConsts.CHRISTMAS_IN_ROOM);
         CacheSysManager.getInstance().release(CacheConsts.CHRISTMAS_IN_ROOM);
         _isFirstCome = true;
         ChristmasManager.isToRoom = false;
      }
   }
}
