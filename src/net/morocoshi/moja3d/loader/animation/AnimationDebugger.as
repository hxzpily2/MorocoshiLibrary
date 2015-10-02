package net.morocoshi.moja3d.loader.animation 
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import net.morocoshi.moja3d.animation.AnimationCurveNode;
	import net.morocoshi.moja3d.animation.KeyframeAnimation;
	import net.morocoshi.moja3d.loader.M3DParser;
	/**
	 * ...
	 * @author tencho
	 */
	public class AnimationDebugger 
	{
		public var sprite:Sprite;
		
		public function AnimationDebugger() 
		{
			sprite = new Sprite();
		}
		
		public function parse(parser:M3DParser):void 
		{
			var g:Graphics = sprite.graphics;
			g.clear();
			
			if (parser.keyAnimations.length == 0)
			{
				return;
			}
			
			g.lineStyle(0.5, 0x808080, 0.9);
			for (var ix:int = -100; ix <= 100; ix+= 10) 
			{
				g.moveTo(0, ix);
				g.lineTo(400, ix);
			}
			g.lineStyle();
			
			for each(var key:KeyframeAnimation in parser.keyAnimations)
			{
				if (key.position) drawCurve(key.position);
				if (key.rotation) drawCurve(key.rotation);
				if (key.scale) drawCurve(key.scale);
			}
		}
		
		private function drawCurve(curve:AnimationCurveNode):void 
		{
			if (curve.x) curve.x.drawAnimation(sprite.graphics, 1, 0xff0000, 0.1, 1);
			if (curve.y) curve.y.drawAnimation(sprite.graphics, 1, 0x00ff00, 0.1, 1);
			if (curve.z) curve.z.drawAnimation(sprite.graphics, 1, 0x0000ff, 0.1, 1);
		}
		
	}

}