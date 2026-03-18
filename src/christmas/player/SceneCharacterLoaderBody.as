package christmas.player
{
   import ddt.data.player.PlayerInfo;
   import ddt.manager.ItemManager;
   import ddt.view.character.ILayer;
   import flash.display.BitmapData;
   import flash.display.BlendMode;
   
   public class SceneCharacterLoaderBody
   {
       
      
      private var _loaders:Vector.<ChristmasSceneCharacterLayer>;
      
      private var _recordStyle:Array;
      
      private var _recordColor:Array;
      
      private var _content:BitmapData;
      
      private var _playerInfo:PlayerInfo;
      
      private var _isAllLoadSucceed:Boolean = true;
      
      private var _callBack:Function;
      
      public function SceneCharacterLoaderBody(_arg_1:PlayerInfo)
      {
         super();
         this._playerInfo = _arg_1;
      }
      
      public function load(_arg_1:Function = null) : void
      {
         var _local_3:int = 0;
         this._callBack = _arg_1;
         if(this._playerInfo == null || this._playerInfo.Style == null)
         {
            return;
         }
         this.initLoaders();
         var _local_2:int = this._loaders.length;
         while(_local_3 < _local_2)
         {
            this._loaders[_local_3].load(this.layerComplete);
            _local_3++;
         }
      }
      
      private function initLoaders() : void
      {
         this._loaders = new Vector.<ChristmasSceneCharacterLayer>();
         this._recordStyle = this._playerInfo.Style.split(",");
         this._recordColor = this._playerInfo.Colors.split(",");
         this._loaders.push(new ChristmasSceneCharacterLayer(ItemManager.Instance.getTemplateById(int(this._recordStyle[4].split("|")[0])),this._recordColor[4],1,this._playerInfo.Sex));
         this._loaders.push(new ChristmasSceneCharacterLayer(ItemManager.Instance.getTemplateById(int(this._recordStyle[4].split("|")[0])),this._recordColor[4],2,this._playerInfo.Sex));
      }
      
      private function drawCharacter() : void
      {
         var _local_3:uint = 0;
         var _local_1:Number = this._loaders[0].width;
         var _local_2:Number = this._loaders[0].height;
         if(_local_1 == 0 || _local_2 == 0)
         {
            return;
         }
         this._content = new BitmapData(_local_1,_local_2,true,0);
         while(_local_3 < this._loaders.length)
         {
            if(!this._loaders[_local_3].isAllLoadSucceed)
            {
               this._isAllLoadSucceed = false;
            }
            this._content.draw(this._loaders[_local_3].getContent(),null,null,BlendMode.NORMAL);
            _local_3++;
         }
      }
      
      private function layerComplete(_arg_1:ILayer) : void
      {
         var _local_3:int = 0;
         var _local_2:Boolean = true;
         while(_local_3 < this._loaders.length)
         {
            if(!this._loaders[_local_3].isComplete)
            {
               _local_2 = false;
            }
            _local_3++;
         }
         if(_local_2)
         {
            this.drawCharacter();
            this.loadComplete();
         }
      }
      
      private function loadComplete() : void
      {
         if(this._callBack != null)
         {
            this._callBack(this,this._isAllLoadSucceed);
         }
      }
      
      public function getContent() : Array
      {
         return [this._content];
      }
      
      public function dispose() : void
      {
         var _local_1:int = 0;
         if(this._loaders == null)
         {
            return;
         }
         while(_local_1 < this._loaders.length)
         {
            this._loaders[_local_1].dispose();
            _local_1++;
         }
         this._loaders = null;
         this._recordStyle = null;
         this._recordColor = null;
         this._playerInfo = null;
         this._callBack = null;
      }
   }
}
