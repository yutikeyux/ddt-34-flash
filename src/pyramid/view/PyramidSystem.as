package pyramid.view
{
   import com.pickgliss.manager.CacheSysManager;
   import com.pickgliss.utils.ObjectUtils;
   import ddt.manager.KeyboardShortcutsManager;
   import ddt.states.BaseStateView;
   import ddt.constants.CacheConsts;
   import ddt.states.StateType;
	   
   public class PyramidSystem extends BaseStateView
   {
       
      
      private var _pyramidView:PyramidView;
      
      public function PyramidSystem()
      {
         super();
      }
      
      override public function enter(param1:BaseStateView, param2:Object = null) : void
      {
         CacheSysManager.lock(CacheConsts.ALERT_IN_PYRAMID);
         KeyboardShortcutsManager.Instance.forbiddenFull();
         _pyramidView = new PyramidView();
         addChild(_pyramidView);
         super.enter(param1,param2);
      }
      
      override public function leaving(param1:BaseStateView) : void
      {
         CacheSysManager.unlock(CacheConsts.ALERT_IN_PYRAMID);
         CacheSysManager.getInstance().release(CacheConsts.ALERT_IN_PYRAMID);
         KeyboardShortcutsManager.Instance.cancelForbidden();
         super.leaving(param1);
         dispose();
      }
      
      override public function getType() : String
      {
         return StateType.PYRAMID;
      }
      
      override public function getBackType() : String
      {
         return StateType.MAIN;
      }
      
      override public function dispose() : void
      {
         super.dispose();
         ObjectUtils.disposeObject(_pyramidView);
         _pyramidView = null;
         if(parent)
         {
            parent.removeChild(this);
         }
      }
   }
}
