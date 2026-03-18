package game.view.effects
{
   import game.objects.MirariType;
   import road7th.data.DictionaryData;
   
   public class MirariEffectIconManager
   {
      
      private static var _instance:MirariEffectIconManager;
       
      
      private var _effecticons:DictionaryData;
      
      private var _isSetup:Boolean;
      
      public function MirariEffectIconManager(param1:SingletonEnforce)
      {
         super();
         this.initialize();
      }
      
      public static function getInstance() : MirariEffectIconManager
      {
         if(_instance == null)
         {
            _instance = new MirariEffectIconManager(new SingletonEnforce());
         }
         return _instance;
      }
      
      private function initialize() : void
      {
         this._effecticons = new DictionaryData();
         this._isSetup = false;
      }
      
      private function release() : void
      {
         if(this._effecticons)
         {
            this._effecticons.clear();
         }
         this._effecticons = null;
      }
      
      public function get isSetup() : Boolean
      {
         return this._isSetup;
      }
      
      public function setup() : void
      {
         if(this._isSetup == false)
         {
            this._isSetup = true;
            this._effecticons.add(MirariType.Tired,TiredEffectIcon); //yorgunluk
            this._effecticons.add(MirariType.Firing,FiringEffectIcon); //Mühür
            this._effecticons.add(MirariType.LockAngl,LockAngleEffectIcon); //pranga
            this._effecticons.add(MirariType.Weakness,WeaknessEffectIcon);//zayıflatma
            this._effecticons.add(MirariType.NoHole,NoHoleEffectIcon);//çukur engelleme
            this._effecticons.add(MirariType.Defend,DefendEffectIcon);//damage up
            this._effecticons.add(MirariType.Targeting,TargetingEffectIcon); //rehber efekti
            this._effecticons.add(MirariType.DisenableFly,DisenableFlyEffectIcon);
            this._effecticons.add(MirariType.LimitMaxForce,LimitMaxForceEffectIcon);
            this._effecticons.add(MirariType.ReduceStrength,ReduceStrengthEffect);
            this._effecticons.add(MirariType.ResolveHurt,ResolveHurtEffectIcon);
            this._effecticons.add(MirariType.ReversePlayer,RevertEffectIcon);
            this._effecticons.add(MirariType.Defense,DefenseEffectIcon);
            this._effecticons.add(MirariType.Attack,AttackEffectIcon);
         }
      }
      
      public function unsetup() : void
      {
         if(this._isSetup)
         {
            this.release();
            this._isSetup = false;
         }
      }
      
      public function createEffectIcon(param1:int) : BaseMirariEffectIcon
      {
         if(!this._isSetup)
         {
            this.setup();
         }
         var _loc2_:Class = this._effecticons[param1] as Class;
         if(_loc2_ == null)
         {
            return null;
         }
         return new _loc2_() as BaseMirariEffectIcon;
      }
   }
}

class SingletonEnforce
{
    
   
   function SingletonEnforce()
   {
      super();
   }
}
