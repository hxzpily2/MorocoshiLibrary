package net.morocoshi.common.loaders.collada.nodes 
{
	import net.morocoshi.common.loaders.collada.ColladaCollector;
	import net.morocoshi.common.loaders.collada.ColladaUtil;
	import net.morocoshi.common.text.XMLUtil;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class ColladaAnimationNode extends ColladaNode 
	{
		public var animationData:Object;
		
		public function ColladaAnimationNode() 
		{
			animationData = { };
		}
		
		override public function parse(xml:XML, collector:ColladaCollector):void 
		{
			super.parse(xml, collector);
			
			var id:String;
			var sourceData:Object = { };
			var samplerData:Object = { };
			for each(var source:XML in xml.source)
			{
				id = XMLUtil.getAttrString(source, "id", "");
				sourceData[id] = ColladaUtil.getSource(source);
			}
			
			for each(var sampler:XML in xml.sampler)
			{
				var animation:ColladaAnimationData = new ColladaAnimationData();
				samplerData[sampler.@id] = animation;
				for each(var input:XML in sampler.input)
				{
					var sourceID:String = String(input.@source).substr(1);
					switch(String(input.@semantic))
					{
						case "INPUT": animation.times = sourceData[sourceID]; break;
						case "OUTPUT": animation.values = sourceData[sourceID]; break;
						case "INTERPOLATION": animation.tangents = sourceData[sourceID]; break;
						case "IN_TANGENT": animation.inTangent = sourceData[sourceID]; break;
						case "OUT_TANGENT": animation.outTangent = sourceData[sourceID]; break;
					}
				}
			}
			
			for each(var channel:XML in xml.channel)
			{
				var targetPath:String = XMLUtil.getAttrString(channel, "target", "");
				var targetData:Array = targetPath.split("/");
				var anm:ColladaAnimationData = samplerData[String(channel.@source).substr(1)];
				//MAYAのUVアニメでtarget="xxxxx/common/offsetV"とかある。commonはいらない？
				var type:String = targetData[targetData.length - 1];
				if (animationData[targetData[0]] == null)
				{
					animationData[targetData[0]] = { };
				}
				anm.type = type;
				animationData[targetData[0]][type] = anm;
			}
		}
		
	}

}