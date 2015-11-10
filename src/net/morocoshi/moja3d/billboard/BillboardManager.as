package net.morocoshi.moja3d.billboard 
{
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import net.morocoshi.common.math.list.VectorUtil;
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
		private var itemMap:Dictionary;
		
		public function BillboardManager() 
		{
			items = new Vector.<BillboardItem>;
			tempVector = new Vector3D();
			itemMap = new Dictionary();
		}
		
		/**
		 * オブジェクトをビルボード化する
		 * @param	object	対象オブジェクト
		 * @param	pivot	軸回転モードにするか
		 * @param	plane	カメラ平面に対して正面を向くかどうか。通常のビルボードはtrue。falseでカメラの視点を向くようになる。
		 * @param	frontAxis	オブジェクトの正面方向の軸を指定。["+x", "-z"]
		 * @param	topAxis	オブジェクトの上方向の軸を指定。["+x", "-z"]
		 * @return
		 */
		public function addObject(object:Object3D, pivot:Boolean, plane:Boolean, frontAxis:String, topAxis:String):BillboardItem
		{
			var item:BillboardItem = new BillboardItem(object, pivot, plane, frontAxis, topAxis);
			items.push(item);
			itemMap[object] = item;
			return item;
		}
		
		/**
		 * オブジェクトのビルボード化を解除する
		 * @param	object
		 * @return
		 */
		public function removeObject(object:Object3D):Boolean
		{
			var item:BillboardItem = itemMap[object];
			if (item == null) return false;
			
			delete itemMap[item];
			
			return VectorUtil.deleteItem(items, item);
		}
		
		/**
		 * 全てのビルボード化を解除する
		 */
		public function removeAllObject():void 
		{
			items.length = 0;
			itemMap = new Dictionary();
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
				if (item.enabled == false) continue;
				
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
		
	}

}