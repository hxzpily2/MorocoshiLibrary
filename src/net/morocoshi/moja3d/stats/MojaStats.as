package net.morocoshi.moja3d.stats 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	import net.morocoshi.common.optimization.frameskip.FrameSkipper;
	import net.morocoshi.moja3d.filters.Filter3D;
	import net.morocoshi.moja3d.renderer.RenderCollector;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	import net.morocoshi.moja3d.view.DriverInfo;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class MojaStats extends Sprite 
	{
		private var textList:Vector.<TextField>;
		private var labelList:Array;
		private var valueList:Array;
		
		private var modeText:TextField;
		private var defaultFormat:TextFormat;
		
		private var textContainer:Sprite;
		private var checkContainer:Sprite;
		private var baseLayer:Sprite;
		private var checkLayer:Sprite;
		private var fpsInterval:int;
		private var prevTime:int;
		private var currentFps:int;
		private var maxFps:int;
		private var count:int;
		private var _isSoftware:Boolean;
		private var ty:Number = 2;
		private var cy:Number = 2;
		
		[Embed(source = "Inconsolata.otf", fontName="Inconsolata", embedAsCFF="false")] private var Font:Class;
		//[Embed(source = "DroidSansMono.ttf", fontName="DroidSansMono", embedAsCFF="false")]
		
		
		public function MojaStats() 
		{
			super();
			defaultFormat = new TextFormat("Inconsolata", 14, 0xffffff, true);
			
			count = 0;
			maxFps = 0;
			currentFps = 0;
			fpsInterval = 1000;
			
			baseLayer = createBaseLayer(90, 142, 0x0, 0.8);
			checkLayer = createBaseLayer(90, 10, 0xffffff, 0.8);
			checkLayer.y = baseLayer.height;
			textContainer = new Sprite();
			textContainer.x = 5;
			textContainer.y = 5;
			checkContainer = new Sprite();
			checkContainer.x = 5;
			checkContainer.y = checkLayer.y + 5;
			
			modeText = createTextField();
			labelList = ["FPS", "DRW", "TRI", "MOV", "APH", "COL", "MEM"];
			textList = new Vector.<TextField>;
			valueList = [];
			for (var i:int = 0; i < labelList.length; i++) 
			{
				textList.push(createTextField());
				valueList.push("");
			}
			
			addChild(baseLayer);
			addChild(checkLayer);
			addChild(textContainer);
			addChild(checkContainer);
			
			prevTime = getTimer();
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		public function addLabelCheck(label:String, switchHandler:Function, selected:Boolean = true):StatsCheckBox
		{
			var check:StatsCheckBox = new StatsCheckBox(label, true);
			check.addEventListener(Event.SELECT, function(e:Event):void
			{
				switchHandler(check.selected);
			});
			addCheckBox(check);
			check.selected = selected;
			return check;
		}
		
		public function addFrameSkipCheck(fs:FrameSkipper):StatsCheckBox
		{
			var check:StatsCheckBox = new StatsCheckBox("Frame Skip", true);
			check.addEventListener(Event.SELECT, function(e:Event):void
			{
				fs.enabled = check.selected;
			});
			addCheckBox(check);
			return check;
		}
		
		public function addShaderCheck(shader:MaterialShader, label:String, selected:Boolean = true):StatsCheckBox
		{
			var check:StatsCheckBox = new StatsCheckBox(label, true);
			check.addEventListener(Event.SELECT, function(e:Event):void
			{
				shader.enabled = check.selected;
			});
			addCheckBox(check);
			check.selected = selected;
			return check;
		}
		
		public function addShaderListCheck(shaders:*, label:String, selected:Boolean = true):StatsCheckBox 
		{
			var check:StatsCheckBox = new StatsCheckBox(label, true);
			check.addEventListener(Event.SELECT, function(e:Event):void
			{
				var n:int = shaders.length;
				for (var i:int = 0; i < n; i++)
				{
					var shader:MaterialShader = shaders[i];
					shader.enabled = check.selected;
				}
			});
			addCheckBox(check);
			check.selected = selected;
			return check;
		}
		
		public function addFilterCheck(filter:Filter3D, label:String, selected:Boolean = true):StatsCheckBox
		{
			var check:StatsCheckBox = new StatsCheckBox(label, true);
			check.addEventListener(Event.SELECT, function(e:Event):void
			{
				filter.enabled = check.selected;
			});
			addCheckBox(check);
			check.selected = selected;
			return check;
		}
		
		private function addCheckBox(check:StatsCheckBox):void 
		{
			checkContainer.addChild(check);
			check.y = cy;
			cy += 18;
			checkLayer.height = cy + 6;
			checkLayer.visible = true;
		}
		
		public function setDriverInfo(info:DriverInfo):void
		{
			_isSoftware = info.isSoftware;
			modeText.text = _isSoftware? "SOFTWARE" : "HARDWARE";
			modeText.textColor = info.isSoftware? 0xff8000 : 0x6CC4FF;
		}
		
		private function addedToStageHandler(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			maxFps = int(stage.frameRate);
		}
		
		private function enterFrameHandler(e:Event):void 
		{
			count++;
			var currentTime:int = getTimer();
			if (currentTime - prevTime < fpsInterval) return;
			
			var diff:int = currentTime - prevTime;
			currentFps = 1000 / (diff / count);
			prevTime = currentTime;
			count = 0;
		}
		
		private function createBaseLayer(width:Number, height:Number, rgb:uint, alpha:Number):Sprite 
		{
			var result:Sprite = new Sprite();
			result.graphics.beginFill(rgb, alpha);
			result.graphics.drawRect(0, 0, width, height);
			result.graphics.endFill();
			return result;
		}
		
		public function apply(collector:RenderCollector):void
		{
			valueList[0] = currentFps + "/" + maxFps;
			valueList[1] = collector.drawCount;
			valueList[2] = collector.polygonCount;
			valueList[3] = collector.moveCount;
			valueList[4] = collector.alphaCount;
			valueList[5] = collector.colorCount;
			valueList[6] = (System.totalMemory / 1024 / 1024).toFixed(1);
			
			for (var i:int = 0; i < textList.length; i++) 
			{
				textList[i].text = labelList[i] + ":" + valueList[i];
			}
		}
		
		private function createTextField():TextField 
		{
			var result:TextField = new TextField();
			result.autoSize = TextFieldAutoSize.LEFT;
			result.selectable = false;
			result.defaultTextFormat = defaultFormat;
			result.embedFonts = true;
			result.y = ty;
			textContainer.addChild(result);
			ty += 16;
			return result;
		}
		
		
		public function get isSoftware():Boolean 
		{
			return _isSoftware;
		}
		
	}

}