package neural 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class NeuronLayer extends Sprite 
	{
		private var numNeurons:int;
		public var neurons:Vector.<Neuron>;
		
		public function NeuronLayer(numNeurons:int, isFirst:Boolean, isFinal:Boolean) 
		{
			super();
			this.numNeurons = numNeurons;
			neurons = new Vector.<Neuron>();
			for (var i:int = 0; i < numNeurons; i++) 
			{
				var n:Neuron = new Neuron(isFirst,isFinal);
				neurons.push(n);
				addChild(n);
			}
		}
		
		public function createConnectionsWith(layer:NeuronLayer):void
		{
			for each(var n:Neuron in neurons)
			{
				for each(var n2:Neuron in layer.neurons)
				{
					n.createConnectionWith(n2);
				}
			}
		}
		
		public function draw():void 
		{
			var gap:Number = (stage.stageHeight-100) / neurons.length;
			
			for (var i:int = 0; i < neurons.length; i++) 
			{
				neurons[i].y = (i - neurons.length / 2 + .5) * gap;
				neurons[i].draw();
			}
		}
		
		public function process():void 
		{
			for each(var n:Neuron in neurons) n.process();
		}
		
		public function processBackward():void 
		{
			for each(var n:Neuron in neurons) n.processBackward();
		}
		
		public function resetAmount():void
		{
			for each(var n:Neuron in neurons) n.resetAmount();
		}
		
		public function resetAll():void
		{
			for each(var n:Neuron in neurons) n.resetAll();
		}
		
		public function updateBias():void 
		{
			for each(var n:Neuron in neurons) n.updateBias();
		}
		
	}

}