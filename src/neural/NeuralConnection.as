package neural 
{
	import ui.fonts.Fonts;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class NeuralConnection extends Sprite 
	{
		
		public var inNeuron:Neuron;
		public var outNeuron:Neuron;
		
		public var weight:Number;
		
		public var tf:TextField;
		
		public static var instances:Vector.<NeuralConnection>;
		
		public function NeuralConnection(_in:Neuron,_out:Neuron) 
		{
			if (instances == null) instances = new Vector.<NeuralConnection>();
			instances.push(this);
			
			super();
			//tf = Fonts.createTF("info", Fonts.normal);
			//addChild(tf);
			
			weight = ((Math.random() - .5)*2)*NeuralNetwork.WEIGHT_RANDOM_FACTOR;
			inNeuron = _in;
			outNeuron = _out;
			draw();
		}
		
		
		public function sendAmount(amount:Number):void
		{
			var weightedAmount:Number = amount * weight;
			outNeuron.addAmount(weightedAmount);
		}
		
		public function draw():void 
		{
			var p1:Point = inNeuron.localToGlobal(new Point());
			var p2:Point = outNeuron.localToGlobal(new Point());
			
			graphics.clear();
			graphics.lineStyle(2, 0x373737);
			graphics.moveTo(p1.x, p1.y);
			graphics.lineTo(p2.x, p2.y);
			
			var radius:Number = 10;
			
			var mp:Point = Point.interpolate(p2,p1, .3);
			//tf.x = mp.x
			//tf.y = mp.y + radius;
			
			
			graphics.drawCircle(mp.x, mp.y, radius);
			graphics.lineStyle();
			graphics.beginFill(weight<0?0xDC40FD:0xD0F14B);
			graphics.drawCircle(mp.x, mp.y, Math.abs(weight) * radius / NeuralNetwork.WEIGHT_RANDOM_FACTOR);
			graphics.endFill();
			
			//tf.text = "Weight = " + weight.toFixed(2);
		}		
		
		
		public function updateWeight():void
		{
			var sumOfShit:Number = 0;
			for (var i:int = 0; i < NeuralNetwork.TRAINING_STEP_SIZE; i++)
			{
				sumOfShit += outNeuron.deltaErrors[i] * inNeuron.storedAmounts[i];
			}
			
			weight -= (NeuralNetwork.LEARNING_RATE / NeuralNetwork.TRAINING_STEP_SIZE) * sumOfShit;
		}
	}

}