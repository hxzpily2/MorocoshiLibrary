package net.morocoshi.common.loaders.fbx.animation 
{
	import mx.utils.StringUtil;
	import net.morocoshi.common.debug.TraceBox;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	import net.morocoshi.common.loaders.fbx.FBXScene;
	
	/**
	 * まだ途中なので後でなんとかする。
	 * まだFBXからアニメーションをパースする方法が見つかってないので意味ないけど・・・
	 * 
	 * @author tencho
	 */
	public class FBXAnimationCurve
	{
		public var id:Number;
		public var times:Vector.<Number>;
		public var values:Vector.<Number>;
		public var nextControlT:Vector.<Number>;
		public var nextControlV:Vector.<Number>;
		public var prevControlT:Vector.<Number>;
		public var prevControlV:Vector.<Number>;
		
		public function FBXAnimationCurve(node:FBXNode = null) 
		{
			if (node) parse(node);
		}
		
		public function parse(node:FBXNode):void
		{
			id = node.$args[0];
			times = new Vector.<Number>;
			values = new Vector.<Number>;
			nextControlT = new Vector.<Number>;
			nextControlV = new Vector.<Number>;
			prevControlT = new Vector.<Number>;
			prevControlV = new Vector.<Number>;
			var timeList:Array = [];
			
			var i:int;
			var n:int;
			var alist:Array;
			var numKeyframe:int;
			//時間
			if (node.KeyTime && node.KeyTime[0][0].a)
			{
				alist = node.KeyTime[0][0].a[0];
				numKeyframe = n = alist.length;
				for (i = 0; i < n; i++) 
				{
					times.push(alist[i] / FBXScene.MSEC_TO_FBX);
				}
			}
			//値
			if (node.KeyValueFloat && node.KeyValueFloat[0][0].a)
			{
				alist = node.KeyValueFloat[0][0].a[0];
				n = alist.length;
				for (i = 0; i < n; i++) 
				{
					values.push(alist[i]);
					timeList[i] = (i == n - 1)? 0 : times[i + 1] - times[i]
				}
			}
			
			//カーブ
			var details:Vector.<Object> = new Vector.<Object>;
			var comment:String = node.getComment("KeyAttrDataFloat", 0)[0];
			comment = comment.split("KeyAttrDataFloat:")[1];
			var comList:Array = comment.split(";");
			for (i = 0; i < comList.length; i++)
			{
				details[i] = { };
				var items:Array = comList[i].split(",");
				for (var j:int = 0; j < items.length; j++) 
				{
					var item:String = items[j].split(" ").join("");
					item = item.split("\n").join("");
					var data:Array = item.split(":");
					var comKey:String = data[0];
					var comVal:Number = Number(data[1]);
					details[i][comKey] = comVal;
				}
			}
			
			for (i = 0; i < numKeyframe; i++)
			{
				var index:int = (i < comList.length)? i : comList.length - 1;
				var currentDetail:Object = details[index];
				var prevDetail:Object = (index > 0)? details[index - 1] : null;
				nextControlV[i] = (currentDetail.RightAuto !== 0)? calcHeight(currentDetail.RightSlope, currentDetail.RightWeight, timeList[i]) : 0;
				nextControlT[i] = (currentDetail.RightAuto !== 0)? currentDetail.RightWeight * timeList[i] : 0;
				prevControlV[i] = (prevDetail && prevDetail.NextLeftAuto !== 0)? -calcHeight(prevDetail.NextLeftSlope, prevDetail.NextLeftWeight, timeList[i - 1]) : 0;
				prevControlT[i] = (prevDetail && prevDetail.NextLeftAuto !== 0)? -prevDetail.NextLeftWeight * timeList[i - 1] : 0;
			}
		}
		
		private function calcHeight(slope:Number, weight:Number, time:Number):Number 
		{
			return slope * weight * time / 1000;
		}
		
		/**
		 * 全キーの値がdefと同じ＆カーブ無しだったら不要なアニメーションなのでfalseを返す
		 * @param	defaultX
		 */
		public function checkValid(def:Number):Boolean 
		{
			var n:int = values.length;
			for (var i:int = 0; i < n; i++) 
			{
				if (values[i] != def) return true;
			}
			return false;
		}
		
	}

}