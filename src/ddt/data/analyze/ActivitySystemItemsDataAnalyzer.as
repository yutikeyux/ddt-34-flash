package ddt.data.analyze
{
	import com.pickgliss.loader.DataAnalyzer;
	import com.pickgliss.utils.ObjectUtils;
	import chickActivation.data.ChickActivationInfo;
	import ddt.data.PyramidSystemItemsInfo;
	import guildMemberWeek.data.GuildMemberWeekItemsInfo;
	import guildMemberWeek.manager.GuildMemberWeekManager;
	
	public class ActivitySystemItemsDataAnalyzer extends DataAnalyzer
	{
		public var pyramidSystemDataList:Array;
		
		public var guildMemberWeekDataList:Array;
		
		public var chickActivationDataList:Array;
		
		public function ActivitySystemItemsDataAnalyzer(_arg_1:Function)
		{
			super(_arg_1);
		}
		
		override public function analyze(_arg_1:*) : void
		{
			var _local_3:XMLList = null;
			var _local_4:int = 0;
			var _local_5:PyramidSystemItemsInfo = null;
			var _local_6:Array = null;
			var _local_7:GuildMemberWeekItemsInfo = null;
			var _local_8:Array = null;
			var _local_13:ChickActivationInfo = null;
			var _local_14:Array = null;
			this.pyramidSystemDataList = [];
			this.guildMemberWeekDataList = [];
			this.chickActivationDataList = [];
			var _local_2:XML = new XML(_arg_1);
			if(_local_2.@value == "true")
			{
				_local_3 = _local_2..Item;
				_local_4 = 0;
				while(_local_4 < _local_3.length())
				{
					if(_local_3[_local_4].@ActivityType == "8")
					{
						_local_5 = new PyramidSystemItemsInfo();
						ObjectUtils.copyPorpertiesByXML(_local_5,_local_3[_local_4]);
						_local_6 = this.pyramidSystemDataList[_local_5.Quality - 1];
						if(!_local_6)
						{
							_local_6 = [];
						}
						_local_6.push(_local_5);
						this.pyramidSystemDataList[_local_5.Quality - 1] = _local_6;
					}
					else if(_local_3[_local_4].@ActivityType == String(GuildMemberWeekManager.instance.getGiftType))
					{
						_local_7 = new GuildMemberWeekItemsInfo();
						ObjectUtils.copyPorpertiesByXML(_local_7,_local_3[_local_4]);
						_local_8 = this.guildMemberWeekDataList[_local_7.Quality - 1];
						if(!_local_8)
						{
							_local_8 = [];
						}
						_local_8.push(_local_7);
						this.guildMemberWeekDataList[_local_7.Quality - 1] = _local_8;
					}
					else if(_local_3[_local_4].@ActivityType == "40")
					{
						_local_13 = new ChickActivationInfo();
						ObjectUtils.copyPorpertiesByXML(_local_13,_local_3[_local_4]);
						if(_local_13.Quality >= 10001 && _local_13.Quality <= 10010)
						{
							_local_14 = this.chickActivationDataList[12];
							if(!_local_14)
							{
								_local_14 = new Array();
							}
							_local_14.push(_local_13);
							_local_14.sortOn("Quality",Array.NUMERIC);
							this.chickActivationDataList[12] = _local_14;
						}
						else
						{
							_local_14 = this.chickActivationDataList[_local_13.Quality];
							if(!_local_14)
							{
								_local_14 = new Array();
							}
							_local_14.push(_local_13);
							this.chickActivationDataList[_local_13.Quality] = _local_14;
						}
					}
					_local_4++;
				}
				onAnalyzeComplete();
			}
			else
			{
				message = _local_2.@message;
				onAnalyzeError();
			}
		}
	}
}
