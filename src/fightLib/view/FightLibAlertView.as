package fightLib.view
{
	import bagAndInfo.cell.BaseCell;
	import com.pickgliss.toplevel.StageReferance;
	import com.pickgliss.ui.ComponentFactory;
	import com.pickgliss.ui.LayerManager;
	import com.pickgliss.ui.controls.TextButton;
	import com.pickgliss.ui.core.Disposeable;
	import com.pickgliss.ui.text.FilterFrameText;
	import com.pickgliss.utils.ObjectUtils;
	import ddt.data.goods.ItemTemplateInfo;
	import ddt.manager.ItemManager;
	import ddt.manager.LanguageMgr;
	import ddt.manager.SoundManager;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class FightLibAlertView extends Sprite implements Disposeable
	{
		
		private static const ButtonToCenter:int = 8;
		
		
		private var _background:DisplayObject;
		
		private var _girlImage:Bitmap;
		
		private var _txt:FilterFrameText;
		
		private var _infoStr:String;
		
		private var _okLabel:String;
		
		private var _okBtn:TextButton;
		
		private var _okFun:Function;
		
		private var _cancelLabel:String;
		
		private var _cancelBtn:TextButton;
		
		private var _cancelFun:Function;
		
		private var _showOkBtn:Boolean;
		
		private var _showCancelBtn:Boolean;
		
		private var _centerPosition:Point;
		
		private var _WeaponCellArr:Array;
		
		// Tooltip için yeni değişkenler
		private var _tipBg:Sprite;
		private var _tipTxt:FilterFrameText;
		
		public function FightLibAlertView(param1:String, param2:String = null, param3:Function = null, param4:String = null, param5:Function = null, param6:Boolean = true, param7:Boolean = false, param8:Array = null)
		{
			this._okLabel = LanguageMgr.GetTranslation("ok");
			this._cancelLabel = LanguageMgr.GetTranslation("tank.command.fightLibCommands.script.MeasureScree.watchAgain");
			super();
			this._infoStr = param1;
			if(param2)
			{
				this._okLabel = param2;
			}
			this._okFun = param3;
			if(param4)
			{
				this._cancelLabel = param4;
			}
			this._cancelFun = param5;
			this._showOkBtn = param6;
			this._showCancelBtn = param7;
			this.configUI();
			this.addEvent();
			if(!this._showCancelBtn)
			{
				this._okBtn.x = this._centerPosition.x - this._okBtn.width / 2;
			}
			else
			{
				this._okBtn.x = this._centerPosition.x - this._okBtn.width - ButtonToCenter;
				this._cancelBtn.x = this._centerPosition.x + ButtonToCenter;
			}
			this._okBtn.y = this._cancelBtn.y = this._centerPosition.y;
			this._okBtn.visible = this._showOkBtn;
			this._cancelBtn.visible = this._showCancelBtn;
			if(param8 != null)
			{
				this.ShowWeaponIcon(param8);
			}
		}
		
		private function ShowWeaponIcon(param1:Array) : void
		{
			var _loc2_:ItemTemplateInfo = null;
			var _loc4_:int = 0;
			var _loc6_:BaseCell = null;
			
			_loc2_ = null;
			_loc4_ = 0;
			var _loc5_:Sprite = null;
			_loc6_ = null;
			
			this._WeaponCellArr = new Array();
			var _loc3_:int = param1.length;
			_loc4_ = 0;
			while(_loc4_ < _loc3_)
			{
				_loc5_ = new Sprite();
				_loc5_.graphics.beginFill(16777215,0);
				_loc5_.graphics.drawRect(0,0,60,60);
				_loc5_.graphics.endFill();
				_loc2_ = ItemManager.Instance.getTemplateById(param1[_loc4_]);
				_loc6_ = new BaseCell(_loc5_,_loc2_,true,false);
				_loc6_.x = 30 + _loc4_ * 70;
				_loc6_.y = 59;
				addChild(_loc6_);
				this._WeaponCellArr.push(_loc6_);
				
				// Silah ismi için altta yazı oluşturma kısmı kaldırıldı.
				// Bunun yerine mouse olaylarını ekle.
				_loc6_.addEventListener(MouseEvent.ROLL_OVER, this.__onCellOver);
				_loc6_.addEventListener(MouseEvent.ROLL_OUT, this.__onCellOut);
				
				_loc4_++;
			}
		}
		
		// --- Tooltip Olayları ---
		
		private function __onCellOver(e:MouseEvent) : void
		{
			var cell:BaseCell = e.currentTarget as BaseCell;
			if(cell && cell.info)
			{
				var name:String = cell.info.Name.slice(2);
				this.showTip(name);
				// Mouse hareket ettikçe tooltip'in takip etmesi için stage'e ekle
				StageReferance.stage.addEventListener(MouseEvent.MOUSE_MOVE, this.__onStageMouseMove);
			}
		}
		
		private function __onCellOut(e:MouseEvent) : void
		{
			this.hideTip();
			StageReferance.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.__onStageMouseMove);
		}
		
		private function __onStageMouseMove(e:MouseEvent) : void
		{
			this.updateTipPosition(e.stageX, e.stageY);
		}
		//
		private function showTip(text:String) : void
		{
			if(!this._tipTxt || !this._tipBg) return;
			
			this._tipTxt.text = text;
			this._tipTxt.visible = true;////
			this._tipBg.visible = true;
			
			// Arka planı yazının genişliğine göre ayarla
			this._tipBg.width = this._tipTxt.textWidth + 10;
			this._tipBg.height = this._tipTxt.textHeight + 8;
		 //this.updateTipPosition(StageReferance.mouseX, StageReferance.mouseY);
		}
		
		private function hideTip() : void
		{
			if(this._tipTxt) this._tipTxt.visible = false;
			if(this._tipBg) this._tipBg.visible = false;
		}
		
		private function updateTipPosition(stageX:Number, stageY:Number) : void
		{
			if(!this._tipTxt || !this._tipBg) return;
			
			// Mouse koordinatını bu View içindeki koordinatlara çevir
			var localPoint:Point = this.globalToLocal(new Point(stageX, stageY));
			
			// Tooltip'i biraz sağa ve aşağı kaydır
			this._tipTxt.x = localPoint.x + 15;
			this._tipTxt.y = localPoint.y + 15;
			
			this._tipBg.x = localPoint.x + 10;
			this._tipBg.y = localPoint.y + 10;
		}
		
		// -------------------------
		
		public function dispose() : void
		{
			var _loc1_:int = 0;
			this.removeEvent();
			if(this._WeaponCellArr != null)
			{
				_loc1_ = 0;
				while(_loc1_ < this._WeaponCellArr.length)
				{
					// Silah hücrelerinden tooltip olaylarını kaldır
					this._WeaponCellArr[_loc1_].removeEventListener(MouseEvent.ROLL_OVER, this.__onCellOver);
					this._WeaponCellArr[_loc1_].removeEventListener(MouseEvent.ROLL_OUT, this.__onCellOut);
					this._WeaponCellArr[_loc1_].dispose();
					_loc1_++;
				}
			}
			// Stage listener temizliği
			StageReferance.stage.removeEventListener(MouseEvent.MOUSE_MOVE, this.__onStageMouseMove);
			
			ObjectUtils.disposeAllChildren(this);
			this._background = null;
			this._girlImage = null;
			this._cancelBtn = null;
			this._cancelFun = null;
			this._okBtn = null;
			this._okFun = null;
			this._txt = null;
			this._WeaponCellArr = null;
			this._tipBg = null;
			this._tipTxt = null;
		}
		
		public function show() : void
		{
			x = StageReferance.stageWidth - width >> 1;
			y = StageReferance.stageHeight - height >> 1;
			this._txt.text = this._infoStr;
			this.updataWeaponIcon();
			LayerManager.Instance.addToLayer(this,LayerManager.GAME_UI_LAYER);
		}
		
		private function updataWeaponIcon() : void
		{
		}
		
		public function hide() : void
		{
			if(parent)
			{
				parent.removeChild(this);
			}
		}
		
		public function set alert(param1:String) : void
		{
			this._txt.text = param1;
		}
		
		public function get alert() : String
		{
			return this._txt.text;
		}
		
		private function configUI() : void
		{
			this._centerPosition = ComponentFactory.Instance.creatCustomObject("fithtLib.Alert.CenterPosition");
			this._background = ComponentFactory.Instance.creatComponentByStylename("fightLib.Game.GirlGuildBack");
			addChild(this._background);
			this._girlImage = ComponentFactory.Instance.creatBitmap("fightLib.Game.GirlGuild.Girl");
			this._girlImage.scaleX = -0.6;
			this._girlImage.scaleY = 0.6;
			addChild(this._girlImage);
			this._txt = ComponentFactory.Instance.creatComponentByStylename("fightLib.Alert.AlertField");
			addChild(this._txt);
			this._okBtn = ComponentFactory.Instance.creatComponentByStylename("fightLib.Alert.SubmitButton");
			if(this._okLabel != null)
			{
				this._okBtn.text = this._okLabel;
			}
			else
			{
				this._okBtn.text = LanguageMgr.GetTranslation("ok");
			}
			addChild(this._okBtn);
			this._cancelBtn = ComponentFactory.Instance.creatComponentByStylename("fightLib.Alert.CancelButton");
			if(this._cancelLabel != null)
			{
				this._cancelBtn.text = this._cancelLabel;
			}
			else
			{
				this._cancelBtn.text = LanguageMgr.GetTranslation("cancel");
			}
			addChild(this._cancelBtn);
			
			// Tooltip nesnelerini oluştur (Başlangıçta gizli)
			this._tipBg = new Sprite();
			this._tipBg.graphics.beginFill(0, 0.7); // Siyah yarı saydam arka plan
			this._tipBg.graphics.drawRoundRect(0, 0, 100, 20, 5, 5);
			this._tipBg.graphics.endFill();
			this._tipBg.visible = false;
			addChild(this._tipBg);
			
			this._tipTxt = ComponentFactory.Instance.creatComponentByStylename("fightLib.WeaponNameField");
			this._tipTxt.visible = false;
			addChild(this._tipTxt);
		}
		
		private function addEvent() : void
		{
			this._okBtn.addEventListener(MouseEvent.CLICK,this.__submitClicked);
			this._cancelBtn.addEventListener(MouseEvent.CLICK,this.__cancelClicked);
		}
		
		private function __cancelClicked(param1:MouseEvent) : void
		{
			SoundManager.instance.play("008");
			if(this._cancelFun != null)
			{
				this._cancelFun();
			}
		}
		
		private function __submitClicked(param1:MouseEvent) : void
		{
			SoundManager.instance.play("008");
			if(this._okFun != null)
			{
				this._okFun();
			}
		}
		
		private function removeEvent() : void
		{
			this._okBtn.removeEventListener(MouseEvent.CLICK,this.__submitClicked);
			this._cancelBtn.removeEventListener(MouseEvent.CLICK,this.__cancelClicked);
		}
	}
}