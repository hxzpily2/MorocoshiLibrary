package net.morocoshi.common.loaders.fbx.animation 
{
	import flash.geom.Vector3D;
	import net.morocoshi.common.debug.TraceBox;
	import net.morocoshi.common.loaders.fbx.FBXNode;
	import net.morocoshi.common.loaders.fbx.FBXParser;
	import net.morocoshi.common.loaders.fbx.objects.FBXObject;
	import net.morocoshi.common.math.transform.AngleUtil;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FBXAnimationNode 
	{
		public var id:Number;
		public var x:FBXAnimationCurve;
		public var y:FBXAnimationCurve;
		public var z:FBXAnimationCurve;
		
		//これ180度ずれてる可能性がある
		public var defaultX:Number;
		public var defaultY:Number;
		public var defaultZ:Number;
		
		public function FBXAnimationNode(node:FBXNode = null) 
		{
			if (node) parse(node);
		}
		
		public function parse(node:FBXNode):void 
		{
			id = node.$args[0];
			var prop:Object = FBXParser.parseProperties(node.Properties70);
			defaultX = prop["d|X"];
			defaultY = prop["d|Y"];
			defaultZ = prop["d|Z"];
		}
		
		public function attachCurve(curve:FBXAnimationCurve, extra:String):void 
		{
			switch(extra)
			{
				case "d|X": x = curve; break;
				case "d|Y": y = curve; break;
				case "d|Z": z = curve; break;
			}
		}
		
		public function checkRotationError(rotation:Vector3D):void
		{
			var fix:Number  = checkError(x, defaultX) || checkError(y, defaultY) || checkError(z, defaultZ);
			if (fix)
			{
				rotation.x += fix;
				rotation.y += fix;
				rotation.z += fix;
			}
		}
		
		private function checkError(curve:FBXAnimationCurve, def:Number):Number 
		{
			if (curve == null || curve.values.length == 0) return 0;
			var angle:Number = AngleUtil.getNearDegree(curve.values[0], def);
			if (angle < 178) return 0;
			return (curve.values[0] > def)? Math.PI : -Math.PI;
		}
		
		public function checkValid():Boolean 
		{
			if (x && x.checkValid(defaultX) == false) x = null;
			if (y && y.checkValid(defaultY) == false) y = null;
			if (z && z.checkValid(defaultZ) == false) z = null;
			return Boolean(x || y || z);
		}
		
	}

}