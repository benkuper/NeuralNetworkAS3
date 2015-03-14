package neural 
{
	import ui.fonts.Fonts;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class NeuralNetwork extends Sprite
	{
		public var neuronsInLayer:Array; // amount of neurons in each layer, numLayer is this array's length
		public var numLayers:int;
		
		public var layers:Vector.<NeuronLayer>;
		
		public var layerContainer:Sprite;
		public var connectionContainer:Sprite;
		
		static public const SIGMA_FACTOR:Number = 1;
		static public const BIAS_RANDOM_FACTOR:Number = 1;
		static public const WEIGHT_RANDOM_FACTOR:Number = 3;
		static public const TRAINING_STEP_SIZE:int = 1;
		static private var _LEARNING_RATE:Number = 1;
		
		
		//for training
		private var currentStep:int;
		private var randomIndices:Array;
		private var trainingExpectedOutputs:Vector.<Vector.<Number>>;
		private var trainingInputValues:Vector.<Vector.<Number>>;
		private var _training:Boolean;

		
		private var tf:TextField;
		
		public function NeuralNetwork(neuronMap:Array) 
		{
			tf = Fonts.createTF("info", Fonts.normalTF);
			addChild(tf);
			
			neuronsInLayer = neuronMap;
			numLayers = neuronsInLayer.length;
			
			connectionContainer = new Sprite();
			addChild(connectionContainer);
			
			layers = new Vector.<NeuronLayer>();
			layerContainer = new Sprite();
			addChild(layerContainer);
			for (var i:int = 0; i < numLayers; i++) 
			{
				var nl:NeuronLayer = new NeuronLayer(neuronsInLayer[i],i == 0,i == numLayers-1);
				layers.push(nl);
				layerContainer.addChild(nl);
			}
			
			createConnections();
			
			for each(var c:NeuralConnection in NeuralConnection.instances)
			{
				connectionContainer.addChild(c);
			}
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			draw();
		}
		
		
		
		
		//UI
		
		public function draw():void 
		{
			//draw layers with neurons
			var margin:Number = 100;
			for (var i:int = 0; i < numLayers; i++)
			{
				layers[i].x = margin/2 + (i / (numLayers-1)) * (stage.stageWidth - margin*2);
				layers[i].y = stage.stageHeight / 2;
				layers[i].draw();
			}
			
			//draw connections
			for each(var c:NeuralConnection in NeuralConnection.instances) c.draw();
			
			updateTF();
		}
		
		private function updateTF():void
		{
			tf.text = "Current step :" + currentStep + "\nTrained :" + currentStep * TRAINING_STEP_SIZE+"\n learning rate :"+LEARNING_RATE;
			tf.x = stage.stageWidth - tf.textWidth - 10;
			tf.y = 5;
		}
		
		private function createConnections():void 
		{
			for (var i:int = 0; i < numLayers-1; i++)
			{
				layers[i].createConnectionsWith(layers[i + 1]);
			}
		}
		
		
		// RUNNING
		
		public function run(inValues:Vector.<Number>):Vector.<Number>
		{
			var l:NeuronLayer;
			
			//RESET NEURON AMOUNTS
			for each(l in layers) l.resetAmount();
			
			
			//FORWARD PROPAGATION PHASE			
			for (var i:int = 0; i < inValues.length; i++)
			{
				layers[0].neurons[i].addAmount(inValues[i]);
			}
			
			for each(l in layers) l.process();
			
			var result:Vector.<Number> = new Vector.<Number>;
			for each(var n:Neuron in layers[layers.length - 1].neurons) result.push(n.amountToSend);
			
			
			return result;
		}
		
		
		// TRAINING
		
		public function setTrainingValues(trainingInputValues:Vector.<Vector.<Number>>, trainingExpectedOutputs:Vector.<Vector.<Number>>):void
		{
			this.trainingInputValues = trainingInputValues;
			this.trainingExpectedOutputs = trainingExpectedOutputs;
			
			randomIndices = new Array();
			var numValuesTotal:int = trainingInputValues.length;
			
			for (var i:int = 0; i < numValuesTotal; i++) randomIndices.push(i);
			
		}
		
		private function trainingEnterFrame(e:Event):void 
		{
			trainMultiStep();
		}
		
		public function trainMultiStep():void
		{
			for (var i:int = 0; i < 1000; i++) trainStep();
			//draw();
			//updateTF();
		}
		
		
		public function trainStep():void
		{
			var i:int;
			
			//RESET ALL NEURONS STORED ERRORS AND AMOUNTS
			resetAllNeurons();
			
			var stepOffset:int = currentStep * TRAINING_STEP_SIZE;
			
			var totalValues:int = trainingInputValues.length;
			
			
			//RUN STEPS
			for (i = 0; i < TRAINING_STEP_SIZE; i++)
			{				
				var index:int = randomIndices[(currentStep+i)%randomIndices.length];
				trainOnce(trainingInputValues[index], trainingExpectedOutputs[index],false);
			}
			
			//UPDATE BIAS (GRADIENT DESCENT)
			for(i = 1; i < layers.length;i++ ) layers[i].updateBias();
			
			//UPDATE WEIGHT IN CONNECTIONS
			for each(var c:NeuralConnection in NeuralConnection.instances) c.updateWeight();
			
			var numSteps:int =  totalValues / TRAINING_STEP_SIZE;
			if (currentStep %  numSteps == 0) {
				randomIndices.sort(randomSort);
			}
			
			currentStep++;
		}
		
		
		public function trainOnce(inValues:Vector.<Number>,expectedOutputs:Vector.<Number>,doDraw:Boolean = false):void
		{
			var l:NeuronLayer;
			var i:int;
			if (inValues.length != layers[0].neurons.length) 
			{
				trace("First layer has different num of neurons than training values");
				return;
			}
			
			if (expectedOutputs.length != layers[numLayers - 1].neurons.length)
			{
				trace("Last layer has different num of neurons than expected values");
				return;
			}
			
			
			//RUN (PROPAGATION)
			run(inValues);
			
			//SET FINAL NEURONS EXPECTED AMOUNT
			for (i = 0; i < layers[layers.length - 1].neurons.length; i++)
			{
				layers[layers.length - 1].neurons[i].expectedAmount = expectedOutputs[i];
			}
			
			
			//BACKWARD "BACKPROPAGATION" ERROR CALCULATION PHASE
			for (i = layers.length - 1; i >= 0; i--)
			{
				layers[i].processBackward();
			}
			
			
			
			//final draw
			if(doDraw) draw();
		}
		
		
		//Reset
		public function resetAllNeurons():void 
		{
			for each(var l:NeuronLayer in layers) l.resetAll();
		}
		
		
		
		//Util
		
		private function randomSort(a:*, b:*):Number    //* means any kind of input
		{
			if (Math.random() < 0.5) return -1;
			else return 1;
		}
		
		
		
		
		//Getter / Setter
		
		static public function get LEARNING_RATE():Number 
		{
			return _LEARNING_RATE;
		}
		
		
		[Shortcut(key = '+', type = 'add', value =.05)]
		[Shortcut(key = '-', type = 'subtract', value =.05)]
		static public function set LEARNING_RATE(value:Number):void 
		{
			_LEARNING_RATE = value;
		}
		
		
		public function get training():Boolean
		{
			return _training;
		}
		
		public function set training(value:Boolean):void 
		{
			if (value == training) return;
			_training = value;
			if (value)
			{
				addEventListener(Event.ENTER_FRAME, trainingEnterFrame);
			}else
			{
				removeEventListener(Event.ENTER_FRAME, trainingEnterFrame);
			}
		}
		
		
		
	}

}