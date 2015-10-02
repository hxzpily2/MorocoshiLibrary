package net.morocoshi.moja3d.billboard 
{
	import flash.geom.Vector3D;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.objects.Camera3D;
	import net.morocoshi.moja3d.objects.Object3D;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class BillboardManager 
	{
		private var items:Vector.<BillboardItem>;
		private var tempVector:Vector3D;
		
		public function BillboardManager() 
		{
			items = new Vector.<BillboardItem>;
			tempVector = new Vector3D();
		}
		
		public function addObject(object:Object3D, pivot:Boolean, plane:Boolean, frontAxis:String, topAxis:String):BillboardItem
		{
			var item:BillboardItem = new BillboardItem(object, pivot, plane, frontAxis, topAxis);
			items.push(item);
			return item;
		}
		
		public function lookAtCamera(camera:Camera3D, upAxis:Vector3D = null):void
		{
			if (upAxis == null)
			{
				upAxis = Vector3D.Z_AXIS;
			}
			var look:Vector3D = camera.getWorldAxisZ(false);
			//look.scaleBy(-1);
			
			var n:int = items.length;
			for (var i:int = 0; i < n; i++) 
			{
				var item:BillboardItem = items[i];
				if (item.plane)
				{
					item.lookAt(look, upAxis);
				}
				else
				{
					var p1:Vector3D = camera._worldMatrix.position;
					var p2:Vector3D = item.object.worldMatrix.position;
					tempVector.x = p1.x - p2.x;
					tempVector.y = p1.y - p2.y;
					tempVector.z = p1.z - p2.z;
					item.lookAt(tempVector, upAxis);
				}
			}
		}
		
		public function removeAllObject():void 
		{
			items.length = 0;
		}
		
	}

}