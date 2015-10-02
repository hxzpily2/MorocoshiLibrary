package net.morocoshi.common.loaders.collada.nodes 
{
	import net.morocoshi.common.loaders.collada.ColladaCollector;
	import net.morocoshi.common.loaders.collada.ColladaUtil;
	import net.morocoshi.common.text.XMLUtil;
	/**
	 * ...
	 * @author tencho
	 */
	public class ColladaEffectNode extends ColladaNode
	{
		public var alpha:Number = 1;
		public var ambientColor:uint = 0x808080;
		public var diffuseColor:uint = 0x808080;
		public var diffuseTexture:String = "";
		public var transparentTexture:String = "";
		
		public function ColladaEffectNode() 
		{
		}
		
		override public function parse(xml:XML, collector:ColladaCollector):void
		{
			super.parse(xml, collector);
			
			var common:XML = xml.profile_COMMON[0];
			if (!common) return;
			
			var sourceLink:Object = { };
			var pathLink:Object = { };
			for each(var newparam:XML in common.newparam)
			{
				var sid:String = newparam.@sid;
				var source:XML = newparam.sampler2D.source[0];
				var path:XML = newparam.surface.init_from[0];
				if (source) sourceLink[sid] = String(source);
				if (path) pathLink[sid] = String(path);
			}
			
			var technique:XML = common.technique[0];
			if (!technique) return;
			
			var shader:XML = technique.blinn[0] || technique.phong[0];
			if (!shader) return;
			
			
			ambientColor = ColladaUtil.toARGB(shader.ambient.color[0], 0x808080) & 0xffffff;
			diffuseColor = ColladaUtil.toARGB(shader.diffuse.color[0], 0x808080) & 0xffffff;
			var diffuseSID:String = XMLUtil.getAttrString(shader.diffuse.texture[0], "texture", "");
			diffuseTexture = sourceLink[diffuseSID] && pathLink[sourceLink[diffuseSID]];
			var transparentSID:String = XMLUtil.getAttrString(shader.transparent.texture[0], "texture", "");
			transparentTexture = sourceLink[transparentSID] && pathLink[sourceLink[transparentSID]];
			alpha = XMLUtil.getNodeNumber(shader.transparency.float[0], 1);
		}
		
	}

}