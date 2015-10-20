package net.morocoshi.moja3d.resources 
{
	import flash.display3D.Context3D;
	import net.morocoshi.moja3d.bounds.BoundingBox;
	import net.morocoshi.moja3d.objects.Surface;
	/**
	 * ...
	 * @author tencho
	 */
	public class CombinedGeometry extends Geometry 
	{
		public var geometries:Vector.<Geometry>;
		//public var surfacesList:Vector.<Vector.<Surface>>;
		
		public function CombinedGeometry() 
		{
			super();
			
			geometries = new Vector.<Geometry>;
			//surfacesList = new Vector.<Vector.<Surface>>;
			//___ここなんとかする
			//isUploaded = true;
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
		
		override public function upload(context3D:Context3D, async:Boolean = false, complete:Function = null):void 
		{
			for each (var item:Geometry in geometries) 
			{
				item.upload(context3D, async, complete);
			}
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