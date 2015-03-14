package audio 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class AnimationCurve extends Sprite 
	{
		private var color:uint;
		private var baseWidth:Number;
		private var baseHeight:Number;
		public var points:Vector.<AnimationValue>;
		
		public function AnimationCurve(color:uint,baseWidth:Number,baseHeight:Number) 
		{
			super();
			this.baseHeight = baseHeight;
			this.baseWidth = baseWidth;
			this.color = color;
			
			reset();
			
		}
		
		public function addPoint(time:Number,value:Number):void
		{
			points.push(new AnimationValue(time, value));
			points.sort(sortOnTime);
			drawPoints();
		}
		
		private function sortOnTime(a1:AnimationValue,a2:AnimationValue):Number 
		{
			if (a1.time < a2.time) return -1;
			else if (a1.time > a2.time) return 1;
			else return 0;
		}
		
		public function setPoint(index:int, value:Number):void
		{
			if (index >= points.length) return;
			points[index].value = value;
		}
		
		public function setDataLinear(data:Vector.<Vector.<Number>>):void
		{
			points = new Vector.<AnimationValue>(data.length);
			for (var i:int = 0; i < data.length; i++)
			{
				points[i] = new AnimationValue(i / data.length, data[i][0]); //takes only the first element as the neural network wil only output one value
			}
			
			drawPoints();
		}
		
		public function drawPoints():void
		{
			graphics.clear();
			graphics.lineStyle(1, color,.8);
			graphics.moveTo(0, baseHeight);
			
			for each(var a:AnimationValue in points)
			{
				graphics.lineTo(a.time * baseWidth, (1 - a.value) * baseHeight);
			}
		}
		
		public function getValueAt(time:Number):Number
		{
			var prevVal:AnimationValue = points[0];
			for each(var a:AnimationValue in points)
			{
				if (a.time > time)
				{
					var relTime:Number = (time-prevVal.time) / (a.time-prevVal.time);
					var val:Number = prevVal.value + (a.value - prevVal.value) * relTime;
					return val;
				}
				
				prevVal = a;
			}
			
			return 0;
		}
		
		public function reset():void 
		{
			points = new Vector.<AnimationValue>();
			addPoint(0, 0);
			addPoint(1, 0);
		}
		
	}

}