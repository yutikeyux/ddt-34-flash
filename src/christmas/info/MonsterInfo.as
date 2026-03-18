package christmas.info
{
   import christmas.event.ChristmasMonsterEvent;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   
   public class MonsterInfo extends EventDispatcher
   {
      
      public static const LIVIN:int = 0;
      
      public static const DEAD:int = 2;
      
      public static const FIGHTING:int = 1;
       
      
      public var ActionMovieName:String = "game.living.Living003";
      
      public var ID:int;
      
      public var MonsterName:String;
      
      public var MissionID:int;
      
      private var _state:int;
      
      public var MonsterPos:Point;
      
      public var MonsterNewPos:Point;
      
      public var type:int;
      
      public function MonsterInfo()
      {
         this.MonsterName = "Sai" + int(Math.random() * 50);
         super();
      }
      
      public function get State() : int
      {
         return this._state;
      }
      
      public function set State(_arg_1:int) : void
      {
         if(this._state != _arg_1)
         {
            this._state = _arg_1;
            dispatchEvent(new ChristmasMonsterEvent(ChristmasMonsterEvent.UPDATE_MONSTER_STATE,this._state));
         }
      }
   }
}
