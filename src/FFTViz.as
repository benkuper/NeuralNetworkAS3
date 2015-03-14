package  
{
	import flash.display.Sprite;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class FFTViz extends Sprite 
	{
		
		private var fftContainer:Sprite;
		
		private var vizWidth:Number = 600;
		private var vizHeight:Number = 100;
		
		private var verticalFactor:Number = 1;
		
		public function FFTViz() 
		{
			super();
			fftContainer = new Sprite();
			addChild(fftContainer);
			
			graphics.clear();
			graphics.beginFill(0x3C3C3C);
			graphics.drawRect(0, 0, vizWidth, vizHeight);
			graphics.endFill();
			
		}
		
		public function drawFFT(data:ByteArray):void
		{
			data.position = 0;
			var numSamples:int = data.bytesAvailable / 4; //size of float
			numSamples /= 2 ;//keep only one channel
			trace("draw fft data, num Samples :" + numSamples);
			
			fftContainer.graphics.clear();
			fftContainer.graphics.lineStyle(1, 0xFCA70A);
			fftContainer.graphics.moveTo(0, vizHeight);
			
			for (var i:int = 0; i < numSamples; i++)
			{
				var val:Number = data.readFloat();
				var tx:Number = (i / numSamples) * vizWidth;
				fftContainer.graphics.moveTo(tx, vizHeight);
				fftContainer.graphics.lineTo(tx, vizHeight-val * verticalFactor);
			}
		}
		
	}

}