package net.morocoshi.moja3d.loader.optimize 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class M3DFace 
	{
		public var jointIndices:Vector.<int>;
		public var vertices:Vector.<M3DVertex>;
		public var material:int;
		public var minIndex:int;
		
		public function M3DFace() 
		{
			vertices = new Vector.<M3DVertex>;
			jointIndices = new Vector.<int>;
		}
		
		public function checkMinIndex():void
		{
			minIndex = int.MAX_VALUE;
			for each (var item:int in jointIndices) 
			{
				if (item < minIndex) minIndex = item;
			}
		}
		
		public function addVertex(v:M3DVertex):void
		{
			vertices.push(v);
			
			var index:int;
			for each (index in v.boneIndex1) 
			{
				if (jointIndices.indexOf(index) == -1)
				{
					jointIndices.push(index);
				}
			}
			for each (index in v.boneIndex2)
			{
				if (jointIndices.indexOf(index) == -1)
				{
					jointIndices.push(index);
				}
			}
			
			if (vertices.length == 3)
			{
				checkMinIndex();
			}
		}
		
	}

}