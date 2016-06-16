package net.morocoshi.moja3d.objects 
{
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.shaders.outline.OutlineColorShader;
	
	use namespace moja3d;
	
	/**
	 * ポリゴンベースのアウトライン
	 * 
	 * @author tencho
	 */
	public class Outline 
	{
		moja3d var shader:OutlineColorShader;
		
		/**
		 * アウトラインを表示するか
		 */
		public var enabled:Boolean;
		
		/**
		 * @param	thickness	厚さ
		 * @param	color		色
		 * @param	alpha		不透明度
		 * @param	fixed		厚さがカメラ距離に関係なく一定
		 */
		public function Outline(thickness:Number = 1, color:uint = 0x000000, alpha:Number = 1, fixed:Boolean = true) 
		{
			shader = new OutlineColorShader(thickness, color, alpha, fixed);
		}
		
		public function clone():Outline 
		{
			var result:Outline = new Outline(thickness, color, alpha, fixed);
			result.enabled = enabled;
			return result;
		}
		
		/**
		 * アウトラインの厚さ
		 */
		public function get thickness():Number 
		{
			return shader.thickness;
		}
		
		public function set thickness(value:Number):void 
		{
			shader.thickness = value;
		}
		
		/**
		 * アウトラインの色
		 */
		public function get color():uint 
		{
			return shader.color;
		}
		
		public function set color(value:uint):void 
		{
			shader.color = value;
		}
		
		/**
		 * アウトラインの不透明度
		 */
		public function get alpha():Number 
		{
			return shader.alpha;
		}
		
		public function set alpha(value:Number):void 
		{
			shader.alpha = value;
		}
		
		/**
		 * アウトラインの厚さがカメラ距離に関係なく一定になるか
		 */
		public function get fixed():Boolean 
		{
			return shader.fixed;
		}
		
		public function set fixed(value:Boolean):void 
		{
			shader.fixed = value;
		}
		
	}

}