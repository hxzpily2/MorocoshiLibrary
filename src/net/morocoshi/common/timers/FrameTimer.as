package net.morocoshi.common.timers
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * フレームベースのタイマー
	 * 
	 * @author	tencho
	 */
	public class FrameTimer
	{
		static private var sprite:Sprite = new Sprite();
		static private var timers:Object = { };
		static private var count:int = 0;
		
		static public function clearAll():void
		{
			timers = { };
			stopEnterFrame();
		}
		
		static public function clearGroup(group:String):void
		{
			for (var k:String in timers)
			{
				var td:TimerData = timers[k];
				if (td.group == group)
				{
					clearID(td.id);
				}
			}
		}
		
		static public function clearID(id:int):void
		{
			if (timers["_" + id])
			{
				delete timers["_" + id];
			}
			if (exist == false)
			{
				stopEnterFrame();
			}
		}
		
		static private function stopEnterFrame():void 
		{
			sprite.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		static private function get exist():Boolean
		{
			for (var k:String in timers) return true;
			return false;
		}
		
		/**
		 * 指定フレーム後に関数を実行する
		 * @param	interval	待機フレーム。0ですぐ実行
		 * @param	complete	実行関数
		 * @param	args	関数に渡す引数
		 * @param	group	グループ名を指定しておくとまとめて中断できる
		 * @param	autoClear	同一グループ名のタイマーを破棄してから実行する
		 * @return
		 */
		static public function setTimer(interval:int, complete:Function, args:Array = null, group:String = "", autoClear:Boolean = false):int
		{
			return setLoopTimer(interval, complete, args, 1, group, autoClear);
		}
		
		static public function setLoopTimer(interval:int, complete:Function, args:Array = null, loop:int = 0, group:String = "", autoClear:Boolean = false):int 
		{
			count++;
			
			if (autoClear)
			{
				clearGroup(group);
			}
			
			var td:TimerData = new TimerData();
			td.isVariable = false;
			td.interval = interval;
			td.loop = loop;
			td.id = count;
			td.group = group;
			td.complete = complete;
			td.args = args || [];
			timers["_" + count] = td;
			sprite.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			if (interval <= 0)
			{
				execute(td);
			}
			
			return count;
		}
		
		static public function setVariable(interval:int, target:*, name:String, value:*, group:String = "", autoClear:Boolean = false):int 
		{
			count++;
			
			if (autoClear)
			{
				clearGroup(group);
			}
			
			var td:TimerData = new TimerData();
			td.isVariable = true;
			td.interval = interval;
			td.id = count;
			td.group = group;
			td.value = value;
			td.loop = 1;
			td.name = name;
			td.target = target;
			timers["_" + count] = td;
			sprite.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			
			if (interval <= 0)
			{
				execute(td);
			}
			
			return count;
		}
		
		static private function enterFrameHandler(e:Event = null):void
		{
			for (var k:String in timers)
			{
				var td:TimerData = timers[k];
				if (--td.interval <= 0)
				{
					execute(td);
				}
			}
		}
		
		static private function execute(td:TimerData):void 
		{
			if (td.isVariable)
			{
				td.target[td.name] = td.value;
			}
			else
			{
				td.complete.apply(null, td.args);
			}
			if (td.loop > 0 && --td.loop <= 0)
			{
				clearID(td.id);						
			}
		}
		
	}

}

internal class TimerData
{
	public var interval:int = 0;
	public var complete:Function;
	public var args:Array;
	public var id:int = 0;
	public var group:String = "";
	
	public var isVariable:Boolean = false;
	public var value:*;
	public var target:*;
	public var name:String;
	public var loop:int = 0;
	
	public function TimerData()
	{
	}
	
}