package net.morocoshi.moja3d.objects 
{
	import flash.utils.Dictionary;
	import net.morocoshi.moja3d.moja3d;
	
	use namespace moja3d;
	
	/**
	 * 距離で表示を変化させるオブジェクト
	 * 
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
		
		/**
		 * 表示するオブジェクトを登録する。登録されたオブジェクトはLODオブジェクトの子に追加される。
		 * @param	object	登録するオブジェクト
		 * @param	min	カメラからの距離がこの値「以上」から表示しはじめる
		 * @param	max	カメラからの距離がこの値「未満」まで表示する
		 * @return
		 */
		public function registerObject(object:Object3D, min:Number, max:Number):Object3D
		{
			addChild(object);
			items[object] = new LODItem(object, min, max);
			return object;
		}
		
		/**
		 * 登録したオブジェクトを削除する。削除に成功すればtrueが返る。
		 * @param	object
		 */
		public function unregisterObject(object:Object3D):Boolean
		{
			delete items[object];
			return removeChild(object);
		}
		
		moja3d function checkDistance(camera:Camera3D):void 
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
		
		override public function clone():Object3D 
		{
			var result:LOD = new LOD();
			cloneProperties(result);
			//子を再帰的にコピーする
			for (var current:Object3D = _children; current; current = current._next)
			{
				var child:Object3D = current.clone();
				var item:LODItem = items[current];
				if (item) result.items[child] = new LODItem(child, item.min, item.max);
				result.addChild(child);
			}
			return result;
		}
		
	}

}