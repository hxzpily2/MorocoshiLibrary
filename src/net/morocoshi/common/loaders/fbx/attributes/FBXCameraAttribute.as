package net.morocoshi.common.loaders.fbx.attributes 
{
	import net.morocoshi.common.loaders.fbx.FBXNode;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class FBXCameraAttribute extends FBXAttribute 
	{
		public var fovX:Number;
		public var fovY:Number;
		public var aspectWidth:Number;
		public var aspectHeight:Number;
		public var zNear:Number = NaN;
		public var zFar:Number = NaN;
		
		public function FBXCameraAttribute(node:FBXNode = null)
		{
			super(node);
		}
		
		override public function parse(node:FBXNode):void 
		{
			super.parse(node);
			
			if (param.FocalLength != null)
			{
				var mm:Number = 25.4;
				var fl:Number = param.FocalLength;
				var fw:Number = param.FilmWidth * mm / 2;
				var fh:Number = param.FilmHeight * mm / 2;
				fovX = 2 * Math.atan2(fw, fl);
				fovY = 2 * Math.atan2(fh, fl);
			}
			else
			{
				fovX = 80 / 180 * Math.PI;
				fovY = 60 / 180 * Math.PI;
			}
			if (param.AspectWidth != null) aspectWidth = param.AspectWidth;
			if (param.AspectHeight != null) aspectHeight = param.AspectHeight;
			if (param.NearPlane != null) zNear = param.NearPlane;
			if (param.FarPlane != null) zFar = param.FarPlane;
		}
		
	}

}