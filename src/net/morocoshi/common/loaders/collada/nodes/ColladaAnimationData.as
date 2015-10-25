package net.morocoshi.common.loaders.collada.nodes 
{
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ColladaAnimationData 
	{
		/**キーフレーム位置（秒単位？）*/
		public var times:Array;
		/**キーフレーム値*/
		public var values:Array;
		/**ベジェ用ハンドルデータ*/
		public var inTangent:Array;
		/**ベジェ用ハンドルデータ*/
		public var outTangent:Array;
		/**補完タイプ。まだLINEARにしか対応してない*/
		public var tangents:Array;
		/**matrixとか*/
		public var type:String;
		/**単位スケーリング済み*/
		private var scaled:Boolean = false;
		
		public function ColladaAnimationData() 
		{
		}
		
		public function scaleMatrix(scale:Number):void 
		{
			if (scaled) return;
			scaled = true;
			
			var n:int = values.length;
			for (var i:int = 0; i < n; i++) 
			{
				var data:Array = values[i];
				data[3] *= scale;
				data[7] *= scale;
				data[11] *= scale;
			}
		}
		
		public function scaleTranslation(scale:Number):void 
		{
			if (scaled) return;
			scaled = true;
			
			var i:int;
			var n:int;
			
			if (inTangent)
			{
				n = inTangent.length;
				for (i = 0; i < n; i++)
				{
					inTangent[i][1] *= scale;
				}
			}
			
			if (outTangent)
			{
				n = outTangent.length;
				for (i = 0; i < n; i++)
				{
					outTangent[i][1] *= scale;
				}
			}
			
			n = values.length;
			for (i = 0; i < n; i++)
			{
				values[i] *= scale;
			}
		}
		
	}

}