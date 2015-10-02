package net.morocoshi.moja3d.shaders 
{
	import net.morocoshi.common.math.list.VectorUtil;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ShaderManager 
	{
		private var shaders:Vector.<MaterialShader>;
		
		public function ShaderManager() 
		{
			shaders = new Vector.<MaterialShader>;
		}
		
		public function addShader(shader:MaterialShader):Boolean
		{
			return VectorUtil.attachItemDiff(shaders, shader);
		}
		
		public function clear():void
		{
			shaders.length = 0;
		}
		
		public function removeShader(shader:MaterialShader):Boolean
		{
			return VectorUtil.deleteItem(shaders, shader);
		}
		
		public function calculate():void
		{
			var n:int = shaders.length;
			for (var i:int = 0; i < n; i++) 
			{
				var shader:MaterialShader = shaders[i];
				shader.calculate();
			}
		}
		
		public function draw():void
		{
			var n:int = shaders.length;
			for (var i:int = 0; i < n; i++) 
			{
				var shader:MaterialShader = shaders[i];
				shader.draw();
			}
		}
		
	}

}