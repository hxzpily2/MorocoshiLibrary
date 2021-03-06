package net.morocoshi.moja3d.animation 
{
	import flash.geom.Matrix3D;
	import net.morocoshi.moja3d.loader.animation.TangentType;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class AnimationMatrixTrack 
	{
		/**開始時間（秒）*/
		private var _startTime:Number;
		/**終了時間（秒）*/
		private var _endTime:Number;
		/**各キーフレームの位置（秒）*/
		public var timeList:Vector.<Number>;
		/**各キーフレームでの姿勢*/
		public var matrixList:Vector.<Matrix3D>;
		/**各キーフレームの補完タイプ*/
		public var tangentList:Vector.<int>;
		/**アニメーションが終端を超えた場合ループさせるか*/
		public var loop:Boolean;
		/**キーフレーム間の線形補完を行うかどうか。そもそも補完しない設定のフレームには意味がない*/
		public var interpolationEnabled:Boolean = true;
		
		/**開始～終了の時間*/
		private var timeLength:Number;
		/**前回チェックしたインデックス*/
		private var lastIndex:int;
		
		public function AnimationMatrixTrack() 
		{
			timeList = new Vector.<Number>;
			matrixList = new Vector.<Matrix3D>;
			tangentList = new Vector.<int>;
			loop = true;
		}
		
		public function clear():void
		{
			timeList = null;
			matrixList = null;
			tangentList = null;
		}
		
		public function addKey(time:Number, matrix:Matrix3D, tangent:int):void
		{
			timeList.push(time);
			matrixList.push(matrix);
			tangentList.push(tangent);
			updateTimeLength();
		}
		
		public function getMatrix3D(time:Number):Matrix3D 
		{
			if (!timeList.length) return null;
			
			//範囲外をループする場合はstart～end内に収める
			if (loop)
			{
				time = ((time - _startTime) % timeLength + timeLength) % timeLength + _startTime;
			}
			else
			{
				if (time < _startTime) time = _startTime;
				if (time > _endTime) time = _endTime;
			}
			var max:int = timeList.length - 1;
			
			//start以下だったら最初の値を返す
			if (time <= timeList[0]) return matrixList[0];
			
			//end以上だったら最後の値を返す
			if (timeList.length >= 2 && time >= timeList[max]) return matrixList[max];
			
			//それ以外だったら
			//前回取得時のインデックスからチェックを開始する
			for (var i:int = 0; i < max; i++) 
			{
				if (lastIndex >= max) lastIndex -= max;
				
				if (time == timeList[lastIndex]) return matrixList[lastIndex];
				
				if (time > timeList[lastIndex] && time < timeList[lastIndex + 1])
				{
					var tangent:int = tangentList[lastIndex];
					if(tangent == TangentType.STEP || interpolationEnabled == false)
					{
						return matrixList[lastIndex];
					}
					var per:Number = (time - timeList[lastIndex]) / (timeList[lastIndex + 1] - timeList[lastIndex]);
					return Matrix3D.interpolate(matrixList[lastIndex], matrixList[lastIndex + 1], per); 
				}
				
				lastIndex++;
			}
			
			//処理的にここまではこないはず
			return matrixList[max];
		}
		
		public function clone():AnimationMatrixTrack 
		{
			var result:AnimationMatrixTrack = new AnimationMatrixTrack();
			result.startTime = _startTime;
			result.endTime = _endTime;
			result.timeList = timeList.concat();
			result.matrixList = matrixList.concat();
			result.tangentList = tangentList.concat();
			result.loop = loop;
			result.interpolationEnabled = interpolationEnabled;
			result.timeLength = timeLength;
			result.lastIndex = lastIndex;
			return result;
		}
		
		public function reset():void 
		{
			lastIndex = 0;
		}
		
		private function updateTimeLength():void 
		{
			timeLength = _endTime - _startTime;
		}
		
		public function get startTime():Number 
		{
			return _startTime;
		}
		
		public function set startTime(value:Number):void 
		{
			_startTime = value;
			updateTimeLength();
		}
		
		public function get endTime():Number 
		{
			return _endTime;
		}
		
		public function set endTime(value:Number):void 
		{
			_endTime = value;
			updateTimeLength();
		}
		
	}

}