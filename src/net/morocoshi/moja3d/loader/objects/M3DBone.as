package net.morocoshi.moja3d.loader.objects 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class M3DBone extends M3DObject 
	{
		/**何番目のボーンか。Stage3Dでの配列処理で使う*/
		public var index:int;
		/**どの頂点にも関連付けられていなかったらfalse*/
		public var enabled:Boolean;
		/**Matrix3D*/
		public var transformLink:Vector.<Number>;
		
		public function M3DBone() 
		{
		}
		
		override public function toM3DObject3D():M3DObject 
		{
			var result:M3DBone = new M3DBone();
			
			result.index = index;
			result.enabled = enabled;
			result.transformLink = transformLink;
			
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
		
	}

}