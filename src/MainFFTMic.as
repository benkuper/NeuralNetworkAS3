package  
{
	import audio.AudioTimeline;
	import audio.TimelineEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filesystem.File;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import neural.NeuralNetwork;
	import ru.inspirit.analysis.FFT;
	import ru.inspirit.analysis.FFTSpectrumAnalyzer;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class MainFFT extends Sprite 
	{
		private var at:AudioTimeline;
		
		private var fft:FFT;
		private var sa:FFTSpectrumAnalyzer;
		private var viz:FFTViz;
		
		//for neural
		private var fftResults:Vector.<ByteArray>;
		private var fftVectors:Vector.<Vector.<Number>>;
		
		private var expectedData:Vector.<Vector.<Number>>;
		private var neuralOutData:Vector.<Vector.<Number>>;
		
		//private var network:NeuralNetwork;
		
		//parameters
		static public const FFT_SAMPLES_LENGTH:int = 30000;
		
		public function MainFFTMic() 
		{
			super();
			
			at = new AudioTimeline();
			
			
			at.addEventListener(TimelineEvent.TIME_CHANGED, timeChanged);
			at.addEventListener(TimelineEvent.SOUND_PROCESSED, soundProcessed);
			fft = new FFT();
			fft.init(FFT_SAMPLES_LENGTH, 2);
			
			sa = new FFTSpectrumAnalyzer(fft);
			
			viz = new FFTViz();
			viz.x = 10;
			viz.y = 300;
			
			
			// lets init Logarithmic Average mode to get more visually correct spectrum
			// you should provide min bandwidth to include and number of bands
			// you want to divide each octave to
			sa.initLogarithmicAverages(50,10);
			//sa.initLinearAverages(100);
			
			var numNeuralInputs:int = sa.numberOfAverageBands;
			var numOutputs:int = 1; //get only amplitude
			
			//network = new NeuralNetwork([numNeuralInputs, 8, 8, numOutputs]);
			//addChild(network);
			
			addChild(at);
			addChild(viz);
			
			at.x = 10;
			at.y = stage.stageHeight-at.height-10;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}
		
		private function soundProcessed(e:TimelineEvent):void 
		{
			generateFFT();
			at.curTime = 0;
			
			generateExpectedData();
		}
		
		private function generateExpectedData():void 
		{
			expectedData = new Vector.<Vector.<Number>>(fftVectors.length);
			for (var i:int = 0; i < fftVectors.length; i++)
			{
				expectedData[i] = new Vector.<Number>(1);
				expectedData[i][0] = getExpectedResult(fftVectors[i]);
			}
			
			at.expectedCurve.setDataLinear(expectedData);
			
			//trace("set training values");
			//network.setTrainingValues(fftVectors, expectedData);
		}
		
		private function fillExpectedDataFromCurve():void
		{
			var numSteps:int = fftVectors.length;
			expectedData = new Vector.<Vector.<Number>>(numSteps);
			for (var i:int = 0; i < numSteps; i++)
			{
				expectedData[i] = new Vector.<Number>(1);
				expectedData[i][0] = at.expectedCurve.getValueAt(i / numSteps);
			}
			
			at.expectedCurve.setDataLinear(expectedData);
			//network.setTrainingValues(fftVectors, expectedData);
		}
		
		private function getExpectedResult(data:Vector.<Number>):Number
		{
			var sum:Number = 0;
			var max:Number = 0;
			var index:int = 0;
			
			for (var i:int = 0; i < data.length;i++ )
			{
				sum += data[i];
				if (data[i] > max) 
				{
					max = data[i];
					index = i;
				}
			}
			var freq:Number = index;// sa.getBand(index);
			//r /= data.length*10;// * max;
			return (index * sum) / (800*data.length) + max / 500;// index / data.length;//100;// max / 10;//Math.min(Math.max(r, 0), 1);
		}
		
		private function timeChanged(e:TimelineEvent):void 
		{
			if (at.curTime >= 1) return;
			if (fftResults == null) return;
			var index:int = int(at.curTime * fftResults.length);
			viz.drawFFT(fftResults[index]);
		}
		
		private function keyDown(e:KeyboardEvent):void 
		{
			switch(e.keyCode)
			{
				case Keyboard.L:
					at.loadFile(File.desktopDirectory.resolvePath("NeuralLoop1.mp3"));
					break;
					
				case Keyboard.O:
					at.openFile();
					
					break;
					
				case Keyboard.P:
					if (at.playing) at.stop();
					else at.play();
					break;
					
				case Keyboard.F:
					fillExpectedDataFromCurve();
					break;
					
					
				case Keyboard.R:
					at.expectedCurve.reset();
					break;
					
				case Keyboard.SPACE:
					network.training = !network.training;
					if (network.training)
					{
						addEventListener(Event.ENTER_FRAME, drawNeuralValues);
					}else
					{
						removeEventListener(Event.ENTER_FRAME, drawNeuralValues);
					}
					break;
					
				case Keyboard.NUMPAD_DIVIDE:
					NeuralNetwork.LEARNING_RATE /= 2;
					trace(NeuralNetwork.LEARNING_RATE);
					break;
					
				case Keyboard.NUMPAD_MULTIPLY:
					NeuralNetwork.LEARNING_RATE *= 2;
					trace(NeuralNetwork.LEARNING_RATE);
					break;
			}
		}
		
		private function drawNeuralValues(e:Event):void
		{
			
			var outValues:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(fftVectors.length);
			for (var i:int = 0; i < fftVectors.length; i++) outValues[i] = network.run(fftVectors[i]);
			at.learnedCurve.setDataLinear(outValues);
			
			network.draw();
		}
		
		private function generateFFT():void 
		{
			
			
			at.soundBytes.position = 0;
			trace("generate fft, soundBytes length ="+at.soundBytes.bytesAvailable);
			
			var numSamples:int = at.soundBytes.bytesAvailable / FFT_SAMPLES_LENGTH;
			var sourceBytes:Vector.<ByteArray> = new Vector.<ByteArray>(numSamples);
			
			fftResults = new Vector.<ByteArray>(numSamples);
			fftVectors = new Vector.<Vector.<Number>>(numSamples);
			
			for (var i:int = 0; i < numSamples; i++)
			{
				//trace("process sample #" + i);
				var buffer:ByteArray = new ByteArray();
				buffer.endian = Endian.LITTLE_ENDIAN;
				at.soundBytes.readBytes(buffer, 0, FFT_SAMPLES_LENGTH);
				sourceBytes[i] = buffer;
				
				buffer.position = 0;
				fft.setStereoRAWDataByteArray(buffer);
				// perform forward FFT to calculate Real and Imaginary parts
				// after forward we can analyze sound spectrum
				fft.forwardFFT();
				
				var spectr_data:ByteArray = sa.analyzeSpectrum();
				var spectrLength:int = spectr_data.length >> 2;
				
				// now we can draw the result spectrum the way
				// you do it with built in Sound Spectrum
				var fftBA:ByteArray = new ByteArray();
				
				fftVectors[i] = new Vector.<Number>(spectrLength/2); //only one channel
				
				fftBA.endian = Endian.LITTLE_ENDIAN;
				for(var j:int = 0; j < spectrLength; ++j)
				{
					var spectrBand:Number = spectr_data.readFloat();
					fftBA.writeFloat(spectrBand);
					
					if(j < spectrLength/2) fftVectors[i][j] = spectrBand;
				}
				
				fftResults[i] = fftBA;
			}
			
			trace("chunks generated :"+numSamples);
		}
		
	}

}