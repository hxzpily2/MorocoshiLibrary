package net.morocoshi.common.loaders.collada.nodes 
{
	import net.morocoshi.common.loaders.collada.ColladaCollector;
	import net.morocoshi.common.loaders.collada.ColladaUtil;
	import net.morocoshi.common.text.XMLUtil;
	/**
	 * ...
	 * @author tencho
	 */
	public class ColladaLightNode extends ColladaNode
	{
		static public const TYPE_AMBIENT:int = 0;
		static public const TYPE_DIRECTIONAL:int = 1;
		static public const TYPE_OMNI:int = 2;
		
		public var type:uint;
		public var color:uint;
		public var fadeEnabled:Boolean;
		public var fadeStart:Number;
		public var fadeEnd:Number;
		public var intensity:Number;
		
		public function ColladaLightNode() 
		{
			type = TYPE_AMBIENT;
			color = 0xffffff;
			fadeEnabled = false;
			fadeStart = 0;
			fadeEnd = 0;
			intensity = 1;
		}
		
		override public function parse(xml:XML, collector:ColladaCollector):void
		{
			super.parse(xml, collector);
			var common:XML = xml.technique_common[0];
			if (common.ambient.length() >= 1)
			{
				type = TYPE_AMBIENT;
				color = ColladaUtil.toRGB(common.ambient[0].color[0], 0xffffff);
			}
			if (common.point.length() >= 1)
			{
				type = TYPE_OMNI;
				color = ColladaUtil.toRGB(common.point[0].color[0], 0xffffff);
			}
			if (common.directional.length() >= 1)
			{
				type = TYPE_DIRECTIONAL;
				color = ColladaUtil.toRGB(common.directional[0].color[0], 0xffffff);
			}
			trace(name, color.toString(16));
			
			if (xml.extra.technique.max_light.length() >= 1)
			{
				var max:XML = xml.extra.technique.max_light[0];
				fadeStart = XMLUtil.getNodeNumber(max.attenuation_far_start[0], 0);
				fadeEnd = XMLUtil.getNodeNumber(max.attenuation_far_end[0], 0);
				fadeEnabled = XMLUtil.getNodeNumber(max.use_far_attenuation[0], 0) == 1;
				intensity = XMLUtil.getNodeNumber(max.multiplier[0], 1);
			}
		}
		
	}

}