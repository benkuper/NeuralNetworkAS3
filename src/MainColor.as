package 
{
	import ui.fonts.Fonts;
	import benkuper.util.Shortcutter;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import neural.NeuralNetwork;
	import utils.color.getColor;
	import utils.color.lerpColor;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class MainColor extends Sprite 
	{
		private var network:NeuralNetwork;
		private var numInputs:int;
		
		private var trainingInputValues:Vector.<Vector.<Number>>;
		private var expectedValues:Vector.<Vector.<Number>>;
		
		private var trainingContainer:Sprite;
		private var checkContainer:Sprite;
		
		private var ti:int = 0;
		private var training:Boolean;
		
		public function MainColor():void 
		{
			Fonts.init();
			Shortcutter.init(stage);
			
			numInputs = 4;
			
			
			
			network = new NeuralNetwork([numInputs, 8,8,3]);
			addChild(network);
			
			trainingContainer = new Sprite();
			addChild(trainingContainer);
			
			checkContainer = new Sprite();
			addChild(checkContainer);
			checkContainer.y = 200;
			
			Shortcutter.add(network);
			Shortcutter.add(NeuralNetwork);
			Shortcutter.add(this);
			
			generateTrainingValues();
			drawTrainingValues(false);
			
			network.setTrainingValues(trainingInputValues, expectedValues);
			//addEventListener(Event.ENTER_FRAME, enterFrame);		
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		private function keyDown(e:KeyboardEvent):void 
		{
			switch(e.keyCode)
			{
				case Keyboard.SPACE:
					toggle();
					break;
					
				case Keyboard.NUMPAD_ADD:
					NeuralNetwork.LEARNING_RATE+= .03;
					break;
					
				case Keyboard.NUMPAD_SUBTRACT:
					NeuralNetwork.LEARNING_RATE -= .03;
					break;
					
				case Keyboard.NUMPAD_MULTIPLY:
					NeuralNetwork.LEARNING_RATE *= 2;
					break;
					
				case Keyboard.NUMPAD_DIVIDE:
					NeuralNetwork.LEARNING_RATE /= 2;
					break;
					
					
				case Keyboard.R: cIndex = 0; break;
				case Keyboard.G: cIndex = 1; break;
				case Keyboard.B: cIndex = 2; break;
				case Keyboard.I: cFactor = -cFactor; break;
			}
		}
		
		
		private function mouseHandler(e:MouseEvent):void 
		{
			switch(e.type)
			{
				case MouseEvent.MOUSE_DOWN:
					addEventListener(Event.ENTER_FRAME, mouseEnterFrame);
					stage.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);
					break;
					
				case MouseEvent.MOUSE_UP:
					removeEventListener(Event.ENTER_FRAME, mouseEnterFrame);
					stage.removeEventListener(MouseEvent.MOUSE_UP, mouseHandler);
					break;
					
				
			}
		}
		
		private var cIndex:int = 0;
		private var cFactor:Number = 1;
		
		private function mouseEnterFrame(e:Event):void 
		{
			var mp:Point = new Point((mouseX - 100) / 100, (mouseY - 100) / 100);
			//
			//var n:Number = getPointValue(p);
			//var values:Vector.<Number> = new Vector.<Number>();
			//values.push(p.x, p.y);
			//var outValues:Vector.<Number> = network.run(values);
			//trace("real = " + n + ", network result = " + outValues[0]);
			
			for (var i:int = 0; i < trainingInputValues.length; i++)
			{
				var p:Point = new Point(trainingInputValues[i][0], trainingInputValues[i][1]);
				var d:Number = Point.distance(p, mp);
				if (d < .05) 
				{
					expectedValues[i][cIndex] = Math.min(Math.max(expectedValues[i][cIndex]+.2*cFactor,0),1);
				}
				
			}
			drawTrainingValues(false);
		}
		
		public function generateTrainingValues():void
		{
			var numTrainingValues:int = 5000;
			
			trainingInputValues = new Vector.<Vector.<Number>>();
			expectedValues = new Vector.<Vector.<Number>>();
			
			for (var i:int = 0; i < numTrainingValues; i++)
			{
				trainingInputValues.push(new Vector.<Number>());
				var p:Point = new Point((Math.random() - .5) * 2, (Math.random() - .5) * 2);
				
				trainingInputValues[i].push(p.x, p.y, -p.x, -p.y);// , p.x, p.y, -p.x, -p.y);
				
				expectedValues.push(new Vector.<Number>());
				//var result:Number = 0;// getPointValue(p);
				expectedValues[i].push(0,0,0);
			}
		}
		
		private function getPointValue(p:Point):Number
		{
			//return p.x > 0?1:0;
			
			//return (p.x > 0 && p.y < 0)?1:0;
			//return (p.x < .5 && p.y < .5 && p.x > -.5 && p.y > -.5)?1:0;
			//return ((p.x+1)%.7 < .3)?1:0;
			//var d:Number = Point.distance(new Point(), p);
			//return Math.min(Math.sin(d*10)*.5+.5,1);
			return ((p.x+1)%1);
		}
		
		
		//[Shortcut (key = 'j')]
		public function dnew():void
		{
			drawTrainingValues(true, true);
		}
		
		//[Shortcut (key = ' ')]
		public function toggle():void
		{
			training = !training;
			if (training)
			{
				addEventListener(Event.ENTER_FRAME, trainEnterFrame);
				
			}else
			{
				removeEventListener(Event.ENTER_FRAME, trainEnterFrame);
			}
		}
		
		private function trainEnterFrame(e:Event):void 
		{
			network.trainMultiStep();
			drawTrainingValues();
			network.draw();
		}
		
		public function drawTrainingValues(checkRun:Boolean = true,newPoints:Boolean = false):void
		{
			//if (checkRun && (++ti % 1000 != 0)) return;
			
			if (!checkRun)
			{
			trainingContainer.graphics.clear();
			trainingContainer.graphics.beginFill(0x171717);
			trainingContainer.graphics.drawRect(0, 0, 200, 200);
			trainingContainer.graphics.endFill();
			}else
			{
			
			checkContainer.graphics.clear();
			checkContainer.graphics.beginFill(0x171717);
			checkContainer.graphics.drawRect(0, 0, 200, 200);
			checkContainer.graphics.endFill();
			}
			
			var numTest:int = trainingInputValues.length;
			for (var i:int = 0; i < numTest; i++)
			{
				
				if (checkRun)
				{
					var outValues:Vector.<Number>;
					
					
					
					if (newPoints)
					{
						
						var p:Point = new Point((Math.random() - .5) * 2, (Math.random() - .5) * 2);
						var ins:Vector.<Number> = new Vector.<Number>();
						ins.push(p.x, p.y, -p.x, -p.y);// , p.x, p.y, -p.x, -p.y);
						outValues = network.run(ins);
						checkContainer.graphics.beginFill(getColor(outValues[0]*255, outValues[1]*255, outValues[2]*255));// lerpColor(0xF05513, 0x87E320, outValues[0]));
						checkContainer.graphics.drawRect(100+p.x * 100, 100+p.y * 100,1,1);
						checkContainer.graphics.endFill();
					}else
					{
						outValues = network.run(trainingInputValues[i]);
						checkContainer.graphics.beginFill(getColor(outValues[0]*255, outValues[1]*255, outValues[2]*255));
						checkContainer.graphics.drawRect(100+trainingInputValues[i][0] * 100, 100+trainingInputValues[i][1] * 100,2,2);
					
						checkContainer.graphics.endFill();
					}
					
					
				}else
				{
					trainingContainer.graphics.beginFill(getColor(expectedValues[i][0]*255, expectedValues[i][1]*255, expectedValues[i][2]*255));
					trainingContainer.graphics.drawRect(100+trainingInputValues[i][0] * 100, 100+trainingInputValues[i][1] * 100,2,2);
					trainingContainer.graphics.endFill();
					
				}
				
				
			}
			
			
			//network.draw();
		}
		
		private function enterFrame(e:Event):void 
		{
			//var inValues:Vector.<Number> = new Vector.<Number>();
			//for (var i:int = 0; i < numInputs; i++) inValues.push((Math.random()-.5)*2);
			//var outValues:Vector.<Number> = new Vector.<Number>();
			//outValues.push(.8);
			////network.train(inValues, outValues);
		}
		
	}
	
}