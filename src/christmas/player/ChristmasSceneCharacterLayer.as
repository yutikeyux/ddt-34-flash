package christmas.player
{
   import christmas.loader.LoaderChristmasUIModule;
   import ddt.data.goods.ItemTemplateInfo;
   import ddt.view.character.BaseLayer;
   
   public class ChristmasSceneCharacterLayer extends BaseLayer
   {
       
      
      private var _direction:int;
      
      private var _sex:Boolean;
      
      public function ChristmasSceneCharacterLayer(_arg_1:ItemTemplateInfo, _arg_2:String = "", _arg_3:int = 1, _arg_4:Boolean = true)
      {
         this._direction = _arg_3;
         this._sex = _arg_4;
         super(_arg_1,_arg_2);
      }
      
      override protected function getUrl(_arg_1:int) : String
      {
         var _local_2:String = this._direction == 1 ? "clothF" : (this._direction == 2 ? "cloth" : "clothF");
         return LoaderChristmasUIModule.Instance.getChristmasResource() + "/cloth/" + (!!this._sex ? "M" : "F") + "/" + _local_2 + "/" + String(_arg_1) + ".png";
      }
   }
}
