package game
{
	import flash.events.MouseEvent;
	import game.model.MissionAgainInfo;
	import ddt.events.GameEvent;
	import ddt.manager.GameInSocketOut;
	import room.RoomManager;
	import ddt.manager.SoundManager;
	
	public class TryAgainCost extends TryAgain
	{
		public function TryAgainCost(param1:MissionAgainInfo, param2:Boolean = true)
		{
			super(param1, param2);
		}
		
		override protected function __tryagainClick(param1:MouseEvent) : void
		{
			if(param1)
			{
				SoundManager.instance.play("008");
			}
			if(RoomManager.Instance.current.selfRoomPlayer.isHost)
			{
				GameInSocketOut.sendMissionTryAgainCost(1, true); 
			}
			dispatchEvent(new GameEvent(GameEvent.TryAgainCost, true)); 
		}
	}
}