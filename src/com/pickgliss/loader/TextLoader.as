package com.pickgliss.loader
{
	import flash.events.Event;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLVariables;
	import flash.utils.ByteArray; // EKLENDİ
	import com.pickgliss.loader.LoaderSavingManager; // EKLENDİ
	
	public class TextLoader extends BaseLoader
	{
		
		public static var TextLoaderKey:String;
		
		public function TextLoader(param1:int, param2:String, param3:URLVariables = null, param4:String = "GET")
		{
			super(param1,param2,param3,param4);
		}
		
		override public function get content() : *
		{
			return _loader.data;
		}
		
		// YENİ EKLENEN FONKSİYON: Önbellekten (Cache) yükleme
		override public function loadFromBytes(param1:ByteArray) : void
		{
			// Diskten okunan veriyi string'e çevir
			param1.position = 0;
			var dataStr:String = param1.readUTFBytes(param1.bytesAvailable);
			
			// Veriyi loader'a işle
			_loader.data = dataStr;
			
			// Analiz işlemlerini başlat (orijinal complete mantığı)
			if(analyzer)
			{
				analyzer.analyzeCompleteCall = fireCompleteEvent;
				analyzer.analyzeErrorCall = fireErrorEvent;
				analyzer.analyze(dataStr);
			}
			else
			{
				fireCompleteEvent();
			}
		}
		
		override protected function __onDataLoadComplete(param1:Event) : void
		{
			removeEvent();
			_loader.close();
			
			// YENİ EKLENEN KISIM: İndirilen veriyi diske kaydet (.ashx uzantılı dinamik dosyaları kaydetmemek için kontrol)
			if(_url && _url.indexOf(".ashx") == -1)
			{
				var ba:ByteArray = new ByteArray();
				ba.writeUTFBytes(_loader.data);
				LoaderSavingManager.cacheFile(_url, ba, true);
			}
			
			if(analyzer)
			{
				analyzer.analyzeCompleteCall = fireCompleteEvent;
				analyzer.analyzeErrorCall = fireErrorEvent;
				analyzer.analyze(_loader.data);
			}
			else
			{
				fireCompleteEvent();
			}
		}
		
		override protected function getLoadDataFormat() : String
		{
			return URLLoaderDataFormat.TEXT;
		}
		
		override public function get type() : int
		{
			return BaseLoader.TEXT_LOADER;
		}
	}
}