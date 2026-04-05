package room.view.roomView
{
	import com.pickgliss.events.FrameEvent;
	import com.pickgliss.ui.controls.Frame;
	import ddt.manager.MessageTipManager;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.display.Loader;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	
	public class MusicFrame extends Frame
	{
		// SUNUCU AYARLARI
		private const BASE_URL:String = "http://88.209.248.52/ddt-res-s1/sound/";
		private const IMAGE_URL:String = "http://88.209.248.52/karakterpng/muzikarayuz.png";
		private const FILE_EXT:String = ".mp3"; 
		
		// Görsel Elemanlar
		private var _mainBg:Shape;
		private var _closeBtn:Sprite;
		private var _charLoader:Loader;
		private var _dialogBubble:Sprite;
		
		// Liste ve Scroll Elemanları
		private var _genreContainer:Sprite; // Tür butonlarının olduğu yer
		private var _listContainer:Sprite;  // Liste alanı (Maske uygulanacak)
		private var _listContent:Sprite;    // İçerik (Kayacak olan kısım)
		private var _scrollTrack:Sprite;    // Scroll arka planı
		private var _scrollThumb:Sprite;    // Scroll tutamaçı
		
		// Veri Yapısı (Türler ve Şarkılar)
		private var _musicLibrary:Object = {
			"Taan": [
				{ label: "Bohça", file: "pop1" + FILE_EXT },
				{ label: "Şurup", file: "pop2" + FILE_EXT },
				{ label: "Sarı Rüya", file: "pop3" + FILE_EXT },
				{ label: "Hazine", file: "pop4" + FILE_EXT },
				{ label: "Bekleme Odası", file: "pop5" + FILE_EXT },
				{ label: "Özür Ağacı", file: "pop6" + FILE_EXT },
				{ label: "Ana Tema", file: "pop7" + FILE_EXT },
				{ label: "İnşaat", file: "pop8" + FILE_EXT },
				{ label: "Mağara", file: "pop9"+ FILE_EXT },
				{ label: "Bulut", file: "pop10" + FILE_EXT },
				{ label: "Vites", file: "pop11" + FILE_EXT },
				{ label: "Üzümler", file: "pop12" + FILE_EXT },
				{ label: "Balkabağı", file: "pop13" + FILE_EXT },
				{ label: "Hoparlör", file: "pop14" + FILE_EXT },
				{ label: "Doğu Ekspresi", file: "pop15" + FILE_EXT },
				{ label: "Buz Kalesi", file: "pop16" + FILE_EXT }
			],
			"DDTank": [
				{ label: "Rock 1 - Efsane Gitar", file: "rock1" + FILE_EXT },
				{ label: "Rock 2 - Deprem", file: "rock2" + FILE_EXT },
				{ label: "Rock 3 - Metal Gürültü", file: "rock3" + FILE_EXT },
				{ label: "Rock 4 - Devrilmeyen", file: "rock4" + FILE_EXT }
			],
			"Eskiler": [
				{ label: "Slow 1 - Hüzünlü Akşam", file: "slow1" + FILE_EXT },
				{ label: "Slow 2 - Romantik Yemek", file: "slow2" + FILE_EXT },
				{ label: "Slow 3 - Nostalji", file: "slow3" + FILE_EXT }
			],
			"Yeniler": [
				{ label: "Oyun 1 - Boss Teması", file: "game1" + FILE_EXT },
				{ label: "Oyun 2 - Kasaba Müziği", file: "game2" + FILE_EXT },
				{ label: "Oyun 3 - Savaş Alanı", file: "game3" + FILE_EXT },
				{ label: "Oyun 4 - Zafer", file: "game4" + FILE_EXT },
				{ label: "Oyun 5 - Final", file: "game5" + FILE_EXT }
			],
			"Özel": [
				{ label: "Özel 1 - DJ Mix", file: "ozel1" + FILE_EXT },
				{ label: "Özel 2 - Canlı Performans", file: "ozel2" + FILE_EXT }
			]
		};
		
		private var _currentGenre:String = "Pop Hits"; // Varsayılan kategori
		private static var _currentSoundChannel:SoundChannel;
		private static var _currentSound:Sound;
		
		public function MusicFrame()
		{
			super();
			titleText = "♫ Oda Müziği Sistemi";
			this.width = 650;
			this.height = 420;
			this.initView();
			this.initEvents();
		}
		
		private function initView() : void
		{
			drawBackground();
			createCloseButton();
			loadCharacterImage();
			createDialogBubble();
			createGenreTabs();
			createListContainer();
			createScrollBar();
			
			// İlk listeyi yükle
			updateList(_currentGenre);
		}
		
		// --- 1. ARKA PLAN ---
		private function drawBackground():void
		{
			_mainBg = new Shape();
			var g = _mainBg.graphics;
			g.beginFill(0x1F1F2E, 1);
			g.lineStyle(2, 0xFFCC00);
			g.drawRoundRect(0, 0, 630, 380, 15, 15);
			g.endFill();
			_mainBg.x = 10;
			_mainBg.y = 35;
			addToContent(_mainBg);
		}
		
		// --- 2. KAPATMA BUTONU ---
		private function createCloseButton():void
		{
			_closeBtn = new Sprite();
			_closeBtn.graphics.beginFill(0x8B0000, 1);
			_closeBtn.graphics.lineStyle(1, 0xFFFFFF);
			_closeBtn.graphics.drawCircle(10, 10, 10);
			_closeBtn.graphics.endFill();
			_closeBtn.graphics.lineStyle(2, 0xFFFFFF);
			_closeBtn.graphics.moveTo(5, 5);
			_closeBtn.graphics.lineTo(15, 15);
			_closeBtn.graphics.moveTo(15, 5);
			_closeBtn.graphics.lineTo(5, 15);
			_closeBtn.x = 610;
			_closeBtn.y = 5;
			_closeBtn.buttonMode = true;
			addToContent(_closeBtn);
		}
		
		// --- 3. KARAKTER RESMİ (Sol Alt) ---
		private function loadCharacterImage():void
		{
			_charLoader = new Loader();
			_charLoader.x = 20;
			_charLoader.y = 420; // Başlangıçta ekran dışı
			
			_charLoader.load(new URLRequest(IMAGE_URL));
			_charLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageLoaded);
			_charLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageError);
			addToContent(_charLoader);
		}
		
		private function onImageLoaded(e:Event):void
		{
			// Resim yüklendikten sonra boyutunu ve konumunu ayarla
			try {
				_charLoader.height = 250;
				_charLoader.scaleX = _charLoader.scaleY; // Oranı koru
				_charLoader.x = 30;
				_charLoader.y = 420 - _charLoader.height - 20; // Pencere altına yasla
			} catch(err:Error) {}
		}
		
		private function onImageError(e:IOErrorEvent):void { trace("Resim yüklenemedi."); }
		
		// --- 4. KONUŞMA BALONU (Sol Üst) ---
		private function createDialogBubble():void
		{
			_dialogBubble = new Sprite();
			var bubble:Shape = new Shape();
			bubble.graphics.beginFill(0xFFFFFF, 1);
			bubble.graphics.lineStyle(1, 0xCCCCCC);
			bubble.graphics.drawRoundRect(0, 0, 200, 70, 10, 10);
			bubble.graphics.endFill();
			_dialogBubble.addChild(bubble);
			
			var txt:TextField = new TextField();
			txt.width = 180;
			txt.height = 60;
			txt.x = 10;
			txt.y = 5;
			txt.wordWrap = true;
			txt.multiline = true;
			txt.selectable = false;
			txt.text = "Merhaba! Yukarıdan türü seç, aşağıdan şarkıyı tıkla. Müziğin tadını çıkar!";
			var tf:TextFormat = new TextFormat("Arial", 11, 0x333333);
			txt.defaultTextFormat = tf;
			_dialogBubble.addChild(txt);
			
			_dialogBubble.x = 40;
			_dialogBubble.y = 50;
			addToContent(_dialogBubble);
		}
		
		// --- 5. TÜR SEKMELERİ (Genre Tabs) ---
		private function createGenreTabs():void
		{
			_genreContainer = new Sprite();
			_genreContainer.x = 270;
			_genreContainer.y = 55;
			addToContent(_genreContainer);
			
			var xPos:int = 0;
			for (var genre:String in _musicLibrary)
			{
				var tab:Sprite = createGenreTab(genre);
				tab.x = xPos;
				_genreContainer.addChild(tab);
				xPos += 70; // Sekme aralığı
			}
		}
		
		private function createGenreTab(name:String):Sprite
		{
			var tab:Sprite = new Sprite();
			tab.name = name;
			
			var bg:Shape = new Shape();
			bg.name = "bg";
			bg.graphics.beginFill(0x333344, 1);
			bg.graphics.drawRoundRect(0, 0, 65, 25, 5, 5);
			bg.graphics.endFill();
			tab.addChild(bg);
			
			var txt:TextField = new TextField();
			txt.text = name;
			txt.width = 65;
			txt.height = 25;
			txt.selectable = false;
			txt.mouseEnabled = false;
			txt.textColor = 0xAAAAAA;
			txt.defaultTextFormat = new TextFormat("Arial", 10, 0xAAAAAA, null, null, null, null, null, "center");
			tab.addChild(txt);
			
			tab.buttonMode = true;
			tab.addEventListener(MouseEvent.CLICK, onGenreClick);
			
			// Aktif olanı boyayalım
			if(name == _currentGenre) {
				txt.textColor = 0xFFCC00;
				bg.graphics.clear();
				bg.graphics.beginFill(0x444455, 1);
				bg.graphics.drawRoundRect(0, 0, 65, 25, 5, 5);
				bg.graphics.endFill();
			}
			
			return tab;
		}
		
		private function onGenreClick(e:MouseEvent):void
		{
			var clickedTab:Sprite = e.currentTarget as Sprite;
			_currentGenre = clickedTab.name;
			updateList(_currentGenre);
			refreshTabStyles();
		}
		
		private function refreshTabStyles():void
		{
			for(var i:int = 0; i < _genreContainer.numChildren; i++)
			{
				var tab:Sprite = _genreContainer.getChildAt(i) as Sprite;
				var txt:TextField = tab.getChildAt(1) as TextField; // 0 index bg, 1 index text
				var bg:Shape = tab.getChildAt(0) as Shape;
				
				if(tab.name == _currentGenre) {
					txt.textColor = 0xFFCC00;
					bg.graphics.clear();
					bg.graphics.beginFill(0x444455, 1);
					bg.graphics.drawRoundRect(0, 0, 65, 25, 5, 5);
					bg.graphics.endFill();
				} else {
					txt.textColor = 0xAAAAAA;
					bg.graphics.clear();
					bg.graphics.beginFill(0x333344, 1);
					bg.graphics.drawRoundRect(0, 0, 65, 25, 5, 5);
					bg.graphics.endFill();
				}
			}
		}
		
		// --- 6. LİSTE ALANI VE SCROLL ---
		private function createListContainer():void
		{
			// Liste Arka Planı
			var listBg:Shape = new Shape();
			listBg.graphics.beginFill(0x222233, 0.8);
			listBg.graphics.drawRect(0, 0, 330, 260);
			listBg.graphics.endFill();
			listBg.x = 270;
			listBg.y = 90;
			addToContent(listBg);
			
			// Container (Maske uygulanacak sabit alan)
			_listContainer = new Sprite();
			_listContainer.x = 270;
			_listContainer.y = 90;
			addToContent(_listContainer);
			
			// Maske
			var mask:Shape = new Shape();
			mask.graphics.beginFill(0xFF0000);
			mask.graphics.drawRect(0, 0, 330, 260);
			mask.graphics.endFill();
			_listContainer.addChild(mask);
			_listContainer.mask = mask;
			
			// İçerik (Kayacak olan)
			_listContent = new Sprite();
			_listContainer.addChild(_listContent);
			
			// Mouse Scroll Event
			_listContainer.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		}
		
		private function updateList(genre:String):void
		{
			// İçeriği temizle
			while(_listContent.numChildren > 0) {
				var item:Sprite = _listContent.getChildAt(0) as Sprite;
				if(item) {
					item.removeEventListener(MouseEvent.CLICK, __playSound);
				}
				_listContent.removeChildAt(0);
			}
			
			// Yeni listeyi oluştur
			var songs:Array = _musicLibrary[genre] as Array;
			var yPos:int = 0;
			
			for each(var song:Object in songs)
			{
				var listItem:Sprite = createListItem(song.label, song.file);
				listItem.y = yPos;
				_listContent.addChild(listItem);
				yPos += 35;
			}
			
			// Scrollu sıfırla
			_listContent.y = 0;
			updateScrollThumb();
		}
		
		private function createListItem(label:String, fileName:String):Sprite
		{
			var item:Sprite = new Sprite();
			item.name = fileName;
			
			var bg:Shape = new Shape();
			bg.graphics.beginFill(0x2A2A3A, 1);
			bg.graphics.drawRoundRect(0, 0, 310, 30, 6, 6);
			bg.graphics.endFill();
			item.addChild(bg);
			
			var txt:TextField = new TextField();
			txt.text = label;
			txt.width = 280;
			txt.height = 30;
			txt.x = 15;
			txt.y = 3;
			txt.textColor = 0xEEEEEE;
			txt.selectable = false;
			txt.mouseEnabled = false;
			item.addChild(txt);
			
			item.buttonMode = true;
			item.useHandCursor = true;
			
			item.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
				txt.textColor = 0xFFFFFF;
				bg.graphics.clear();
				bg.graphics.beginFill(0x3A3A5A, 1);
				bg.graphics.drawRoundRect(0, 0, 310, 30, 6, 6);
				bg.graphics.endFill();
			});
			
			item.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void {
				txt.textColor = 0xEEEEEE;
				bg.graphics.clear();
				bg.graphics.beginFill(0x2A2A3A, 1);
				bg.graphics.drawRoundRect(0, 0, 310, 30, 6, 6);
				bg.graphics.endFill();
			});
			
			item.addEventListener(MouseEvent.CLICK, __playSound);
			return item;
		}
		
		// --- 7. SCROLL BAR ---
		private function createScrollBar():void
		{
			// Track (Yol)
			_scrollTrack = new Sprite();
			_scrollTrack.graphics.beginFill(0x333344, 1);
			_scrollTrack.graphics.drawRoundRect(0, 0, 10, 260, 5, 5);
			_scrollTrack.graphics.endFill();
			_scrollTrack.x = 605;
			_scrollTrack.y = 90;
			addToContent(_scrollTrack);
			
			// Thumb (Tutamaç)
			_scrollThumb = new Sprite();
			_scrollThumb.graphics.beginFill(0xFFCC00, 1);
			_scrollThumb.graphics.drawRoundRect(0, 0, 10, 50, 5, 5);
			_scrollThumb.graphics.endFill();
			_scrollThumb.x = 605;
			_scrollThumb.y = 90;
			addToContent(_scrollThumb);
			
			_scrollThumb.buttonMode = true;
			_scrollThumb.addEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
		}
		
		private function onMouseWheel(e:MouseEvent):void
		{
			var maxScroll:Number = _listContent.height - 260;
			if(maxScroll < 0) return;
			
			_listContent.y += e.delta * 2; // Kaydırma hızı
			_listContent.y = Math.max(-maxScroll, Math.min(0, _listContent.y)); // Sınırlar
			
			updateScrollThumb();
		}
		
		private function onStartDrag(e:MouseEvent):void
		{
			// ScrollThumb'ı sürükleme
			var bounds:Rectangle = new Rectangle(605, 90, 0, 210); // 260 height - 50 thumb height = 210 movement area
			_scrollThumb.startDrag(false, bounds);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onScrollDrag);
			stage.addEventListener(MouseEvent.MOUSE_UP, onStopDrag);
		}
		
		private function onScrollDrag(e:MouseEvent):void
		{
			// Thumb pozisyonuna göre listeyi ayarla
			var scrollPercent:Number = (_scrollThumb.y - 90) / 210;
			var maxContentY:Number = _listContent.height - 260;
			
			if(maxContentY > 0) {
				_listContent.y = - (maxContentY * scrollPercent);
			}
		}
		
		private function onStopDrag(e:MouseEvent):void
		{
			_scrollThumb.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onScrollDrag);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStopDrag);
		}
		
		private function updateScrollThumb():void
		{
			var maxScroll:Number = _listContent.height - 260;
			if(maxScroll <= 0) {
				_scrollThumb.visible = false;
				return;
			}
			
			_scrollThumb.visible = true;
			var scrollPercent:Number = Math.abs(_listContent.y) / maxScroll;
			_scrollThumb.y = 90 + (scrollPercent * 210);
		}
		
		// --- SES KONTROL ---
		private function __playSound(event:MouseEvent) : void
		{
			var item:Sprite = event.currentTarget as Sprite;
			var fileName:String = item.name;
			var fullUrl:String = BASE_URL + fileName;
			
			try
			{
				stopCurrentSound();
				
				_currentSound = new Sound();
				_currentSound.load(new URLRequest(fullUrl));
				_currentSoundChannel = _currentSound.play();
				
				MessageTipManager.getInstance().show("🎶 Çalınıyor"); // texti alıyoruz
			}
			catch(e:Error)
			{
				MessageTipManager.getInstance().show("Hata: Dosya bulunamadı!");
			}
		}
		
		private function __stopSound(event:MouseEvent) : void
		{
			stopCurrentSound();
			MessageTipManager.getInstance().show("Müzik durduruldu.");
		}
		
		private function stopCurrentSound() : void
		{
			if(_currentSoundChannel)
			{
				_currentSoundChannel.stop();
				_currentSoundChannel = null;
			}
		}
		
		// --- EVENT YÖNETİMİ ---
		private function initEvents() : void
		{
			addEventListener(FrameEvent.RESPONSE, __frameResponse);
			_closeBtn.addEventListener(MouseEvent.CLICK, __closeWindow);
		}
		
		private function removeEvents() : void
		{
			removeEventListener(FrameEvent.RESPONSE, __frameResponse);
			if(_closeBtn) _closeBtn.removeEventListener(MouseEvent.CLICK, __closeWindow);
			if(_scrollThumb) {
				_scrollThumb.removeEventListener(MouseEvent.MOUSE_DOWN, onStartDrag);
				_scrollThumb.removeEventListener(MouseEvent.MOUSE_UP, onStopDrag);
			}
		}
		
		private function __closeWindow(event:MouseEvent):void { dispose(); }
		
		private function __frameResponse(event:FrameEvent) : void
		{
			if(event.responseCode == FrameEvent.CLOSE_CLICK || event.responseCode == FrameEvent.ESC_CLICK) dispose();
		}
		
		override public function dispose() : void
		{
			removeEvents();
			super.dispose();
		}
	}
}