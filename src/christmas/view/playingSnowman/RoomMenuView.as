package christmas.view.playingSnowman
{
   import com.pickgliss.events.FrameEvent;
   import com.pickgliss.toplevel.StageReferance;
   import com.pickgliss.ui.AlertManager;
   import com.pickgliss.ui.ComponentFactory;
   import com.pickgliss.ui.LayerManager;
   import com.pickgliss.ui.controls.SimpleBitmapButton;
   import com.pickgliss.ui.controls.alert.BaseAlerFrame;
   import com.pickgliss.ui.core.Disposeable;
   import com.pickgliss.ui.image.ScaleFrameImage;
   import com.pickgliss.utils.ObjectUtils;
   import ddt.manager.LanguageMgr;
   import ddt.manager.SocketManager;
   import ddt.manager.SoundManager;
   import flash.display.Bitmap;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class RoomMenuView extends Sprite implements Disposeable
   {
       
      
      private var _menuIsOpen:Boolean = true;
      
      private var _BG:Bitmap;
      
      private var _closeBtn:SimpleBitmapButton;
      
      private var _switchIMG:ScaleFrameImage;
      
      private var _returnBtn:SimpleBitmapButton;
      
      public function RoomMenuView()
      {
         super();
         this.initialize();
      }
      
      private function initialize() : void
      {
         this._BG = ComponentFactory.Instance.creatBitmap("asset.christmasRoom.menuBG");
         addChild(this._BG);
         this._closeBtn = ComponentFactory.Instance.creatComponentByStylename("asset.christmasRoom.switchBtn");
         addChild(this._closeBtn);
         this._switchIMG = ComponentFactory.Instance.creatComponentByStylename("asset.christmasRoom.switchIMG");
         this._switchIMG.setFrame(1);
         this._closeBtn.addChild(this._switchIMG);
         this._returnBtn = ComponentFactory.Instance.creatComponentByStylename("asset.christmasRoom.returnBtn");
         addChild(this._returnBtn);
         this.setEvent();
      }
      
      private function setEvent() : void
      {
         this._returnBtn.addEventListener(MouseEvent.CLICK,this.backRoomList);
         this._closeBtn.addEventListener(MouseEvent.CLICK,this.switchMenu);
      }
      
      private function backRoomList(_arg_1:MouseEvent) : void
      {
         SoundManager.instance.play("008");
         var _local_2:BaseAlerFrame = AlertManager.Instance.simpleAlert(LanguageMgr.GetTranslation("AlertDialog.Info"),LanguageMgr.GetTranslation("christmas.room.leaveroom"),LanguageMgr.GetTranslation("ok"),LanguageMgr.GetTranslation("cancel"),false,false,false,LayerManager.ALPHA_BLOCKGOUND);
         _local_2.addEventListener(FrameEvent.RESPONSE,this.__frameResponse);
      }
      
      private function __frameResponse(_arg_1:FrameEvent) : void
      {
         SoundManager.instance.play("008");
         var _local_2:BaseAlerFrame = _arg_1.currentTarget as BaseAlerFrame;
         _local_2.removeEventListener(FrameEvent.RESPONSE,this.__frameResponse);
         switch(_arg_1.responseCode)
         {
            case FrameEvent.ENTER_CLICK:
            case FrameEvent.SUBMIT_CLICK:
               SocketManager.Instance.out.sendLeaveChristmasRoom();
               SoundManager.instance.play("008");
               dispatchEvent(new Event(Event.CLOSE));
               break;
            case FrameEvent.CANCEL_CLICK:
            case FrameEvent.CLOSE_CLICK:
            case FrameEvent.ESC_CLICK:
               break;
            default:
               return;
         }
         _local_2.dispose();
      }
      
      private function switchMenu(_arg_1:MouseEvent) : void
      {
         SoundManager.instance.play("008");
         if(this._menuIsOpen)
         {
            this._switchIMG.setFrame(2);
         }
         else
         {
            this._switchIMG.setFrame(1);
         }
         addEventListener(Event.ENTER_FRAME,this.menuShowOrHide);
      }
      
      private function menuShowOrHide(_arg_1:Event) : void
      {
         var _local_2:int = 0;
         _local_2 = 34;
         if(this._menuIsOpen)
         {
            this.x += 20;
            if(this.x >= StageReferance.stageWidth - _local_2)
            {
               removeEventListener(Event.ENTER_FRAME,this.menuShowOrHide);
               this.x = StageReferance.stageWidth - _local_2;
               this._menuIsOpen = false;
            }
         }
         else
         {
            this.x -= 20;
            if(this.x <= StageReferance.stageWidth - this.width)
            {
               removeEventListener(Event.ENTER_FRAME,this.menuShowOrHide);
               this.x = StageReferance.stageWidth - this.width + 5;
               this._menuIsOpen = true;
            }
         }
      }
      
      public function dispose() : void
      {
         ObjectUtils.disposeAllChildren(this);
         if(this.parent)
         {
            this.parent.removeChild(this);
         }
         this._BG = null;
         this._closeBtn = null;
         this._switchIMG = null;
         this._returnBtn = null;
      }
   }
}
