package christmas.info
{
   import christmas.player.PlayerVO;
   import ddt.data.goods.ItemTemplateInfo;
   import ddt.manager.ItemManager;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   
   public class ChristmasSystemItemsInfo extends EventDispatcher
   {
       
      
      public var TemplateID:int;
      
      public var Count:int = 1;
      
      private var _templateInfo:ItemTemplateInfo;
      
      public var isUp:Boolean;
      
      public var isFall:Boolean;
      
      public var num:int = 10;
      
      private var _playerDefaultPos:Point;
      
      private var _fightOver:Boolean;
      
      private var _roomClose:Boolean;
      
      private var _myPlayerVO:PlayerVO;
      
      private var _isLiving:Boolean;
      
      private var _current_Blood:Number;
      
      private var _cutValue:Number;
      
      private var _snowNum:int;
      
      public function ChristmasSystemItemsInfo(_arg_1:int = 0)
      {
         super();
         this.TemplateID = _arg_1;
      }
      
      public function get TemplateInfo() : ItemTemplateInfo
      {
         if(this._templateInfo == null)
         {
            return ItemManager.Instance.getTemplateById(this.TemplateID);
         }
         return this._templateInfo;
      }
      
      public function get playerDefaultPos() : Point
      {
         return this._playerDefaultPos;
      }
      
      public function set playerDefaultPos(_arg_1:Point) : void
      {
         this._playerDefaultPos = _arg_1;
      }
      
      public function get fightOver() : Boolean
      {
         return this._fightOver;
      }
      
      public function set fightOver(_arg_1:Boolean) : void
      {
         this._fightOver = _arg_1;
      }
      
      public function get roomClose() : Boolean
      {
         return this._roomClose;
      }
      
      public function set roomClose(_arg_1:Boolean) : void
      {
         this._roomClose = _arg_1;
      }
      
      public function get myPlayerVO() : PlayerVO
      {
         return this._myPlayerVO;
      }
      
      public function set myPlayerVO(_arg_1:PlayerVO) : void
      {
         this._myPlayerVO = _arg_1;
      }
      
      public function set current_Blood(_arg_1:Number) : void
      {
         if(this._current_Blood == _arg_1)
         {
            this._cutValue = -1;
            return;
         }
         this._cutValue = this._current_Blood - _arg_1;
         this._current_Blood = _arg_1;
         dispatchEvent(new Event(Event.CHANGE));
      }
      
      public function get current_Blood() : Number
      {
         return this._current_Blood;
      }
      
      public function set isLiving(_arg_1:Boolean) : void
      {
         this._isLiving = _arg_1;
         if(!this._isLiving)
         {
            this.current_Blood = 0;
         }
      }
      
      public function get isLiving() : Boolean
      {
         return this._isLiving;
      }
      
      public function get snowNum() : int
      {
         return this._snowNum;
      }
      
      public function set snowNum(_arg_1:int) : void
      {
         this._snowNum = _arg_1;
      }
   }
}
