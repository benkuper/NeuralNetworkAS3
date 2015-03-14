package neural 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class NeuralEvent extends Event 
	{
		
		static public const RUN_FINISH:String = "runFinish";
		
		public function NeuralEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new NeuralEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("NeuralEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}