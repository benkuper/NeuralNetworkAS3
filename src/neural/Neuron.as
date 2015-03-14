package neural 
{
	import ui.fonts.Fonts;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class Neuron extends Sprite 
	{
		private var isFinal:Boolean;
		public var outConnections:Vector.<NeuralConnection>;
		public var inConnections:Vector.<NeuralConnection>;
		
		
		public var currentAmount:Number;
		private var amountWithBias:Number;
		private var isFirst:Boolean;
		
		public var amountToSend:Number;
		public var storedAmounts:Vector.<Number>;
		
		public var expectedAmount:Number;//only for final neurons
		
		
		public var bias:Number; //Used instead of triggering, smooth value sending
		
		public var deltaErrors:Vector.<Number>;
		
		public var tf:TextField;
		
		public function Neuron(isFirst:Boolean, isFinal:Boolean) 
		{
			super();
			this.isFirst = isFirst;
			this.isFinal = isFinal;
			
			bias = (isFirst || isFinal)?0:((Math.random() - .5) * 2)*NeuralNetwork.BIAS_RANDOM_FACTOR;
			
			resetAll();
			deltaErrors = new Vector.<Number>;
			
			//tf = Fonts.createTF("info", Fonts.normal);
			//addChild(tf);
			//tf.y = 20;
			
			
			outConnections = new Vector.<NeuralConnection>();
			inConnections = new Vector.<NeuralConnection>();
		}
		
		public function addAmount(value:Number):void
		{
			currentAmount += value;
		}
		
		public function process():void
		{
			
			//function to handle amount to send
			amountWithBias = currentAmount + bias; //received amount + bias
			
			amountToSend = sigma(amountWithBias)*NeuralNetwork.SIGMA_FACTOR;
			
			for each(var c:NeuralConnection in outConnections)
			{
				c.sendAmount(amountToSend);
			}
			
		}
		
		[Inline]
		private function sigma(z:Number):Number //function to apply to z to get amount to send to next neurons
		{
			return 1 / (1 + Math.exp(-z));
		}
		
		[Inline]
		private function sigmaPrime(z:Number):Number
		{
			return sigma(z) * (1 - sigma(z));
		}
		
		public function resetAmount():void
		{
			amountToSend = 0;
			currentAmount = 0;
			amountWithBias = 0;
		}
		
		public function resetAll():void
		{
			resetAmount();
			deltaErrors = new Vector.<Number>();
			storedAmounts = new Vector.<Number>();
		}
		
		public function createConnectionWith(n2:Neuron):void 
		{
			var c:NeuralConnection = new NeuralConnection(this, n2);
			outConnections.push(c);
			n2.inConnections.push(c);
		}
		
		public function draw():void 
		{			
			var radius:Number = 20;
			graphics.clear();
			graphics.beginFill(0x555555);
			graphics.drawCircle(0, 0, radius);
			graphics.endFill();
		
			graphics.beginFill(amountWithBias<0?0xD04BF1:0xFFD93E,.5);
			graphics.drawCircle(0, 0, Math.abs(amountWithBias) * radius / NeuralNetwork.BIAS_RANDOM_FACTOR);
			graphics.endFill();
			
			graphics.lineStyle(3, 0xFA460A);
			graphics.drawCircle(0, 0, Math.abs(amountToSend) * radius / NeuralNetwork.BIAS_RANDOM_FACTOR);
			
			//tf.text = "received = " + currentAmount.toFixed(2) + "\nz = " + amountWithBias.toFixed(2) + "\nbias=" + bias.toFixed(2) + "\namountToSend=" + amountToSend.toFixed(2);// + "\ndeltaError=" + deltaError;
			//
			//if (!isFirst && deltaErrors.length > 1)
			//{
				//tf.appendText("\nlast deltaError=" + deltaErrors[deltaErrors.length - 1].toFixed(3));
			//}
		}
		
		public function processBackward():void 
		{
			if (isFinal)
			{
				deltaErrors.push((amountToSend - expectedAmount) * sigmaPrime(amountWithBias));
			}else
			{
				
				if (!isFirst)
				{
					var outNeuronsError:Number = 0;
					for each(var c:NeuralConnection in outConnections) outNeuronsError += c.outNeuron.deltaErrors[c.outNeuron.deltaErrors.length-1] * c.weight;
					
					deltaErrors.push(outNeuronsError * sigmaPrime(amountWithBias));
				}
				
				storedAmounts.push(amountToSend);
			}
		}
		
		public function updateBias():void 
		{
			var sumOfErrors:Number = 0;
			for each(var e:Number in deltaErrors) sumOfErrors += e;
			
			bias -= (NeuralNetwork.LEARNING_RATE / NeuralNetwork.TRAINING_STEP_SIZE)*e;
		}
	}

}