package audio 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class TimelineEvent extends Event 
	{
		
		static public const TIME_CHANGED:String = "timeChanged";
		static public const SOUND_PROCESSED:String = "soundProcessed";
		
		public function TimelineEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new TimelineEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("TimelineEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}