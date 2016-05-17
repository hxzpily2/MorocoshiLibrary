package net.morocoshi.moja3d.resources 
{
	import net.morocoshi.moja3d.bounds.BoundingBox;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class CombinedGeometry extends Geometry 
	{
		public var geometries:Vector.<Geometry>;
		
		public function CombinedGeometry() 
		{
			super();
			
			geometries = new Vector.<Geometry>;
		}
		
		override public function calculateBounds(boundingBox:BoundingBox):void 
		{
			var aabbList:Vector.<BoundingBox> = new Vector.<BoundingBox>;
			for each(var item:Geometry in geometries)
			{
				var aabb:BoundingBox = new BoundingBox();
				item.calculateBounds(aabb);
				aabbList.push(aabb);
			}
			var unioned:BoundingBox = BoundingBox.getUniondBoundingBox(aabbList);
			boundingBox.copyFrom(unioned);
		}
		
		override public function clone():Resource 
		{
			var result:CombinedGeometry = new CombinedGeometry();
			var n:int = geometries.length;
			for (var i:int = 0; i < n; i++) 
			{
				result.geometries.push(geometries[i].clone() as Geometry);
			}
			return result;
		}
		
		override public function upload(context3D:ContextProxy):Boolean 
		{
			for each (var item:Geometry in geometries) 
			{
				item.upload(context3D);
			}
			return true;
		}
		
		override public function dispose():void 
		{
			for each (var item:Geometry in geometries) 
			{
				item.dispose();
			}
		}
		
	}

}