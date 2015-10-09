package net.morocoshi.moja3d.loader.geometries 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class M3DSkinGeometry extends M3DMeshGeometry 
	{
		public var weights1:Vector.<Number>;
		public var weights2:Vector.<Number>;
		public var boneIndices1:Vector.<Number>;
		public var boneIndices2:Vector.<Number>;
		
		/**ボーンINDEXの配列*/
		public var boneIDList:Vector.<int>;
		
		private var boneCount:int;
		
		public function M3DSkinGeometry() 
		{
			super();
		}
		
		public function fixJointIndex():void
		{
			if (boneIDList) return;
			
			var boneMap:Object = { };
			boneIDList = new Vector.<int>;
			boneCount = -1;
			
			var i:int;
			var n:int;
			var index:int;
			
			n = boneIndices1.length;
			for (i = 0; i < n; i++)
			{
				index = boneIndices1[i];
				if (boneMap[index] === undefined)
				{
					boneCount++;
					boneMap[index] = boneCount;
					boneIDList.push(index);
				}
				boneIndices1[i] = boneMap[index];
			}
			
			if (boneIndices2)
			{
				n = boneIndices2.length;
				for (i = 0; i < n; i++) 
				{
					index = boneIndices2[i];
					if (boneMap[index] === undefined)
					{
						boneCount++;
						boneMap[index] = boneCount;
						boneIDList.push(index);
					}
					boneIndices2[i] = boneMap[index];
				}
			}
		}
		
		override public function getKey():String 
		{
			var key:Array = [];
			if (boneIndices1)	key.push("7:" + boneIndices1.join(","));
			if (weights1)		key.push("8:" + weights1.join(","));
			if (boneIndices2)	key.push("9:" + boneIndices2.join(","));
			if (weights2)		key.push("X:" + weights2.join(","));
			return super.getKey() + "|" + key.join("|");
		}
		
	}

}