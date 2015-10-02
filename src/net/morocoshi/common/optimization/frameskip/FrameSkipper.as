package net.morocoshi.common.optimization.frameskip 
{
	import flash.utils.getTimer;
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FrameSkipper 
	{
		private var prev:int;
		private var tick:Number;
		private var _skipFrame:int;
		private var skipRate:Number;
		private var _targetFPS:int;
		private var _drawable:Boolean;
		private var _maxSkipFrame:int;
		private var _enabled:Boolean;
		private var _calcTime:Number;
		private var numCalc:int;
		private var _drawTime:int;
		private var prevCalcTime:int;
		private var overDrawTime:int;
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		public function FrameSkipper() 
		{
			_skipFrame = 0;
			_calcTime = 0;
			numCalc = 0;
			prev = -1;
			_drawable = true;
			targetFPS = 30;
			skipRate = 5;
			_maxSkipFrame = 10;
			_enabled = true;
		}
		
		//--------------------------------------------------------------------------
		//
		//  
		//
		//--------------------------------------------------------------------------
		
		public function set targetFPS(value:int):void
		{
			_targetFPS = value;
			tick = 1000 / _targetFPS;
		}
		
		public function get targetFPS():int
		{
			return _targetFPS;
		}
		
		public function get drawable():Boolean 
		{
			return _drawable;
		}
		
		public function set drawable(value:Boolean):void 
		{
			_drawable = value;
		}
		
		public function get maxSkipFrame():int 
		{
			return _maxSkipFrame;
		}
		
		public function set maxSkipFrame(value:int):void 
		{
			_maxSkipFrame = value;
		}
		
		public function get enabled():Boolean 
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void 
		{
			_enabled = value;
		}
		
		public function get drawTime():int 
		{
			return _drawTime;
		}
		
		public function get calcTime():Number 
		{
			return _calcTime;
		}
		
		public function get skipFrame():int 
		{
			return _skipFrame;
		}
		
		//--------------------------------------------------------------------------
		//
		//  更新処理
		//
		//--------------------------------------------------------------------------
		
		/**
		 * 計算処理（毎フレーム実行）
		 * @param	func
		 */
		public function calculate(func:Function):void 
		{
			//計算＆時間計測
			var rec:int = getTimer();
			if (func != null)
			{
				func();
			}
			var time:int = getTimer() - rec;
			if (rec - prevCalcTime > tick + 5)
			{
				overDrawTime = rec - prevCalcTime - time;
			}
			else
			{
				overDrawTime = 0;
			}
			_calcTime += time;
			numCalc++;
			prevCalcTime = rec;
		}
		
		/**
		 * 描画処理（遅いとスキップされる）
		 * @param	func
		 */
		public function draw(func:Function):void
		{
			if (_enabled == false)
			{
				_drawable = true;
				_skipFrame = 0;
				_calcTime = 0;
				numCalc = 0;
				prev = -1;
				func();
				return;
			}
			
			//前回からの経過時間を計算
			var current:int = getTimer();
			var delta:int = (prev < 0)? 0 : current - prev;
			
			//フレームスキップ中
			if (_skipFrame > 0)
			{
				_skipFrame--;
				_drawTime = 0;
				_drawable = false;
			}
			else
			{
				//calculate()にかかった平均時間（ミリ秒）
				if (numCalc > 0)
				{
					_calcTime /= numCalc;
				}
				
				_drawable = true;
				//描画＆時間計測
				var rec:int = getTimer();
				func();
				_drawTime = Math.max(overDrawTime, getTimer() - rec);
				//次のフレームスキップを計算
				var rest:int = tick - _calcTime;//フレームレートを維持するために残された描画時間（ミリ秒）
				_skipFrame = (rest <= 0)? _maxSkipFrame : Math.ceil(_drawTime / rest) - 1;
				if (_skipFrame > _maxSkipFrame)
				{
					_skipFrame = _maxSkipFrame;
				}
				
				_calcTime = 0;
				numCalc = 0;
			}
			prev = current;
		}
		/*
		private var startTime:Number = new Date().getTime();
		public function getTimer():Number
		{
			return new Date().getTime() - startTime;
		}
		*/
	}

}