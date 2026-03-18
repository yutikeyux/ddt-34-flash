package com.pickgliss.loader
{
	import flash.events.Event;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import com.pickgliss.loader.LoaderSavingManager; // Cache için eklendi
	
	public class CompressTextLoader extends BaseLoader
	{
		
		private var _deComressedText:String;
		
		public function CompressTextLoader(id:int, url:String, args:URLVariables = null, requestMethod:String = "GET")
		{
			if(args == null)
			{
				args = new URLVariables();
			}
			if(args["rnd"] == null)
			{
				args["rnd"] = TextLoader.TextLoaderKey;
			}
			super(id,url,args,requestMethod);
		}
		
		// YENİ EKLENEN FONKSİYON: Cache'ten (Diskten) Yükleme
		// LoaderManager bu fonksiyonu çağırdığında veriyi diskten okur ve işler
		override public function loadFromBytes(param1:ByteArray) : void
		{
			// Diskten gelen veri sıkıştırılmış formattadır.
			param1.position = 0;
			param1.uncompress(); // Veriyi çöz
			
			this._deComressedText = param1.readUTFBytes(param1.bytesAvailable);
			
			// Olayları tetikle (İlerleme ve Tamamlanma)
			_progress = 1;
			dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS,this));
			
			if(Boolean(analyzer))
			{
				analyzer.analyzeCompleteCall = fireCompleteEvent;
				analyzer.analyzeErrorCall = fireErrorEvent;
				analyzer.analyze(this._deComressedText);
			}
			else
			{
				fireCompleteEvent();
			}
		}
		
		override protected function __onDataLoadComplete(event:Event) : void
		{
			removeEvent();
			_loader.close();
			var temp:ByteArray = _loader.data;
			
			// YENİ EKLENEN KISIM: Webden indirilen veriyi Cache'e Kaydetme
			// .ashx uzantılı dosyalar (dinamik sorgular) cache'lenmez.
			if(_url && _url.indexOf(".ashx") == -1)
			{
				var cacheData:ByteArray = new ByteArray();
				// Orijinal veriyi bozmadan kopyalamak için writeBytes kullanıyoruz
				temp.position = 0;
				cacheData.writeBytes(temp, 0, temp.length);
				// Kaydet
				LoaderSavingManager.cacheFile(_url, cacheData, true);
			}
			
			// Orijinal Akış: Veriyi çöz ve kullan
			temp.uncompress();
			temp.position = 0;
			this._deComressedText = temp.readUTFBytes(temp.bytesAvailable);
			
			if(Boolean(analyzer))
			{
				analyzer.analyzeCompleteCall = fireCompleteEvent;
				analyzer.analyzeErrorCall = fireErrorEvent;
				analyzer.analyze(this._deComressedText);
			}
			else
			{
				fireCompleteEvent();
			}
		}
		
		override public function get content() : *
		{
			return this._deComressedText;
		}
		
		override public function get type() : int
		{
			return BaseLoader.COMPRESS_TEXT_LOADER;
		}
	}
}