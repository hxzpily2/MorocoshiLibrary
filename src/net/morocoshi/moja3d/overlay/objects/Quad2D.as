package net.morocoshi.moja3d.overlay.objects 
{
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.shaders.overlay.SpriteFillShader;
	
	use namespace moja3d;
	/**
	 * ...
	 * @author tencho
	 */
	public class Quad2D extends Plane2D 
	{
		private var fillShader:SpriteFillShader;
		private var _color:uint;
		
		public function Quad2D(width:Number, height:Number, color:uint, alpha:Number = 1, originX:Number = 0, originY:Number = 0) 
		{
			super(width, height, originX, originY);
			
			_color = color;
			fillShader = new SpriteFillShader(_color, alpha);
			_material.shaderList.addShader(fillShader);
		}
		
	}

}