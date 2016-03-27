package net.morocoshi.moja3d.shaders.shadow
{
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.agal.AGALConstant;
	import net.morocoshi.moja3d.objects.Object3D;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class CircleShadowUnit 
	{
		public var object:Object3D;
		public var offset:Number;
		public var height:Number;
		public var alpha:Number;
		public var scale:Number;
		public var positionConst:AGALConstant;
		public var dataConst:AGALConstant;
		
		public function CircleShadowUnit() 
		{
			
		}
		
		public function update():void 
		{
			if (positionConst == null || dataConst == null) return;
			
			var point:Vector3D = object.getWorldPosition();
			positionConst.x = point.x;
			positionConst.y = point.y;
			positionConst.z = point.z;
			dataConst.x = offset;
			dataConst.y = height;
			dataConst.z = alpha;
			dataConst.w = scale;
		}
		
	}

}