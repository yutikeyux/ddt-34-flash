package AvatarCollection.data
{
	import com.pickgliss.loader.DataAnalyzer;
	import road7th.data.DictionaryData;
	
	public class AvatarCollectionItemDataAnalyzer extends DataAnalyzer
	{
		
		private var _maleItemDic:DictionaryData;
		
		private var _femaleItemDic:DictionaryData;
		
		private var _maleItemList:Vector.<AvatarCollectionItemVo>;
		
		private var _femaleItemList:Vector.<AvatarCollectionItemVo>;
		
		public function AvatarCollectionItemDataAnalyzer(param1:Function)
		{
			super(param1);
		}
		
		override public function analyze(param1:*) : void
		{
			var _loc2_:XMLList = null;
			var _loc3_:int = 0;
			var _loc4_:AvatarCollectionItemVo = null;
			var _loc5_:int = 0;
			var _loc6_:XML = new XML(param1);
			this._maleItemDic = new DictionaryData();
			this._femaleItemDic = new DictionaryData();
			this._maleItemList = new Vector.<AvatarCollectionItemVo>();
			this._femaleItemList = new Vector.<AvatarCollectionItemVo>();
			if(_loc6_.@value == "true")
			{
				_loc2_ = _loc6_..Item;
				_loc3_ = 0;
				while(_loc3_ < _loc2_.length())
				{
					_loc4_ = new AvatarCollectionItemVo();
					_loc4_.id = _loc2_[_loc3_].@ID;
					_loc4_.itemId = _loc2_[_loc3_].@TemplateID;
					_loc4_.proArea = _loc2_[_loc3_].@Description;
					_loc4_.needGold = _loc2_[_loc3_].@Cost;
					_loc4_.sex = _loc2_[_loc3_].@Sex;
					_loc5_ = _loc4_.id;
					if(_loc4_.sex == 1)
					{
						if(!this._maleItemDic[_loc5_])
						{
							this._maleItemDic[_loc5_] = new DictionaryData();
						}
						this._maleItemDic[_loc5_].add(_loc4_.itemId,_loc4_);
						this._maleItemList.push(_loc4_);
					}
					else
					{
						if(!this._femaleItemDic[_loc5_])
						{
							this._femaleItemDic[_loc5_] = new DictionaryData();
						}
						this._femaleItemDic[_loc5_].add(_loc4_.itemId,_loc4_);
						this._femaleItemList.push(_loc4_);
					}
					_loc3_++;
				}
				onAnalyzeComplete();
			}
			else
			{
				message = _loc6_.@message;
				onAnalyzeError();
			}
		}
		
		public function get maleItemDic() : DictionaryData
		{
			return this._maleItemDic;
		}
		
		public function get femaleItemDic() : DictionaryData
		{
			return this._femaleItemDic;
		}
		
		public function get maleItemList() : Vector.<AvatarCollectionItemVo>
		{
			return this._maleItemList;
		}
		
		public function get femaleItemList() : Vector.<AvatarCollectionItemVo>
		{
			return this._femaleItemList;
		}
	}
}

