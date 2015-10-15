package net.morocoshi.moja3d.loader.objects 
{
	import net.morocoshi.moja3d.loader.animation.M3DAnimation;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class M3DObject 
	{
		public var id:int = 0;
		/**インデックスではなくIDなので注意*/
		public var layer:int = 0;
		/**インデックスではなくIDなので注意*/
		public var parent:int = -1;
		//最終的なObject名。FBXで同名のオブジェクトがあるとまずいのでリネームされている場合がある。
		public var name:String = "";
		//リネームされていない本来のObject3D名。アニメーションデータをアタッチする際に使う。
		public var animationID:String = "";
		//表示するか
		public var visible:Boolean = true;
		//位置回転サイズ
		public var matrix:Vector.<Number>;
		//UserData
		public var userData:Object = {};
		//ジオメトリ
		public var geometryID:int = -1;
		//アニメ―ションデータ
		public var animation:M3DAnimation;
		
		public function M3DObject() 
		{
		}
		
		public function getKey():String
		{
			var key:String = String(visible);
			if (userData)
			{
				var users:Array = [];
				for (var k:String in userData) 
				{
					users.push(k + "=" + userData[k]);
				}
				users.sort();
				key += users.join("|");
			}
			return key;
		}
		
		public function toM3DObject3D():M3DObject 
		{
			var result:M3DObject = new M3DObject();
			result.animation = animation;
			result.animationID = animationID;
			result.id = id;
			result.layer = layer;
			result.matrix = matrix;
			result.name = name;
			result.parent = parent;
			result.userData = userData;
			result.visible = visible;
			return result;
		}
		
		public function get hasUserData():Boolean 
		{
			if (userData == null) return false;
			for (var key:String in userData) 
			{
				return true;
			}
			return false;
		}
		
	}

}