package christmas.model
{
   import christmas.event.ChristmasRoomEvent;
   import christmas.player.PlayerVO;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.utils.setTimeout;
   import road7th.data.DictionaryData;
   
   public class ChristmasRoomModel extends EventDispatcher
   {
       
      
      private var _players:DictionaryData;
      
      private var _playersBuffer:Array;
      
      public var _mapObjects:DictionaryData;
      
      private var _playerNameVisible:Boolean = true;
      
      public function ChristmasRoomModel()
      {
         super();
         this._players = new DictionaryData(true);
         this._playersBuffer = new Array();
         this._mapObjects = new DictionaryData(true);
      }
      
      public function get players() : DictionaryData
      {
         return this._players;
      }
      
      public function addPlayer(_arg_1:PlayerVO) : void
      {
         this._playersBuffer.push(_arg_1);
         setTimeout(this.addPlayerToMap,500 + this._playersBuffer.length * 200);
      }
      
      public function getObjects() : DictionaryData
      {
         return this._mapObjects;
      }
      
      private function addPlayerToMap() : void
      {
         if(!this._players || !this._playersBuffer[0])
         {
            return;
         }
         this._players.add(this._playersBuffer[0].playerInfo.ID,this._playersBuffer[0]);
         this._playersBuffer.shift();
      }
      
      public function updatePlayerStauts(_arg_1:int, _arg_2:int, _arg_3:Point) : void
      {
         var _local_4:int = 0;
         var _local_5:PlayerVO = null;
         if(this._playersBuffer && this._playersBuffer.length > 0)
         {
            _local_4 = 0;
            while(_local_4 < this._playersBuffer.length)
            {
               if(_arg_1 == this._playersBuffer[_local_4].playerInfo.ID)
               {
                  _local_5 = this._playersBuffer[_local_4] as PlayerVO;
                  _local_5.playerStauts = _arg_2;
                  _local_5.playerPos = _arg_3;
                  return;
               }
               _local_4++;
            }
         }
      }
      
      public function removePlayer(_arg_1:int) : void
      {
         this._players.remove(_arg_1);
      }
      
      public function getPlayers() : DictionaryData
      {
         return this._players;
      }
      
      public function getPlayerFromID(_arg_1:int) : PlayerVO
      {
         return this._players[_arg_1];
      }
      
      public function reset() : void
      {
         this.dispose();
         this._players = new DictionaryData(true);
      }
      
      public function get playerNameVisible() : Boolean
      {
         return this._playerNameVisible;
      }
      
      public function set playerNameVisible(_arg_1:Boolean) : void
      {
         this._playerNameVisible = _arg_1;
         dispatchEvent(new ChristmasRoomEvent(ChristmasRoomEvent.PLAYER_NAME_VISIBLE));
      }
      
      public function dispose() : void
      {
         this._players = null;
         this._playersBuffer = null;
      }
   }
}
