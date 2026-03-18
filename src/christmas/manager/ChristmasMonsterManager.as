package christmas.manager
{
   import christmas.event.ChristmasMonsterEvent;
   import christmas.info.MonsterInfo;
   import christmas.player.ChristmasMonster;
   import ddt.events.CrazyTankSocketEvent;
   import ddt.manager.GameInSocketOut;
   import flash.events.EventDispatcher;
   import room.RoomManager;
   import room.model.RoomInfo;
   
   public class ChristmasMonsterManager extends EventDispatcher
   {
      
      private static var _instance:ChristmasMonsterManager;
       
      
      private var _monsterInfo:MonsterInfo;
      
      public var isFighting:Boolean = false;
      
      private var _activeState:Boolean = false;
      
      public var curMonster:ChristmasMonster;
      
      public function ChristmasMonsterManager(_arg_1:ThisIsSingleTon)
      {
         super();
         if(_arg_1 == null)
         {
            throw new Error("this is singleton,can\'t be new like this!");
         }
      }
      
      public static function get Instance() : ChristmasMonsterManager
      {
         if(_instance == null)
         {
            _instance = new ChristmasMonsterManager(new ThisIsSingleTon());
         }
         return _instance;
      }
      
      public function set ActiveState(_arg_1:Boolean) : void
      {
         this._activeState = _arg_1;
         ChristmasMonsterManager.Instance.dispatchEvent(new ChristmasMonsterEvent(ChristmasMonsterEvent.MONSTER_ACTIVE_START,_arg_1));
      }
      
      public function setupFightEvent() : void
      {
         RoomManager.Instance.addEventListener(CrazyTankSocketEvent.GAME_ROOM_CREATE,this.__gameStart);
      }
      
      private function __gameStart(_arg_1:CrazyTankSocketEvent) : void
      {
         RoomManager.Instance.removeEventListener(CrazyTankSocketEvent.GAME_ROOM_CREATE,this.__gameStart);
         if(this._monsterInfo)
         {
            GameInSocketOut.sendGameRoomSetUp(this._monsterInfo.MissionID,RoomInfo.CHRISTMAS_ROOM,false,"","",3,0,0,false,this._monsterInfo.MissionID);
            ChristmasMonsterManager.Instance.curMonster = null;
            GameInSocketOut.sendGameStart();
         }
      }
      
      public function removeFightEvent() : void
      {
         RoomManager.Instance.removeEventListener(CrazyTankSocketEvent.GAME_ROOM_CREATE,this.__gameStart);
      }
      
      public function get ActiveState() : Boolean
      {
         return this._activeState;
      }
      
      public function set CurrentMonster(_arg_1:MonsterInfo) : void
      {
         this._monsterInfo = _arg_1;
      }
   }
}

class ThisIsSingleTon
{
    
   
   function ThisIsSingleTon()
   {
      super();
   }
}
