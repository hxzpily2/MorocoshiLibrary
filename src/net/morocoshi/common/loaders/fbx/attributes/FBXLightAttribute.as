package net.morocoshi.common.loaders.fbx.attributes 
{
	import net.morocoshi.common.loaders.fbx.FBXNode;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class FBXLightAttribute extends FBXAttribute 
	{
		public var enabled:Boolean = true;
		public var color:uint = 0xffffff;
		public var type:int = 0;
		public var intensity:Number = 1;
		public var useNear:Boolean = false;
		public var useFar:Boolean = false;
		public var innerAngle:Number = 0;
		public var outerAngle:Number = 1;
		public var nearStart:Number;
		public var nearEnd:Number;
		public var farStart:Number = 0;
		public var farEnd:Number = 1000;
		
		public function FBXLightAttribute(node:FBXNode = null) 
		{
			super(node);
		}
		
		override public function parse(node:FBXNode):void 
		{
			super.parse(node);
			enabled = param.CastLightOnObject != false;
			if (param.Color != null) color = param.Color;
			if (param.LightType != null) type = param.LightType;
			if (param.Intensity != null) intensity = param.Intensity * 0.01;
			
			useNear = param.EnableNearAttenuation == true;
			useFar = param.EnableFarAttenuation == true;
			
			if (param.NearAttenuationStart != null) nearStart = param.NearAttenuationStart;
			if (param.NearAttenuationEnd != null) nearEnd = param.NearAttenuationEnd;
			if (param.FarAttenuationStart != null) farStart = param.FarAttenuationStart;
			if (param.FarAttenuationEnd != null) farEnd = param.FarAttenuationEnd;
			
			if (param.InnerAngle != null) innerAngle = param.InnerAngle * Math.PI / 180;
			if (param.OuterAngle != null) outerAngle = param.OuterAngle * Math.PI / 180;
			
		}
		
	}

}