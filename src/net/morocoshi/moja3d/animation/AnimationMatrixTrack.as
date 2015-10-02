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
		public var startTime:Number;
		/**終了時間（秒）*/
		public var endTime:Number;
		/**各キーフレームの位置（秒）*/
		public var timeList:Vector.<Number>;
		/**各キーフレームでの姿勢*/
		public var matrixList:Vector.<Matrix3D>;
		/**各キーフレームの補完タイプ*/
		public var tangentList:Vector.<int>;
		/**アニメーションが終端を超えた場合ループさせるか*/
		public var loop:Boolean;
		/**キーフレームの設定を無視した強制補完タイプ（TangentType.NONEで無効に）*/
		public var forceTangent:int = -1;
		
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
		
		public function addKey(time:Number, matrix:Matrix3D, tangent:int):void
		{
			timeList.push(time);
			matrixList.push(matrix);
			tangentList.push(tangent);
			timeLength = endTime - startTime;
		}
		
		public function getMatrix3D(time:Number):Matrix3D 
		{
			if (!timeList.length) return null;
			
			//範囲外をループする場合はstart～end内に収める
			if (loop)
			{
				time = ((time - startTime) % timeLength + timeLength) % timeLength + startTime;
			}
			else
			{
				if (time < startTime) time = startTime;
				if (time > endTime) time = endTime;
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
					var tangent:int = forceTangent == TangentType.NONE? tangentList[lastIndex] : forceTangent;
					if(tangent == TangentType.STEP)
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
			result.startTime = startTime;
			result.endTime = endTime;
			result.timeList = timeList.concat();
			result.matrixList = matrixList.concat();
			result.tangentList = tangentList.concat();
			result.loop = loop;
			result.forceTangent = forceTangent;
			result.timeLength = timeLength;
			result.lastIndex = lastIndex;
			return result;
		}
		
		public function reset():void 
		{
			lastIndex = 0;
		}
		
	}

}