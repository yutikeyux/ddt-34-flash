package christmas.view.playingSnowman
{
   import christmas.controller.ChristmasRoomController;
   import christmas.loader.LoaderChristmasUIModule;
   import christmas.manager.ChristmasManager;
   import christmas.model.ChristmasRoomModel;
   import church.vo.SceneMapVO;
   import com.pickgliss.ui.ComponentFactory;
   import com.pickgliss.ui.core.Disposeable;
   import com.pickgliss.ui.text.FilterFrameText;
   import com.pickgliss.utils.ClassUtils;
   import com.pickgliss.utils.ObjectUtils;
   import ddt.events.CrazyTankSocketEvent;
   import ddt.manager.ChatManager;
   import ddt.manager.LanguageMgr;
   import ddt.manager.SoundManager;
   import ddt.manager.StateManager;
   import ddt.manager.TimeManager;
   import ddt.states.StateType;
   import ddt.view.chat.ChatView;
   import ddt.view.scenePathSearcher.PathMapHitTester;
   import ddt.view.scenePathSearcher.SceneScene;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   import road7th.comm.PackageIn;
   
   public class ChristmasRoomView extends Sprite implements Disposeable
   {
      
      public static const MAP_SIZEII:Array = [1738,1300];
       
      
      private var _contoller:ChristmasRoomController;
      
      private var _model:ChristmasRoomModel;
      
      private var _sceneScene:SceneScene;
      
      private var _sceneMap:ChristmasScneneMap;
      
      private var _chatFrame:ChatView;
      
      private var _roomMenuView:RoomMenuView;
      
      private var _snowPackNumImg:Bitmap;
      
      private var _snowPackNumTxt:FilterFrameText;
      
      private var _activeTimeTxt:FilterFrameText;
      
      private var _timer:Timer;
      
      public function ChristmasRoomView(_arg_1:ChristmasRoomController, _arg_2:ChristmasRoomModel)
      {
         super();
         this._contoller = _arg_1;
         this._model = _arg_2;
         this.initialize();
      }
      
      public function show() : void
      {
         this._contoller.addChild(this);
      }
      
      private function initialize() : void
      {
         SoundManager.instance.playMusic("christmasRoom");
         this._sceneScene = new SceneScene();
         ChatManager.Instance.state = ChatManager.CHAT_CHRISTMAS_ROOM;
         this._chatFrame = ChatManager.Instance.view;
         this._chatFrame.output.isLock = true;
         addChild(this._chatFrame);
         ChatManager.Instance.setFocus();
         ChatManager.Instance.lock = true;
         this._snowPackNumImg = ComponentFactory.Instance.creatBitmap("asset.christmas.snowpacknum");
         this._snowPackNumTxt = ComponentFactory.Instance.creatComponentByStylename("christmas.christmasRoom.snowPackNumTxt");
         this._activeTimeTxt = ComponentFactory.Instance.creatComponentByStylename("christmas.christmasRoom.activeTimeTxt");
         this._snowPackNumTxt.text = ChristmasManager.instance.getBagSnowPacksCount() + "";
         addChild(this._snowPackNumImg);
         addChild(this._snowPackNumTxt);
         addChild(this._activeTimeTxt);
         this._roomMenuView = ComponentFactory.Instance.creat("christmas.room.menuView");
         addChild(this._roomMenuView);
         this._roomMenuView.addEventListener(Event.CLOSE,this._leaveRoom);
         this.flushTip();
         this.setMap();
         this.firestGetTime();
         this.addEvent();
      }
      
      private function addEvent() : void
      {
         ChristmasManager.instance.addEventListener(CrazyTankSocketEvent.UPDATE_TIMES_ROOM,this.__updateRoomTimes);
      }
      
      private function removeEvent() : void
      {
         ChristmasManager.instance.removeEventListener(CrazyTankSocketEvent.UPDATE_TIMES_ROOM,this.__updateRoomTimes);
      }
      
      private function __updateRoomTimes(_arg_1:CrazyTankSocketEvent) : void
      {
         var _local_2:PackageIn = _arg_1.pkg;
         var _local_3:Date = _local_2.readDate();
         ChristmasManager.instance.model.gameEndTime = _local_2.readDate();
         ChristmasScneneMap.packsNum = 2;
         this.firestGetTime();
      }
      
      public function removeTimer() : void
      {
         this._sceneMap.stopAllTimer();
      }
      
      public function setViewAgain() : void
      {
         SoundManager.instance.playMusic("christmasRoom");
         ChatManager.Instance.state = ChatManager.CHAT_CHRISTMAS_ROOM;
         this._chatFrame = ChatManager.Instance.view;
         addChild(this._chatFrame);
         ChatManager.Instance.setFocus();
         ChatManager.Instance.lock = true;
         this._chatFrame.output.isLock = true;
         this._sceneMap.enterIng = false;
         this.firestGetTime();
      }
      
      private function flushTip() : void
      {
         this._timer = new Timer(60000,0);
         this._timer.addEventListener(TimerEvent.TIMER,this.updateTip);
         this._timer.start();
      }
      
      private function updateTip(_arg_1:TimerEvent) : void
      {
         this.firestGetTime();
      }
      
      private function firestGetTime() : void
      {
         var _local_1:Date = TimeManager.Instance.Now();
         var _local_2:Number = _local_1.getTime();
         var _local_3:Number = ChristmasManager.instance.model.gameEndTime.getTime();
         var _local_4:Number = _local_3 - _local_2;
         var _local_5:int = int(_local_4 / (1000 * 60 * 60));
         var _local_6:int = int((_local_4 - _local_5 * 1000 * 60 * 60) / (1000 * 60));
         if(_local_6 >= 0)
         {
            this._activeTimeTxt.text = LanguageMgr.GetTranslation("christmas.flushTimecut",_local_5,_local_6);
         }
         else
         {
            this._activeTimeTxt.text = LanguageMgr.GetTranslation("christmas.flushTimecut",0,0);
         }
         this._snowPackNumTxt.text = ChristmasManager.instance.getBagSnowPacksCount() + "";
      }
      
      public function setMap(_arg_1:Point = null) : void
      {
         ChristmasManager.isFrameChristmas = true;
         this.clearMap();
         var _local_2:MovieClip = new (ClassUtils.uiSourceDomain.getDefinition(LoaderChristmasUIModule.Instance.getMapRes()) as Class)() as MovieClip;
         var _local_3:Sprite = _local_2.getChildByName("articleLayer") as Sprite;
         var _local_4:Sprite = _local_2.getChildByName("NPCMouse") as Sprite;
         var _local_5:Sprite = _local_2.getChildByName("mesh") as Sprite;
         var _local_6:Sprite = _local_2.getChildByName("bg") as Sprite;
         var _local_7:Sprite = _local_2.getChildByName("bgSize") as Sprite;
         var _local_8:Sprite = _local_2.getChildByName("snowCenter") as Sprite;
         var _local_9:Sprite = _local_2.getChildByName("decoration") as Sprite;
         if(_local_7)
         {
            MAP_SIZEII[0] = _local_7.width;
            MAP_SIZEII[1] = _local_7.height;
         }
         else
         {
            MAP_SIZEII[0] = _local_6.width;
            MAP_SIZEII[1] = _local_6.height;
         }
         this._sceneScene.setHitTester(new PathMapHitTester(_local_5));
         if(!this._sceneMap)
         {
            this._sceneMap = new ChristmasScneneMap(this._model,this._sceneScene,this._model.getPlayers(),this._model.getObjects(),_local_6,_local_5,_local_3,_local_4,_local_9,_local_8);
            addChildAt(this._sceneMap,0);
         }
         this._sceneMap.sceneMapVO = this.getSceneMapVO();
         if(_arg_1)
         {
            this._sceneMap.sceneMapVO.defaultPos = _arg_1;
         }
         this._sceneMap.addSelfPlayer();
         this._sceneMap.setCenter();
      }
      
      public function getSceneMapVO() : SceneMapVO
      {
         var _local_1:SceneMapVO = new SceneMapVO();
         _local_1.mapName = LanguageMgr.GetTranslation("church.churchScene.WeddingMainScene");
         _local_1.mapW = MAP_SIZEII[0];
         _local_1.mapH = MAP_SIZEII[1];
         _local_1.defaultPos = ComponentFactory.Instance.creatCustomObject("christmas.RoomView.sceneMapVOPosII");
         return _local_1;
      }
      
      public function movePlayer(_arg_1:int, _arg_2:Array) : void
      {
         if(this._sceneMap)
         {
            this._sceneMap.movePlayer(_arg_1,_arg_2);
         }
      }
      
      public function updatePlayerStauts(_arg_1:int, _arg_2:int, _arg_3:Point = null) : void
      {
         if(this._sceneMap)
         {
            this._sceneMap.updatePlayersStauts(_arg_1,_arg_2,_arg_3);
         }
      }
      
      public function updateSelfStatus(_arg_1:int) : void
      {
         this._sceneMap.updateSelfStatus(_arg_1);
      }
      
      public function playerRevive(_arg_1:int) : void
      {
         if(this._sceneMap.selfPlayer && _arg_1 == this._sceneMap.selfPlayer.ID)
         {
            if(this._roomMenuView)
            {
               this._roomMenuView.visible = true;
            }
         }
         this._sceneMap.playerRevive(_arg_1);
      }
      
      private function _leaveRoom(_arg_1:Event) : void
      {
         StateManager.setState(StateType.MAIN);
         this._contoller.dispose();
      }
      
      private function clearMap() : void
      {
         if(this._sceneMap)
         {
            if(this._sceneMap.parent)
            {
               this._sceneMap.parent.removeChild(this._sceneMap);
            }
            this._sceneMap.dispose();
         }
         this._sceneMap = null;
      }
      
      public function dispose() : void
      {
         this.removeEvent();
         ObjectUtils.disposeAllChildren(this);
         if(parent)
         {
            parent.removeChild(this);
         }
         if(this._timer)
         {
            this._timer.stop();
            this._timer.removeEventListener(TimerEvent.TIMER,this.updateTip);
         }
         this._roomMenuView = null;
         this._sceneScene = null;
         this._sceneMap = null;
         this._chatFrame = null;
      }
   }
}
