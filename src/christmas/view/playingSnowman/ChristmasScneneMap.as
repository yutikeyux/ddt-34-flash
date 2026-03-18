package christmas.view.playingSnowman
{
   import christmas.event.ChristmasRoomEvent;
   import christmas.info.MonsterInfo;
   import christmas.manager.ChristmasManager;
   import christmas.manager.ChristmasMonsterManager;
   import christmas.model.ChristmasRoomModel;
   import christmas.player.ChristmasMonster;
   import christmas.player.ChristmasRoomPlayer;
   import christmas.player.PlayerVO;
   import church.view.churchScene.MoonSceneMap;
   import church.vo.SceneMapVO;
   import com.pickgliss.ui.ComponentFactory;
   import com.pickgliss.ui.core.Disposeable;
   import com.pickgliss.ui.text.FilterFrameText;
   import com.pickgliss.utils.ClassUtils;
   import ddt.events.CrazyTankSocketEvent;
   import ddt.events.SceneCharacterEvent;
   import ddt.manager.LanguageMgr;
   import ddt.manager.MessageTipManager;
   import ddt.manager.PlayerManager;
   import ddt.manager.SocketManager;
   import ddt.view.sceneCharacter.SceneCharacterDirection;
   import ddt.view.scenePathSearcher.SceneScene;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import road7th.comm.PackageIn;
   import road7th.data.DictionaryData;
   import road7th.data.DictionaryEvent;
   
   public class ChristmasScneneMap extends Sprite implements Disposeable
   {
      
      private static var selectSpeek:int = 1;
      
      public static var packsNum:int = 2;
       
      
      protected var articleLayer:Sprite;
      
      protected var meshLayer:Sprite;
      
      protected var bgLayer:Sprite;
      
      protected var skyLayer:Sprite;
      
      protected var snowLayer:Sprite;
      
      public var sceneScene:SceneScene;
      
      protected var _data:DictionaryData;
      
      protected var _characters:DictionaryData;
      
      public var selfPlayer:ChristmasRoomPlayer;
      
      private var last_click:Number;
      
      private var current_display_fire:int = 0;
      
      private var _currentLoadingPlayer:ChristmasRoomPlayer;
      
      private var _isShowName:Boolean = true;
      
      private var _isChatBall:Boolean = true;
      
      private var _clickInterval:Number = 200;
      
      private var _lastClick:Number = 0;
      
      private var _sceneMapVO:SceneMapVO;
      
      private var _model:ChristmasRoomModel;
      
      private var armyPos:Point;
      
      private var decorationLayer:Sprite;
      
      protected var _mapObjs:DictionaryData;
      
      protected var _monsters:DictionaryData;
      
      private var _snowMC:MovieClip;
      
      private var _snowCenterMc:MovieClip;
      
      private var _snowSpeakPng:Bitmap;
      
      private var _snowSpeak:FilterFrameText;
      
      private var _timer:Timer;
      
      private var _mouseMovie:MovieClip;
      
      private var r:int = 250;
      
      private var auto:Point;
      
      private var autoMove:Boolean = false;
      
      private var _entering:Boolean = false;
      
      private var _speakTimer:Timer;
      
      private var _timeFive:Timer;
      
      private var endPoint:Point;
      
      protected var reference:ChristmasRoomPlayer;
      
      public function ChristmasScneneMap(_arg_1:ChristmasRoomModel, _arg_2:SceneScene, _arg_3:DictionaryData, _arg_4:DictionaryData, _arg_5:Sprite, _arg_6:Sprite, _arg_7:Sprite = null, _arg_8:Sprite = null, _arg_9:Sprite = null, _arg_10:Sprite = null)
      {
         this.endPoint = new Point();
         super();
         this._model = _arg_1;
         this.sceneScene = _arg_2;
         this._data = _arg_3;
         this._mapObjs = _arg_4;
         if(_arg_5 == null)
         {
            this.bgLayer = new Sprite();
         }
         else
         {
            this.bgLayer = _arg_5;
         }
         this.meshLayer = _arg_6 == null ? new Sprite() : _arg_6;
         this.meshLayer.alpha = 0;
         this.articleLayer = _arg_7 == null ? new Sprite() : _arg_7;
         this.decorationLayer = _arg_9 == null ? new Sprite() : _arg_9;
         this.skyLayer = _arg_8 == null ? new Sprite() : _arg_8;
         this.snowLayer = _arg_10 == null ? new Sprite() : _arg_10;
         this.decorationLayer.mouseChildren = this.decorationLayer.mouseEnabled = false;
         this.addChild(this.bgLayer);
         this.addChild(this.snowLayer);
         this.addChild(this.articleLayer);
         this.addChild(this.decorationLayer);
         this.addChild(this.meshLayer);
         this.addChild(this.skyLayer);
         this.init();
         this.addEvent();
         this.initSnow();
      }
      
      private function initSnow() : void
      {
         if(this.bgLayer != null && this.articleLayer != null)
         {
            this._snowCenterMc = this.snowLayer.getChildByName("snowCenter_MC") as MovieClip;
            this._snowCenterMc.visible = false;
            this._snowCenterMc.buttonMode = false;
            this._snowCenterMc.mouseEnabled = false;
            this._snowCenterMc.mouseChildren = false;
            this._snowCenterMc.gotoAndStop(1);
            this._snowMC = this.skyLayer.getChildByName("snow_mc") as MovieClip;
            this._snowMC.addEventListener(MouseEvent.CLICK,this._enterSnowNPC);
            this._snowMC.addEventListener(MouseEvent.MOUSE_OVER,this.__onMouseOver);
            this._snowMC.addEventListener(MouseEvent.MOUSE_OUT,this.__onMouseOut);
            this._snowMC.buttonMode = true;
         }
      }
      
      private function __onMouseOver(_arg_1:MouseEvent) : void
      {
         this._snowCenterMc.visible = true;
         this._snowCenterMc.gotoAndPlay(1);
      }
      
      private function __onMouseOut(_arg_1:MouseEvent) : void
      {
         this._snowCenterMc.visible = false;
         this._snowCenterMc.gotoAndStop(1);
      }
      
      private function _enterSnowNPC(_arg_1:MouseEvent) : void
      {
         SocketManager.Instance.out.getPacksToPlayer(0);
      }
      
      private function isPacksComplete(_arg_1:int = 1) : void
      {
         SocketManager.Instance.out.getPacksToPlayer(1);
      }
      
      private function checkDistance() : Boolean
      {
         var _local_3:Number = NaN;
         var _local_1:Number = this.selfPlayer.x - this.armyPos.x;
         var _local_2:Number = this.selfPlayer.y - this.armyPos.y;
         if(Math.pow(_local_1,2) + Math.pow(_local_2,2) > Math.pow(this.r,2))
         {
            _local_3 = Math.atan2(_local_2,_local_1);
            this.auto = new Point(this.armyPos.x,this.armyPos.y);
            this.auto.x += (_local_1 > 0 ? 1 : -1) * Math.abs(Math.cos(_local_3) * this.r);
            this.auto.y += (_local_2 > 0 ? 1 : -1) * Math.abs(Math.sin(_local_3) * this.r);
            return false;
         }
         return true;
      }
      
      private function checkCanStartGame() : Boolean
      {
         var _local_1:Boolean = true;
         if(PlayerManager.Instance.Self.Bag.getItemAt(6) == null)
         {
            MessageTipManager.getInstance().show(LanguageMgr.GetTranslation("tank.room.RoomIIController.weapon"));
            _local_1 = false;
         }
         return _local_1;
      }
      
      public function set enterIng(_arg_1:Boolean) : void
      {
         this._entering = _arg_1;
      }
      
      public function get sceneMapVO() : SceneMapVO
      {
         return this._sceneMapVO;
      }
      
      public function set sceneMapVO(_arg_1:SceneMapVO) : void
      {
         this._sceneMapVO = _arg_1;
      }
      
      protected function init() : void
      {
         this._characters = new DictionaryData(true);
         this._monsters = new DictionaryData(true);
         var _local_1:Class = ClassUtils.uiSourceDomain.getDefinition("asset.christmas.room.MouseClickMovie") as Class;
         this._mouseMovie = new _local_1() as MovieClip;
         this._mouseMovie.mouseChildren = false;
         this._mouseMovie.mouseEnabled = false;
         this._mouseMovie.stop();
         this.bgLayer.addChild(this._mouseMovie);
         this._snowSpeakPng = ComponentFactory.Instance.creatBitmap("asset.christmas.room.snowSpeakImg");
         this._snowSpeakPng.visible = false;
         this._snowSpeak = ComponentFactory.Instance.creatComponentByStylename("christmas.room.snowSpeakTxt");
         this._snowSpeak.visible = false;
         addChild(this._snowSpeakPng);
         addChild(this._snowSpeak);
         this.last_click = 0;
         if(this.bgLayer != null && this.articleLayer != null)
         {
            this.armyPos = new Point(this.bgLayer.getChildByName("armyPos").x,this.bgLayer.getChildByName("armyPos").y);
         }
         this._speakTimer = new Timer(300000,0);
         this._speakTimer.addEventListener(TimerEvent.TIMER,this.__santaSpeakTimer);
         this._speakTimer.start();
      }
      
      private function __santaSpeakTimer(_arg_1:TimerEvent) : void
      {
         this._timeFive = new Timer(1000,5);
         this._timeFive.addEventListener(TimerEvent.TIMER,this.__santaSpeakFiveSeconds);
         this._timeFive.addEventListener(TimerEvent.TIMER_COMPLETE,this.__santaSpeakFiveSecondsComplete);
         this._timeFive.start();
      }
      
      private function __santaSpeakFiveSeconds(_arg_1:TimerEvent) : void
      {
         if(selectSpeek % 2 == 0)
         {
            this._snowSpeak.text = LanguageMgr.GetTranslation("christmas.room.santaSpeakFiveSecondsText");
         }
         else
         {
            this._snowSpeak.text = LanguageMgr.GetTranslation("christmas.room.santaSpeakFiveSecondsText2");
         }
         this._snowSpeakPng.visible = true;
         this._snowSpeak.visible = true;
         ++selectSpeek;
      }
      
      public function stopAllTimer() : void
      {
         if(this._timeFive)
         {
            this._timeFive.stop();
            this._timeFive.removeEventListener(TimerEvent.TIMER,this.__santaSpeakFiveSeconds);
            this._timeFive.removeEventListener(TimerEvent.TIMER_COMPLETE,this.__santaSpeakFiveSecondsComplete);
         }
         if(this._speakTimer)
         {
            this._speakTimer.stop();
            this._speakTimer.removeEventListener(TimerEvent.TIMER,this.__santaSpeakTimer);
         }
      }
      
      private function __santaSpeakFiveSecondsComplete(_arg_1:TimerEvent) : void
      {
         (_arg_1.target as Timer).removeEventListener(TimerEvent.TIMER,this.__santaSpeakFiveSeconds);
         (_arg_1.target as Timer).removeEventListener(TimerEvent.TIMER_COMPLETE,this.__santaSpeakFiveSecondsComplete);
         (_arg_1.target as Timer).stop();
         this._snowSpeakPng.visible = false;
         this._snowSpeak.visible = false;
      }
      
      protected function addEvent() : void
      {
         this._model.addEventListener(ChristmasRoomEvent.PLAYER_NAME_VISIBLE,this.menuChange);
         this._model.addEventListener(ChristmasRoomEvent.PLAYER_CHATBALL_VISIBLE,this.menuChange);
         addEventListener(MouseEvent.CLICK,this.__click);
         addEventListener(Event.ENTER_FRAME,this.updateMap);
         this._data.addEventListener(DictionaryEvent.ADD,this.__addPlayer);
         this._data.addEventListener(DictionaryEvent.REMOVE,this.__removePlayer);
         this._mapObjs.addEventListener(DictionaryEvent.ADD,this.__addMonster);
         this._mapObjs.addEventListener(DictionaryEvent.REMOVE,this.__removeMonster);
         this._mapObjs.addEventListener(DictionaryEvent.UPDATE,this.__onMonsterUpdate);
         ChristmasManager.instance.addEventListener(CrazyTankSocketEvent.GET_PAKCS_TO_PLAYER,this.__getPacks);
         ChristmasManager.instance.addEventListener(CrazyTankSocketEvent.CHRISTMAS_ROOM_SPEAK,this.__snowSpeak);
      }
      
      private function __getPacks(_arg_1:CrazyTankSocketEvent) : void
      {
         var _local_2:PackageIn = _arg_1.pkg;
         var _local_3:Boolean = _local_2.readBoolean();
         var _local_4:int = _local_2.readInt();
         var _local_5:int = _local_2.readInt();
         var _local_6:int = _local_2.readInt();
         var _local_7:int = _local_5 - _local_6;
         if(_local_4 >= 2)
         {
            ChristmasManager.instance.showTransactionFrame(LanguageMgr.GetTranslation("christmas.snowPacks.full"),null,null,this,false);
            return;
         }
         var _local_8:Number = ChristmasManager.instance.model.serverTime();
         if(_local_8 < 14)
         {
            ChristmasManager.instance.showTransactionFrame(LanguageMgr.GetTranslation("christmas.snowPacks.unfinished2",packsNum < 0 ? 0 : packsNum),null,null,this,false);
            return;
         }
         if(_local_6 < _local_5 && _local_3 && _local_8 >= 14)
         {
            ChristmasManager.instance.showTransactionFrame(LanguageMgr.GetTranslation("christmas.snowPacks.unfinished",packsNum < 0 ? 0 : packsNum),null,null,this,false);
            return;
         }
         if(!_local_3)
         {
            ChristmasManager.instance.showTransactionFrame(LanguageMgr.GetTranslation("christmas.room.packs.isFull"),null,null,this,false);
            return;
         }
         if(_local_6 >= _local_5 && _local_3 && _local_8 >= 14)
         {
            --packsNum;
            ChristmasManager.instance.showTransactionFrame(LanguageMgr.GetTranslation("christmas.snowPacks.complete",_local_7.toString()),this.isPacksComplete,null,this,false);
            return;
         }
      }
      
      private function __addMonster(_arg_1:DictionaryEvent) : void
      {
         var _local_2:MonsterInfo = _arg_1.data as MonsterInfo;
         var _local_3:ChristmasMonster = new ChristmasMonster(_local_2,_local_2.MonsterPos);
         this._monsters.add(_local_2.ID,_local_3);
         this.articleLayer.addChild(_local_3);
      }
      
      private function __removeMonster(_arg_1:DictionaryEvent) : void
      {
         var _local_2:MonsterInfo = _arg_1.data as MonsterInfo;
         var _local_3:ChristmasMonster = this._monsters[_local_2.ID] as ChristmasMonster;
         this._monsters.remove(_local_2.ID);
         _local_3.dispose();
      }
      
      private function __onMonsterUpdate(_arg_1:DictionaryEvent) : void
      {
         var _local_2:MonsterInfo = _arg_1.data as MonsterInfo;
         var _local_3:ChristmasMonster = this._monsters[_local_2.ID] as ChristmasMonster;
      }
      
      private function __snowSpeak(_arg_1:CrazyTankSocketEvent) : void
      {
         this._timer = new Timer(1000,10);
         this._timer.addEventListener(TimerEvent.TIMER,this.__timeShowSnowSpeak);
         this._timer.addEventListener(TimerEvent.TIMER_COMPLETE,this.__timeSnowSpeakComplete);
         this._timer.start();
      }
      
      private function __timeShowSnowSpeak(_arg_1:TimerEvent) : void
      {
         this._snowSpeak.text = LanguageMgr.GetTranslation("christmas.room.snowSpeakText");
         this._snowSpeakPng.visible = true;
         this._snowSpeak.visible = true;
      }
      
      private function __timeSnowSpeakComplete(_arg_1:TimerEvent) : void
      {
         this._timer.removeEventListener(TimerEvent.TIMER,this.__timeShowSnowSpeak);
         this._timer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.__timeSnowSpeakComplete);
         this._timer.stop();
         this._snowSpeakPng.visible = false;
         this._snowSpeak.visible = false;
      }
      
      private function menuChange(_arg_1:ChristmasRoomEvent) : void
      {
         switch(_arg_1.type)
         {
            case ChristmasRoomEvent.PLAYER_NAME_VISIBLE:
               this.nameVisible();
               return;
            default:
               return;
         }
      }
      
      public function nameVisible() : void
      {
         var _local_1:ChristmasRoomPlayer = null;
         for each(_local_1 in this._characters)
         {
            _local_1.isShowName = this._model.playerNameVisible;
         }
      }
      
      protected function updateMap(_arg_1:Event) : void
      {
         var _local_2:ChristmasRoomPlayer = null;
         if(!this._characters || this._characters.length <= 0)
         {
            return;
         }
         for each(_local_2 in this._characters)
         {
            _local_2.updatePlayer();
            _local_2.isShowName = this._model.playerNameVisible;
         }
         this.BuildEntityDepth();
      }
      
      protected function __click(_arg_1:MouseEvent) : void
      {
         if(!this.selfPlayer || this.selfPlayer.playerVO.playerStauts != 0 || !this.selfPlayer.getCanAction())
         {
            return;
         }
         var _local_2:Point = this.globalToLocal(new Point(_arg_1.stageX,_arg_1.stageY));
         this.autoMove = false;
         if(getTimer() - this._lastClick > this._clickInterval)
         {
            this._lastClick = getTimer();
            if(!this.sceneScene.hit(_local_2))
            {
               this.selfPlayer.playerVO.walkPath = this.sceneScene.searchPath(this.selfPlayer.playerPoint,_local_2);
               this.selfPlayer.playerVO.walkPath.shift();
               this.selfPlayer.playerVO.scenePlayerDirection = SceneCharacterDirection.getDirection(this.selfPlayer.playerPoint,this.selfPlayer.playerVO.walkPath[0]);
               this.selfPlayer.playerVO.currentWalkStartPoint = this.selfPlayer.currentWalkStartPoint;
               this.sendMyPosition(this.selfPlayer.playerVO.walkPath.concat());
               this._mouseMovie.x = _local_2.x;
               this._mouseMovie.y = _local_2.y;
               this._mouseMovie.play();
            }
         }
      }
      
      public function sendMyPosition(_arg_1:Array) : void
      {
         var _local_3:uint = 0;
         var _local_2:Array = [];
         while(_local_3 < _arg_1.length)
         {
            _local_2.push(int(_arg_1[_local_3].x),int(_arg_1[_local_3].y));
            _local_3++;
         }
         var _local_4:String = _local_2.toString();
         SocketManager.Instance.out.sendChristmasRoomMove(_arg_1[_arg_1.length - 1].x,_arg_1[_arg_1.length - 1].y,_local_4);
      }
      
      public function movePlayer(_arg_1:int, _arg_2:Array) : void
      {
         var _local_3:ChristmasRoomPlayer = null;
         if(this._characters[_arg_1])
         {
            _local_3 = this._characters[_arg_1] as ChristmasRoomPlayer;
            if(!_local_3.getCanAction())
            {
               _local_3.playerVO.playerStauts = 0;
               _local_3.setStatus();
            }
            _local_3.playerVO.walkPath = _arg_2;
            _local_3.playerWalk(_arg_2);
         }
      }
      
      public function updatePlayersStauts(_arg_1:int, _arg_2:int, _arg_3:Point) : void
      {
         var _local_4:ChristmasRoomPlayer = null;
         if(this._characters[_arg_1])
         {
            _local_4 = this._characters[_arg_1] as ChristmasRoomPlayer;
            if(_arg_2 == 0)
            {
               _local_4.playerVO.playerStauts = _arg_2;
               _local_4.playerVO.playerPos = _arg_3;
               _local_4.setStatus();
            }
            else if(_arg_2 == 1)
            {
               if(!_local_4.getCanAction())
               {
                  _local_4.playerVO.playerStauts = 0;
                  _local_4.setStatus();
               }
               _local_4.playerVO.playerStauts = _arg_2;
               _local_4.isReadyFight = true;
               _local_4.addEventListener(ChristmasRoomEvent.READYFIGHT,this.__otherPlayrStartFight);
               _local_4.playerVO.walkPath = [_arg_3];
               _local_4.playerWalk([_arg_3]);
            }
            else
            {
               _local_4.playerVO.playerStauts = _arg_2;
               _local_4.setStatus();
            }
         }
      }
      
      public function __otherPlayrStartFight(_arg_1:ChristmasRoomEvent) : void
      {
         var _local_2:ChristmasRoomPlayer = _arg_1.currentTarget as ChristmasRoomPlayer;
         _local_2.removeEventListener(ChristmasRoomEvent.READYFIGHT,this.__otherPlayrStartFight);
         _local_2.sceneCharacterDirection = SceneCharacterDirection.getDirection(_local_2.playerPoint,this.armyPos);
         _local_2.dispatchEvent(new SceneCharacterEvent(SceneCharacterEvent.CHARACTER_DIRECTION_CHANGE,false));
         _local_2.isReadyFight = false;
         _local_2.setStatus();
      }
      
      public function updateSelfStatus(_arg_1:int) : void
      {
         if(this.selfPlayer)
         {
            if(this.selfPlayer.playerVO.playerStauts == 2)
            {
               this.selfPlayer.playerVO.playerPos = ChristmasManager.instance.christmasInfo.playerDefaultPos;
               this.ajustScreen(this.selfPlayer);
               this.setCenter();
               this._entering = false;
            }
            this.selfPlayer.playerVO.playerStauts = _arg_1;
            this.selfPlayer.setStatus();
         }
      }
      
      public function checkSelfStatus() : int
      {
         return this.selfPlayer.playerVO.playerStauts;
      }
      
      public function playerRevive(_arg_1:int) : void
      {
         var _local_2:ChristmasRoomPlayer = null;
         if(this._characters[_arg_1])
         {
            _local_2 = this._characters[_arg_1] as ChristmasRoomPlayer;
            _local_2.revive();
            this.selfPlayer.playerVO.playerStauts = 0;
            this._entering = false;
         }
      }
      
      public function setCenter(_arg_1:SceneCharacterEvent = null) : void
      {
         var _local_2:Number = NaN;
         var _local_3:Number = NaN;
         if(this.reference)
         {
            _local_2 = -(this.reference.x - MoonSceneMap.GAME_WIDTH / 2);
            _local_3 = -(this.reference.y - MoonSceneMap.GAME_HEIGHT / 2) + 50;
         }
         else
         {
            _local_2 = -(ChristmasManager.instance.christmasInfo.playerDefaultPos.x - MoonSceneMap.GAME_WIDTH / 2);
            _local_3 = -(ChristmasManager.instance.christmasInfo.playerDefaultPos.y - MoonSceneMap.GAME_HEIGHT / 2) + 50;
         }
         if(_local_2 > 0)
         {
            _local_2 = 0;
         }
         if(_local_2 < MoonSceneMap.GAME_WIDTH - this._sceneMapVO.mapW)
         {
            _local_2 = MoonSceneMap.GAME_WIDTH - this._sceneMapVO.mapW;
         }
         if(_local_3 > 0)
         {
            _local_3 = 0;
         }
         if(_local_3 < MoonSceneMap.GAME_HEIGHT - this._sceneMapVO.mapH)
         {
            _local_3 = MoonSceneMap.GAME_HEIGHT - this._sceneMapVO.mapH;
         }
         x = _local_2;
         y = _local_3;
      }
      
      public function addSelfPlayer() : void
      {
         var _local_1:PlayerVO = null;
         if(!this.selfPlayer)
         {
            _local_1 = ChristmasManager.instance.christmasInfo.myPlayerVO;
            _local_1.playerInfo = PlayerManager.Instance.Self;
            this._currentLoadingPlayer = new ChristmasRoomPlayer(_local_1,this.addPlayerCallBack);
         }
      }
      
      protected function ajustScreen(_arg_1:ChristmasRoomPlayer) : void
      {
         if(_arg_1 == null)
         {
            if(this.reference)
            {
               this.reference.removeEventListener(SceneCharacterEvent.CHARACTER_MOVEMENT,this.setCenter);
               this.reference = null;
            }
            return;
         }
         if(this.reference)
         {
            this.reference.removeEventListener(SceneCharacterEvent.CHARACTER_MOVEMENT,this.setCenter);
         }
         this.reference = _arg_1;
         this.reference.addEventListener(SceneCharacterEvent.CHARACTER_MOVEMENT,this.setCenter);
      }
      
      protected function __addPlayer(_arg_1:DictionaryEvent) : void
      {
         var _local_2:PlayerVO = _arg_1.data as PlayerVO;
         this._currentLoadingPlayer = new ChristmasRoomPlayer(_local_2,this.addPlayerCallBack);
      }
      
      private function addPlayerCallBack(_arg_1:ChristmasRoomPlayer, _arg_2:Boolean, _arg_3:int) : void
      {
         if(_arg_3 == 0)
         {
            if(!this.articleLayer || !_arg_1)
            {
               return;
            }
            this._currentLoadingPlayer = null;
            _arg_1.sceneScene = this.sceneScene;
            _arg_1.setSceneCharacterDirectionDefault = _arg_1.sceneCharacterDirection = _arg_1.playerVO.scenePlayerDirection;
            if(!this.selfPlayer && _arg_1.playerVO.playerInfo.ID == PlayerManager.Instance.Self.ID)
            {
               _arg_1.playerVO.playerPos = _arg_1.playerVO.playerPos;
               this.selfPlayer = _arg_1;
               this.articleLayer.addChild(this.selfPlayer);
               this.ajustScreen(this.selfPlayer);
               this.setCenter();
               this.selfPlayer.setStatus();
               this.selfPlayer.addEventListener(SceneCharacterEvent.CHARACTER_ACTION_CHANGE,this.playerActionChange);
            }
            else
            {
               this.articleLayer.addChild(_arg_1);
            }
            _arg_1.playerPoint = _arg_1.playerVO.playerPos;
            _arg_1.sceneCharacterStateType = "natural";
            this._characters.add(_arg_1.playerVO.playerInfo.ID,_arg_1);
            _arg_1.isShowName = this._model.playerNameVisible;
         }
      }
      
      private function playerActionChange(_arg_1:SceneCharacterEvent) : void
      {
         var _local_3:ChristmasMonster = null;
         var _local_4:Point = null;
         var _local_2:String = _arg_1.data.toString();
         if(_local_2 == "naturalStandFront" || _local_2 == "naturalStandBack")
         {
            this._mouseMovie.gotoAndStop(1);
            _local_3 = ChristmasMonsterManager.Instance.curMonster;
            if(_local_3 && _local_3.MonsterState <= MonsterInfo.LIVIN)
            {
               _local_4 = this.localToGlobal(new Point(this.selfPlayer.playerPoint.x,this.selfPlayer.playerPoint.y + 50));
               if(_local_3.hitTestPoint(_local_4.x,_local_4.y) || _local_3.hitTestObject(this.selfPlayer))
               {
                  _local_3.StartFight();
               }
            }
         }
      }
      
      protected function __removePlayer(_arg_1:DictionaryEvent) : void
      {
         var _local_2:int = (_arg_1.data as PlayerVO).playerInfo.ID;
         var _local_3:ChristmasRoomPlayer = this._characters[_local_2] as ChristmasRoomPlayer;
         this._characters.remove(_local_2);
         if(_local_3)
         {
            if(_local_3.parent)
            {
               _local_3.parent.removeChild(_local_3);
            }
            _local_3.removeEventListener(SceneCharacterEvent.CHARACTER_MOVEMENT,this.setCenter);
            _local_3.removeEventListener(SceneCharacterEvent.CHARACTER_ACTION_CHANGE,this.playerActionChange);
            _local_3.dispose();
         }
         _local_3 = null;
      }
      
      protected function BuildEntityDepth() : void
      {
         var _local_3:DisplayObject = null;
         var _local_4:Number = NaN;
         var _local_5:int = 0;
         var _local_6:Number = NaN;
         var _local_7:int = 0;
         var _local_8:DisplayObject = null;
         var _local_9:Number = NaN;
         var _local_2:int = 0;
         var _local_1:int = this.articleLayer.numChildren;
         while(_local_2 < _local_1 - 1)
         {
            _local_3 = this.articleLayer.getChildAt(_local_2);
            _local_4 = this.getPointDepth(_local_3.x,_local_3.y);
            _local_6 = Number.MAX_VALUE;
            _local_7 = _local_2 + 1;
            while(_local_7 < _local_1)
            {
               _local_8 = this.articleLayer.getChildAt(_local_7);
               _local_9 = this.getPointDepth(_local_8.x,_local_8.y);
               if(_local_9 < _local_6)
               {
                  _local_5 = _local_7;
                  _local_6 = _local_9;
               }
               _local_7++;
            }
            if(_local_4 > _local_6)
            {
               this.articleLayer.swapChildrenAt(_local_2,_local_5);
            }
            _local_2++;
         }
      }
      
      protected function getPointDepth(_arg_1:Number, _arg_2:Number) : Number
      {
         return this.sceneMapVO.mapW * _arg_2 + _arg_1;
      }
      
      protected function removeEvent() : void
      {
         this._model.removeEventListener(ChristmasRoomEvent.PLAYER_NAME_VISIBLE,this.menuChange);
         this._model.removeEventListener(ChristmasRoomEvent.PLAYER_CHATBALL_VISIBLE,this.menuChange);
         removeEventListener(MouseEvent.CLICK,this.__click);
         removeEventListener(Event.ENTER_FRAME,this.updateMap);
         this._data.removeEventListener(DictionaryEvent.ADD,this.__addPlayer);
         this._data.removeEventListener(DictionaryEvent.REMOVE,this.__removePlayer);
         this._mapObjs.removeEventListener(DictionaryEvent.ADD,this.__addMonster);
         this._mapObjs.removeEventListener(DictionaryEvent.REMOVE,this.__removeMonster);
         this._mapObjs.removeEventListener(DictionaryEvent.UPDATE,this.__onMonsterUpdate);
         if(this.reference)
         {
            this.reference.removeEventListener(SceneCharacterEvent.CHARACTER_MOVEMENT,this.setCenter);
         }
         if(this.selfPlayer)
         {
            this.selfPlayer.removeEventListener(SceneCharacterEvent.CHARACTER_ACTION_CHANGE,this.playerActionChange);
         }
         this._snowMC.removeEventListener(MouseEvent.CLICK,this._enterSnowNPC);
         ChristmasManager.instance.removeEventListener(CrazyTankSocketEvent.GET_PAKCS_TO_PLAYER,this.__getPacks);
         ChristmasManager.instance.removeEventListener(CrazyTankSocketEvent.CHRISTMAS_ROOM_SPEAK,this.__snowSpeak);
      }
      
      public function dispose() : void
      {
         var p:ChristmasRoomPlayer = null;
         var o:ChristmasMonster = null;
         var i:int = 0;
         var player:ChristmasRoomPlayer = null;
         this.removeEvent();
         if(this._mapObjs)
         {
            this._mapObjs.clear();
            this._mapObjs = null;
         }
         if(this._data)
         {
            this._data.clear();
            this._data = null;
         }
         this._sceneMapVO = null;
         for each(p in this._characters)
         {
            if(p.parent)
            {
               p.parent.removeChild(p);
            }
            p.removeEventListener(SceneCharacterEvent.CHARACTER_MOVEMENT,this.setCenter);
            p.removeEventListener(SceneCharacterEvent.CHARACTER_ACTION_CHANGE,this.playerActionChange);
            p.dispose();
            p = null;
         }
         this._characters.clear();
         this._characters = null;
         if(this.articleLayer)
         {
            i = this.articleLayer.numChildren;
            while(i > 0)
            {
               player = this.articleLayer.getChildAt(i - 1) as ChristmasRoomPlayer;
               if(player)
               {
                  player.removeEventListener(SceneCharacterEvent.CHARACTER_MOVEMENT,this.setCenter);
                  player.removeEventListener(SceneCharacterEvent.CHARACTER_ACTION_CHANGE,this.playerActionChange);
                  if(player.parent)
                  {
                     player.parent.removeChild(player);
                  }
                  player.dispose();
               }
               player = null;
               try
               {
                  this.articleLayer.removeChildAt(i - 1);
               }
               catch(e:RangeError)
               {
               }
               i -= 1;
            }
            if(this.articleLayer && this.articleLayer.parent)
            {
               this.articleLayer.parent.removeChild(this.articleLayer);
            }
         }
         this.articleLayer = null;
         if(this.selfPlayer)
         {
            if(this.selfPlayer.parent)
            {
               this.selfPlayer.parent.removeChild(this.selfPlayer);
            }
            this.selfPlayer.dispose();
         }
         this.selfPlayer = null;
         if(this._currentLoadingPlayer)
         {
            if(this._currentLoadingPlayer.parent)
            {
               this._currentLoadingPlayer.parent.removeChild(this._currentLoadingPlayer);
            }
            this._currentLoadingPlayer.dispose();
         }
         this._currentLoadingPlayer = null;
         for each(o in this._monsters)
         {
            o.dispose();
            o = null;
         }
         this._monsters.clear();
         if(this._mouseMovie && this._mouseMovie.parent)
         {
            this._mouseMovie.parent.removeChild(this._mouseMovie);
         }
         this._mouseMovie = null;
         if(this.meshLayer && this.meshLayer.parent)
         {
            this.meshLayer.parent.removeChild(this.meshLayer);
         }
         this.meshLayer = null;
         if(this.bgLayer && this.bgLayer.parent)
         {
            this.bgLayer.parent.removeChild(this.bgLayer);
         }
         this.bgLayer = null;
         if(this.skyLayer && this.skyLayer.parent)
         {
            this.skyLayer.parent.removeChild(this.skyLayer);
         }
         this.skyLayer = null;
         this.sceneScene = null;
         if(parent)
         {
            this.parent.removeChild(this);
         }
      }
   }
}
