package net.morocoshi.common.loaders.fbx.expoters 
{
	import net.morocoshi.common.loaders.fbx.FBXNode;
	import net.morocoshi.common.loaders.fbx.FBXParser;
	
	/**
	 * FBX生成用のライトデータ
	 * 
	 * @author tencho
	 */
	public class FELightGeometry extends FEGeometry 
	{
		static public const OMNI:int = 0;
		static public const DIRECTIONAL:int = 1;
		static public const SPOT:int = 2;
		static public const AMBIENT:int = 3;
		
		public var type:int;
		public var rgbList:Array;
		public var intensity:Number;
		public var fadeStart:Number;
		public var fadeEnd:Number;
		public var innerAngle:Number;
		public var outerAngle:Number;
		private var _color:uint;
		
		public function FELightGeometry() 
		{
			rgbList = [0, 0, 0];
			type = DIRECTIONAL;
			color = 0xFFE500;
			intensity = 1;
		}
		
		public function get color():uint 
		{
			return _color;
		}
		
		public function set color(value:uint):void 
		{
			_color = value;
			rgbList[0] = (_color >> 16 & 0xFF) / 0xFF;
			rgbList[1] = (_color >> 8 & 0xFF) / 0xFF;
			rgbList[2] = (_color & 0xFF) / 0xFF;
		}
		
		override public function toFBXNode():FBXNode 
		{
			var node:FBXNode = new FBXNode(null, [id, "NodeAttribute::", "Light"]);
			var p70:Array = [
				["Color", "Color", "", "A", rgbList[0], rgbList[1], rgbList[2]],
				["Intensity", "Number", "", "A", intensity * 100],
				["LightType", "enum", "", "", type],
				["DrawGroundProjection", "bool", "", "", 0],
				["Fog", "Number", "", "A", 0],
				["DecayStart", "Number", "", "A", 0],
				["NearAttenuationEnd", "Number", "", "A", 0],
				["FarAttenuationStart", "Number", "", "A", 0],
				["FarAttenuationEnd", "Number", "", "A", 0]
			];
			FBXParser.addPropertyNode(node, p70);
			node.addValue("TypeFlags", ["Light"]);
			node.addValue("GeometryVersion", [124]);
			return node;
		}
		
	}

}