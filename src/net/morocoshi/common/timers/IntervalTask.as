package net.morocoshi.common.timers 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	/**
	 * 非同期処理をさせるためのクラス
	 * 
	 * @author tencho
	 */
	public class IntervalTask 
	{
		private var _isRunning:Boolean;
		private var taskList:Vector.<TaskData>;
		private var sprite:Sprite;
		private var index:Number;
		private var currentTask:TaskData;
		private var complete:Function;
		private var args:Array;
		private var name:String;
		private var wait:int;
		private var _interval:int;
		private var _frameSkip:int;
		private var isPausing:Boolean;
		
		//--------------------------------------------------------------------------
		//
		//  コンストラクタ
		//
		//--------------------------------------------------------------------------
		
		public function IntervalTask(name:String = "") 
		{
			this.name = name;
			isPausing = false;
			_interval = 33;
			_frameSkip = 0;
			wait = 0;
			sprite = new Sprite();
			taskList = new Vector.<TaskData>;
		}
		
		//--------------------------------------------------------------------------
		//
		//  タスク追加
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 条件付きループ処理を登録する
		 * @param	init	初期化時に実行される関数。通常イテレータ変数の初期値とループを抜ける条件値の代入に使う。
		 * @param	task	ループ処理。通常この関数内にイテレータ変数をインクリメントなどする。
		 * @param	conditional	ループの条件関数。戻り値がtrueの間はループし続ける。
		 * @return
		 */
		public function addLoopTask(name:String, init:Function, task:Function, conditional:Function = null):TaskData
		{
			var data:TaskData = new TaskData();
			data.name = name;
			data.isInit = false;
			data.init = init;
			data.task = task;
			data.args = null;
			data.conditional = conditional;
			taskList.push(data);
			return data;
		}
		
		/**
		 * 通常の処理を登録する
		 * @param	task
		 * @param	args
		 * @return
		 */
		public function addSingleTask(name:String, task:Function, args:Array = null):TaskData 
		{
			var data:TaskData = new TaskData();
			data.name = name;
			data.isInit = false;
			data.init = null;
			data.task = task;
			data.args = args || [];
			data.conditional = null;
			taskList.push(data);
			return data;
		}
		
		/**
		 * タスクを実行する
		 * @param	complete	タスク完了時に呼ばれる
		 * @param	args	タスク完了時にcompleteに渡される引数
		 */
		public function start(complete:Function = null, args:Array = null):void
		{
			for each(var task:TaskData in taskList)
			{
				task.isInit = false;
			}
			
			index = 0;
			this.args = args;
			this.complete = complete;
			
			if (taskList.length == 0 && complete != null)
			{
				complete.apply(null, args);
				return;
			}
			
			_isRunning = true;
			currentTask = taskList[index];
			sprite.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			enterFrameHandler(null);
		}
		
		/**
		 * タスクを一時停止（再開可能）
		 */
		public function stop():void 
		{
			sprite.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		/**
		 * このタスクを完全停止する
		 */
		public function clear():void 
		{
			stop();
			_isRunning = false;
			currentTask = null;
			complete = null;
			args = null;
			taskList.length = 0;
		}
		
		public function resume():void
		{
			isPausing = false;
			if (currentTask == null)
			{
				applyComplete();
			}
		}
		
		public function pause():void 
		{
			isPausing = true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  内部処理
		//
		//--------------------------------------------------------------------------
		
		private function enterFrameHandler(e:Event):void 
		{
			//待機フレームがあれば待つ
			if (wait > 0)
			{
				wait--;
				return;
			}
			
			//ポーズ中は処理停止
			if (isPausing)
			{
				return;
			}
			
			var t:int;
			var r:int;
			var startTime:int = getTimer();
			var prevTime:int = startTime;
			while (currentTask)
			{
				//初回実行
				if (currentTask.isInit == false)
				{
					currentTask.isInit = true;
					if (currentTask.init != null)
					{
						currentTask.init();
					}
				}
				
				if (currentTask.conditional == null)
				{
					//条件なし
					currentTask.task.apply(null, currentTask.args);
					next();
				}
				else if (currentTask.conditional())
				{
					//条件あり＆一致
					currentTask.task.apply(null, currentTask.args);
				}
				else
				{
					//条件あり＆不一致
					next();
				}
				
				var time:int = getTimer();
				if (currentTask != null)
				{
					var past:int = time - prevTime;
					if (past > _interval)
					{
						wait = Math.ceil(past / _interval) - 1;
						if (wait > _frameSkip)
						{
							wait = _frameSkip;
						}
					}
				}
				//処理途中でポーズがかかった場合 or 経過時間がオーバーしていればループを抜ける
				if (isPausing || prevTime - startTime > _interval)
				{
					break;
				}
				
				prevTime = time;
			}
		}
		
		/**
		 * 次のタスクへ移動し、無かったらcompleteを呼び出す
		 */
		private function next():void 
		{
			index++;
			currentTask = (index < taskList.length)? taskList[index] : null;
			if (currentTask == null && isPausing == false)
			{
				applyComplete();
			}
		}
		
		private function applyComplete():void 
		{
			_isRunning = false;
			var tempComplete:Function = complete;
			var tempArgs:Array = args;
			clear();
			if (tempComplete != null)
			{
				tempComplete.apply(null, tempArgs);
			}
			tempArgs = null;
			tempComplete = null;
		}
		
		/**
		 * 1frameに連続処理できるミリ秒時間
		 */
		public function get interval():int 
		{
			return _interval;
		}
		
		public function set interval(value:int):void 
		{
			_interval = value;
		}
		
		/**
		 * 1frameの負荷がintervalを超えてしまった時のフレームスキップ処理の限界フレーム。0でフレームスキップ無し。
		 */
		public function get frameSkip():int 
		{
			return _frameSkip;
		}
		
		public function set frameSkip(value:int):void 
		{
			_frameSkip = value;
		}
		
		public function get isRunning():Boolean
		{
			return _isRunning;
		}
		
	}

}