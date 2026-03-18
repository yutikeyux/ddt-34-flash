package christmas.info
{
   import christmas.player.PlayerVO;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   
   public class ChristmasInfo extends EventDispatcher
   {
      
      public static const CHRISTMAS_MONSTER:int = 17;
      
      public static const LIVIN:int = 0;
       
      
      private var _myPlayerVO:PlayerVO;
      
      private var _playerDefaultPos:Point;
      
      public function ChristmasInfo()
      {
         super();
      }
      
      public function set myPlayerVO(_arg_1:PlayerVO) : void
      {
         this._myPlayerVO = _arg_1;
      }
      
      public function get myPlayerVO() : PlayerVO
      {
         return this._myPlayerVO;
      }
      
      public function set playerDefaultPos(_arg_1:Point) : void
      {
         this._playerDefaultPos = _arg_1;
      }
      
      public function get playerDefaultPos() : Point
      {
         return this._playerDefaultPos;
      }
   }
}
