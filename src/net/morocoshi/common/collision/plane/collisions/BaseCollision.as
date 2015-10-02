package net.morocoshi.common.collision.plane.collisions
{
	import flash.geom.Rectangle;
	import net.morocoshi.common.partitioning.quadtree.TreeData;
	
	/**
	 * 2Dコリジョン基礎クラス
	 * 
	 * @author	tencho
	 */
	public class BaseCollision 
	{
		public var _type:int;
		public var _enabled:Boolean = true;
		public var treeData:TreeData;
		
		/**コリジョン領域*/
		public var _rect:Rectangle = new Rectangle();
		
		public function BaseCollision() 
		{
			treeData = new TreeData(this);
			treeData.useHitList = false;
		}
		
		/**コリジョンが有効か*/
		public function get enabled():Boolean 
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void 
		{
			_enabled = value;
		}
		
		/**コリジョンタイプ*/
		public function get type():int 
		{
			return _type;
		}
		
	}

}