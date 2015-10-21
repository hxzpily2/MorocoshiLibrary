package net.morocoshi.moja3d.renderer 
{
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Matrix3D;
	import net.morocoshi.moja3d.shaders.ShaderList;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class RenderElement 
	{
		internal var next:RenderElement;
		internal var prev:RenderElement;
		
		public var name:String;
		public var sortPriority:Number;
		public var matrix:Matrix3D;
		public var culling:String;
		public var layer:uint;
		
		//public var passCompareMode:String;
		//public var depthMask:Boolean;
		public var sourceFactor:String;
		public var destinationFactor:String;
		public var useRefrectionTexture:Boolean;
		public var vertexBufferList:Vector.<VertexBuffer3D>;
		public var vertexBufferFormatList:Vector.<String>;
		public var indexBuffer:IndexBuffer3D;
		public var firstIndex:int;
		public var numTriangles:int;
		public var shaderList:ShaderList;
		
		/**カメラ平面からの距離（レンダラ内で計算）*/
		public var distance:Number;
		
		public function RenderElement() 
		{
			layer = RenderLayer.OPAQUE;
			sortPriority = 0;
			firstIndex = 0;
			numTriangles = -1;
			useRefrectionTexture = false;
			culling = Context3DTriangleFace.NONE;
			sourceFactor = Context3DBlendFactor.SOURCE_ALPHA;
			destinationFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			vertexBufferList = new Vector.<VertexBuffer3D>;
			vertexBufferFormatList = new Vector.<String>;
		}
		
		/**
		 * リストの長さを返す。自分より前にあるものはカウントしない。連結数だけループして確認するので注意。
		 * @return
		 */
		public function getLength():int
		{
			var count:int = 0;
			var current:RenderElement = this;
			while (current)
			{
				count++;
				current = current.next;
			}
			return count;
		}
		
	}

}