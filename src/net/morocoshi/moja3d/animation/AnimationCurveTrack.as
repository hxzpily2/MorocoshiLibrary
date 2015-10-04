package net.morocoshi.moja3d.animation 
{
	import flash.display.Graphics;
	import net.morocoshi.moja3d.loader.animation.M3DCurveTrack;
	import net.morocoshi.moja3d.loader.animation.M3DKeyframe;
	import net.morocoshi.moja3d.loader.animation.TangentType;
	
	/**
	 * アニメーショントラック
	 * 
	 * @author tencho
	 */
	public class AnimationCurveTrack 
	{
		public var startTime:Number;
		public var endTime:Number;
		private var timeLength:Number;
		public var timeList:Vector.<Number>;
		public var valueList:Vector.<Number>;
		public var tangentList:Vector.<int>;
		/**キーフレーム間の線形補完を行うかどうか。そもそも補完しない設定のフレームには意味がない*/
		public var interpolationEnabled:Boolean = true;
		
		/**アニメーションが終端を超えた場合ループさせるか*/
		public var loop:Boolean;
		/**パース前の生データ*/
		public var rawData:M3DCurveTrack;
		
		private var lastIndex:int = 0;
		
		public function AnimationCurveTrack() 
		{
			timeList = new Vector.<Number>;
			valueList = new Vector.<Number>;
			tangentList = new Vector.<int>;
			loop = true;
		}
		
		/**
		 * スプラインカーブ用のキーフレームリストを渡して曲線上にキーフレームを生成させる。
		 * @param	curveList
		 * @param	bezierCurveInterval	曲線の分割数。0で分割無し。
		 */
		public function parse(curveList:Vector.<CurveKey>, bezierCurveInterval:Number):void
		{
			timeList.length = 0;
			valueList.length = 0;
			tangentList.length = 0;
			var n:int = curveList.length;
			if (n == 0) return;
			addKey(curveList[0].time, curveList[0].value, TangentType.LINER);
			
			var i:int;
			var j:int;
			var rate:Number;
			for (i = 0; i < n - 1; i++) 
			{
				var c0:CurveKey = curveList[i];
				var c1:CurveKey = curveList[i + 1];
				var seg:int = (c1.time - c0.time) / bezierCurveInterval;
				switch(c0.tangent)
				{
					case TangentType.STEP:
						addKey(c1.time, c1.value, TangentType.STEP);
						break;
					case TangentType.LINER:
						addKey(c1.time, c1.value, TangentType.LINER);
						break;
					case TangentType.HERMITE:
						//___コントロールポイントが直線状の場合も考慮したい
						if (!c0.isCurvePointNext && !c1.isCurvePointPrev) seg = 0;
						for (j = 0; j <= seg; j++) 
						{
							//0<rate<=1
							rate = (j + 1) / (seg + 1);
							addHermiteKey(c0.time, c0.value, c1.time, c1.value, c0.nextCtrlTime, c0.nextCtrlValue, c1.prevCtrlTime, c1.prevCtrlValue, rate);
						}
						break;
					case TangentType.BEZIER:
						//___コントロールポイントが直線状の場合も考慮したい
						if (!c0.isCurvePointNext && !c1.isCurvePointPrev) seg = 0;
						for (j = 0; j <= seg; j++) 
						{
							//0<rate<=1
							rate = (j + 1) / (seg + 1);
							addBezierKey(c0.time, c0.value, c1.time, c1.value, c0.time + c0.nextCtrlTime, c0.value + c0.nextCtrlValue, c1.time + c1.prevCtrlTime, c1.value + c1.prevCtrlValue, rate);
						}
						break;
				}
			}
		}
		
		public function reset():void
		{
			lastIndex = 0;
		}
		
		/**
		 * 指定時間における値を取得する。常に前回取得時より先の時間を取得していくことで処理が軽くなる
		 * @param	time
		 * @return
		 */
		public function getValue(time:Number):Number 
		{
			if (!timeList.length) return 0;
			
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
			if (time <= timeList[0])
			{
				return valueList[0];
			}
			
			//end以上だったら最後の値を返す
			if (timeList.length >= 2 && time >= timeList[max])
			{
				return valueList[max];
			}
			
			//それ以外だったら
			//前回取得時のインデックスからチェックを開始する
			for (var i:int = 0; i < max; i++) 
			{
				if (lastIndex >= max) lastIndex -= max;
				
				if (time == timeList[lastIndex]) return valueList[lastIndex];
				
				if (time > timeList[lastIndex] && time < timeList[lastIndex + 1])
				{
					var tangent:int = tangentList[lastIndex];
					if(tangent == TangentType.STEP || interpolationEnabled == false)
					{
						return valueList[lastIndex];
					}
					var per:Number = (time - timeList[lastIndex]) / (timeList[lastIndex + 1] - timeList[lastIndex]);
					return valueList[lastIndex] * (1 - per) + valueList[lastIndex + 1] * per;
				}
				
				lastIndex++;
			}
			//処理的にここまではこないはず
			return valueList[max];
		}
		
		/**
		 * エルミート曲線上にキーを打つ(終点ベクトルの扱いはベジェとは逆なので注意)
		 */
		private function addHermiteKey(p0x:Number, p0y:Number, p1x:Number, p1y:Number, n0x:Number, n0y:Number, n1x:Number, n1y:Number, rate:Number):void
		{
			var rr:Number = rate * rate;
			var rrr:Number = rr * rate;
			var b:Number = -2 * rrr + 3 * rr;
			var a:Number = -b + 1;
			var c:Number = rrr - 2 * rr + rate;
			var d:Number = rrr - rr;
			
			var y:Number = p0y * a + n0y * c + p1y * b + n1y * d;
			var x:Number = p0x * a + n0x * c + p1x * b + n1x * d;
			addKey(x, y, TangentType.LINER);
		}
		
		/**
		 * ベジェ曲線上にキーを打つ
		 */
		private function addBezierKey(ax:Number, ay:Number, bx:Number, by:Number, cax:Number, cay:Number, cbx:Number, cby:Number, t:Number):void
		{
			var t2:Number = 1 - t;
			var v1:Number = t2 * t2 * t2;
			var v2:Number = 3 * t * t2 * t2;
			var v3:Number = 3 * t * t * t2;
			var v4:Number = t * t * t;
			var px:Number = v1 * ax + v2 * cax + v3 * cbx + v4 * bx;
			var py:Number = v1 * ay + v2 * cay + v3 * cby + v4 * by;
			addKey(px, py, TangentType.LINER);
		}
		
		public function addKey(time:Number, value:Number, tangent:int):void 
		{
			timeList.push(time);
			valueList.push(value);
			tangentList.push(tangent);
			timeLength = endTime - startTime;
		}
		
		public function drawAnimation(graphics:Graphics, thickness:Number, color:uint, scaleX:Number, scaleY:Number):void 
		{
			graphics.lineStyle(thickness, color, 1);
			var n:int = timeList.length;
			for (var i:int = 0; i < n; i++) 
			{
				if (i == 0)
				{
					graphics.moveTo(timeList[i] * scaleX, valueList[i] * scaleY);
				}
				else
				{
					graphics.lineTo(timeList[i] * scaleX, valueList[i] * scaleY);
				}
			}
			for (i = 0; i < rawData.keyList.length; i++) 
			{
				var key:M3DKeyframe = rawData.keyList[i];
				var sx:Number = (key.time) * scaleX;
				var sy:Number = (key.value) * scaleY;
				var ex:Number = (key.time + key.nextTime) * scaleX;
				var ey:Number = (key.value + key.nextValue) * scaleY;
				graphics.beginFill(color, 1);
				graphics.drawCircle(sx, sy, thickness * 2);
				graphics.endFill();
				graphics.drawCircle(ex, ey, thickness * 2);
				graphics.moveTo(sx, sy);
				graphics.lineTo(ex, ey);
				
				if (i < rawData.keyList.length - 1)
				{
					key = rawData.keyList[i + 1];
					sx = (key.time) * scaleX;
					sy = (key.value) * scaleY;
					ex = (key.time + key.prevTime) * scaleX;
					ey = (key.value + key.prevValue) * scaleY;
					graphics.beginFill(color, 1);
					graphics.drawCircle(sx, sy, thickness * 2);
					graphics.endFill();
					graphics.drawCircle(ex, ey, thickness * 2);
					graphics.moveTo(sx, sy);
					graphics.lineTo(ex, ey);
				}
			}
		}
		
		public function clone():AnimationCurveTrack 
		{
			var result:AnimationCurveTrack = new AnimationCurveTrack();
			result.startTime = startTime;
			result.endTime = endTime;
			result.timeLength = timeLength;
			result.timeList = timeList.concat();
			result.valueList = valueList.concat();
			result.tangentList = tangentList.concat();
			result.interpolationEnabled = interpolationEnabled;
			result.loop = loop;
			result.rawData = rawData;
			result.lastIndex = lastIndex;
			return result;
		}
		
	}

}