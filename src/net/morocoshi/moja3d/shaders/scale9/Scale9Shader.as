package net.morocoshi.moja3d.shaders.scale9 
{
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.resources.Geometry;
	import net.morocoshi.moja3d.resources.VertexAttribute;
	import net.morocoshi.moja3d.shaders.AlphaTransform;
	import net.morocoshi.moja3d.shaders.MaterialShader;
	
	/**
	 * Scale9用
	 * 
	 * @author tencho
	 */
	public class Scale9Shader extends MaterialShader 
	{
		private var constant:AGALConstant;
		private var geometry:Geometry;
		private var _x1:Number = 0;
		private var _x2:Number = 0;
		private var _y1:Number = 0;
		private var _y2:Number = 0;
		
		public function Scale9Shader(geometry:Geometry) 
		{
			super();
			this.geometry = geometry;
			
			updateTexture();
			updateAlphaMode();
			updateConstants();
			updateShaderCode();
		}
		
		override public function getKey():String 
		{
			return "Scale9Shader:";
		}
		
		override protected function updateAlphaMode():void
		{
			super.updateAlphaMode();
			alphaTransform = AlphaTransform.UNCHANGE;
		}
		
		override protected function updateTexture():void 
		{
			super.updateTexture();
		}
		
		override protected function updateConstants():void 
		{
			super.updateConstants();
			constant = vertexCode.addConstantsFromArray("@scale9", [_x1, _x2, _y1, _y2]);
		}
		
		override protected function updateShaderCode():void 
		{
			super.updateShaderCode();
			
			var va:String = "va" + geometry.getAttributeIndex(VertexAttribute.SCALE9);
			vertexConstants.number = true;
			
			vertexCode.addCode([
				"var $split",
				"$split.x = " + va + ".x +" + va + ".y",
				"$split.y = " + va + ".z +" + va + ".w",
				"$split.xy = @1_1 - $split.xy",
				"$pos.xy *= $split.xy",
				"$split.x = @scale9.x * " + va + ".x",
				"$split.y = @scale9.y * " + va + ".y",
				"$split.z = @scale9.z * " + va + ".z",
				"$split.w = @scale9.w * " + va + ".w",
				"$pos.x += $split.x",
				"$pos.x += $split.y",
				"$pos.y += $split.z",
				"$pos.y += $split.w"
			]);
		}
		
		override public function clone():MaterialShader 
		{
			var shader:Scale9Shader = new Scale9Shader(geometry);
			return shader;
		}
		
		public function get x1():Number 
		{
			return _x1;
		}
		
		public function set x1(value:Number):void 
		{
			constant.x = _x1 = value;
		}
		
		public function get x2():Number 
		{
			return _x2;
		}
		
		public function set x2(value:Number):void 
		{
			constant.y = _x2 = value;
		}
		
		public function get y1():Number 
		{
			return _y1;
		}
		
		public function set y1(value:Number):void 
		{
			constant.z = _y1 = value;
		}
		
		public function get y2():Number 
		{
			return _y2;
		}
		
		public function set y2(value:Number):void 
		{
			constant.w = _y2 = value;
		}
		
	}

}