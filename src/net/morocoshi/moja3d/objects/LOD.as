package net.morocoshi.moja3d.objects 
{
	import flash.utils.Dictionary;
	import net.morocoshi.moja3d.moja3d;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class LOD extends Object3D
	{
		private var items:Dictionary;
		
		public function LOD() 
		{
			super();
			items = new Dictionary();
		}
		
		public function registerObject(object:Object3D, min:Number, max:Number):Object3D
		{
			addChild(object);
			items[object] = new LODItem(object, min, max);
			return object;
		}
		
		public function unregisterObject(object:Object3D):void
		{
			removeChild(object);
			delete items[object];
		}
		
		public function checkDistance(camera:Camera3D):void 
		{
			var m:Vector.<Number> = _worldMatrix.rawData;
			var d:Number = camera.getDistanceXYZ(m[12], m[13], m[14]);
			for each (var item:LODItem in items) 
			{
				item.object.visible = (item.min < d && d <= item.max);
			}
		}
		
		override public function reference():Object3D 
		{
			var result:LOD = new LOD();
			referenceProperties(result);
			//子を再帰的にコピーする
			for (var current:Object3D = _children; current; current = current._next)
			{
				var child:Object3D = current.reference();
				var item:LODItem = items[current];
				if (item) result.items[child] = new LODItem(child, item.min, item.max);
				result.addChild(child);
			}
			return result;
		}
		
	}

}