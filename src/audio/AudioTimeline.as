package audio 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.SampleDataEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * ...
	 * @author Ben Kuper
	 */
	public class AudioTimeline extends Sprite 
	{
		
		private var audioFile:File;
		private var sound:Sound;
		private var channel:SoundChannel;
		private var _playing:Boolean;
		
		//ui
		private var timeline:Sprite;
		private var waveContainer:Sprite;
		private var waveBitmap:Bitmap;
		private var animationContainer:Sprite;
		private var cursor:Sprite;
		private var valCheck:Sprite;
		
		
		//layout
		private var timelineWidth:Number = 1180;
		private var timelineHeight:Number = 200;
		
		
		//timeline
		private var _curTime:Number;
		
		//curves
		private var curveContainer:Sprite;
		public var expectedCurve:AnimationCurve;
		public var learnedCurve:AnimationCurve;
		
		
		//data
		public var soundBytes:ByteArray;
		
		public function AudioTimeline() 
		{
			super();
			audioFile = File.desktopDirectory.resolvePath("");
			
			timeline = new Sprite();
			addChild(timeline);
			
			waveContainer = new Sprite();
			//timeline.addChild(waveContainer);
			waveBitmap = new Bitmap(new BitmapData(timelineWidth,timelineHeight,true,0));
			timeline.addChild(waveBitmap);
			
			animationContainer = new Sprite();
			timeline.addChild(animationContainer);
			
			curveContainer = new Sprite();
			timeline.addChild(curveContainer);
			
			expectedCurve = new AnimationCurve(0x81BF0D,timelineWidth,timelineHeight);
			curveContainer.addChild(expectedCurve);
			
			learnedCurve = new AnimationCurve(0xFDAF1E, timelineWidth, timelineHeight);
			curveContainer.addChild(learnedCurve);
			
			cursor = new Sprite();
			timeline.addChild(cursor);
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseHandler);
			
			
			valCheck = new Sprite();
			timeline.addChild(valCheck);
			valCheck.graphics.clear();
			valCheck.graphics.lineStyle(1, 0xE2FF1C);
			valCheck.graphics.drawCircle(0, 0, 5);
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function soundEnterFrame(e:Event):void 
		{
			curTime = channel.position / sound.length;
		}
		
		private function mouseHandler(e:MouseEvent):void 
		{
			switch(e.type)
			{
				case MouseEvent.MOUSE_DOWN:
					if (e.ctrlKey)
					{
						expectedCurve.addPoint(Math.min(Math.max(timeline.mouseX / timelineWidth,0),1), Math.min(Math.max(1-(timeline.mouseY/timelineHeight),0),1));
					}else
					{
						stage.addEventListener(MouseEvent.MOUSE_UP, mouseHandler);
						stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
					}
					break;
					
				case MouseEvent.MOUSE_UP:
					stage.removeEventListener(MouseEvent.MOUSE_UP, mouseHandler);
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
					break;
					
			}
		}
		
		private function mouseMove(e:MouseEvent):void 
		{
			curTime = timeline.mouseX / timelineWidth;
		}
		
		private function addedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			drawBGAndCursor();
		}
		
		private function drawBGAndCursor():void 
		{
			timeline.graphics.clear();
			timeline.graphics.beginFill(0x3C3C3C);
			timeline.graphics.drawRect(0, 0, timelineWidth, timelineHeight);
			timeline.graphics.endFill();
			
			cursor.graphics.clear();
			cursor.graphics.lineStyle(2, 0xFF8C24, .5);
			cursor.graphics.moveTo(0, 0);
			cursor.graphics.lineTo(0, timelineHeight);
		}
		
		
		public function openFile():void
		{
			audioFile.browseForOpen("MP3", [new FileFilter("mp3", "*.mp3")]);
			if(!(audioFile.hasEventListener(Event.SELECT))) audioFile.addEventListener(Event.SELECT, fileOpen);
			
		}
		
		public function loadFile(file:File):void
		{
			audioFile = file;
			processFile(file);
		}
		
		public function play():void 
		{
			channel = sound.play();
			channel.addEventListener(Event.SOUND_COMPLETE, soundComplete);
			_playing = true;
			addEventListener(Event.ENTER_FRAME, soundEnterFrame);
		}
		
		private function soundComplete(e:Event):void 
		{
			stop();
		}
		
		public function stop():void
		{
			channel.stop();
			channel.removeEventListener(Event.SOUND_COMPLETE, soundComplete);
			channel = null;
			_playing = false;
			removeEventListener(Event.ENTER_FRAME, soundEnterFrame);
		}
		
		
		private function fileOpen(e:Event):void 
		{
			trace("file open", audioFile.name);
			processFile(audioFile);
		}
		
		private function processFile(file:File):void
		{
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			var bytes:ByteArray  = new ByteArray();
			fs.readBytes(bytes);
			fs.close();
			
			bytes.position = 0;
			sound = new Sound();
			sound.loadCompressedDataFromByteArray(bytes, bytes.bytesAvailable);
			
			soundBytes = new ByteArray();
			soundBytes.endian = Endian.LITTLE_ENDIAN;
			
			waveBitmap.bitmapData = new BitmapData(timelineWidth, timelineHeight, true, 0);
			
			addEventListener(Event.ENTER_FRAME, processEnterFrame);			
		}
		
		private function processEnterFrame(e:Event):void 
		{
			var soundBytesPos:int = soundBytes.position;
			soundBytes.position = soundBytes.length;
			
			var samplesToExtract:int = 4096;
			var samplesExtracted:int = sound.extract(soundBytes, samplesToExtract);
			
			
			soundBytes.position = soundBytesPos;
			trace("extract", samplesToExtract, samplesExtracted, soundBytes.length);
			drawWaveform();
			
			if (samplesExtracted == 0)
			{
				processFinished();
			}
			
		}
		
		private function processFinished():void
		{
			removeEventListener(Event.ENTER_FRAME, processEnterFrame);
			dispatchEvent(new TimelineEvent(TimelineEvent.SOUND_PROCESSED));
		}
		
		private function drawWaveform():void 
		{
			var i:int;
			waveContainer.graphics.clear();
			waveContainer.graphics.lineStyle(1, 0x8D8D8D);
			
			var estimatedTotalBytes:int = sound.length * 4 * 2 * 44.1; //two float (size 4) * 44.1 khz
			
			var steps:int = 4; //size of float
			var totalIterations:int = estimatedTotalBytes/ steps;
			var startIteration:int = (soundBytes.position / estimatedTotalBytes) * totalIterations;
			
			trace("draw waveform from : " + startIteration, totalIterations,soundBytes.bytesAvailable);
			
			for (i = startIteration; soundBytes.bytesAvailable >= 4; i++)
			{
				var tx:Number = (i / totalIterations) * timelineWidth;
				var amp:Number = soundBytes.readFloat();
				waveContainer.graphics.moveTo(tx, timelineHeight/2);
				waveContainer.graphics.lineTo(tx, (amp/2+.5)*timelineHeight);
			}
			
			waveBitmap.bitmapData.lock();
			waveBitmap.bitmapData.draw(waveContainer);
			waveBitmap.bitmapData.unlock();
			waveContainer.graphics.clear();
		}
		
		public function get curTime():Number 
		{
			return _curTime;
		}
		
		public function set curTime(value:Number):void 
		{
			_curTime = Math.min(Math.max(value, 0), 1);
			cursor.x = curTime * timelineWidth;
			valCheck.x = cursor.x;
			valCheck.y = (1-expectedCurve.getValueAt(curTime))*timelineHeight;
			dispatchEvent(new TimelineEvent(TimelineEvent.TIME_CHANGED));
		}
		
		public function get playing():Boolean 
		{
			return _playing;
		}
		
	}

}