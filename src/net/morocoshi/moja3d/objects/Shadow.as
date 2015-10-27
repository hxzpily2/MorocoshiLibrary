package net.morocoshi.moja3d.objects 
{
	import flash.display3D.Context3D;
	import net.morocoshi.moja3d.materials.preset.FillMaterial;
	import net.morocoshi.moja3d.materials.TriangleFace;
	import net.morocoshi.moja3d.moja3d;
	import net.morocoshi.moja3d.primitives.Cube;
	import net.morocoshi.moja3d.resources.RenderTextureResource;
	import net.morocoshi.moja3d.view.ContextProxy;
	
	use namespace moja3d;
	
	/**
	 * デプスシャドウに使うシャドウライト
	 * 
	 * @author tencho
	 */
	public class Shadow extends Camera3D
	{
		public var textureWidth:Number;
		public var textureHeight:Number;
		public var intensity:Number;
		public var shadowTexture:RenderTextureResource;
		public var lightTexture:RenderTextureResource;
		public var depthBias:Number;
		public var radiusNear:Number;
		public var radiusFar:Number;
		public var blur:Number;
		public var numSamples:int;
		
		private var debugCube:Cube;
		
		public function Shadow() 
		{
			super();
			_debug = false;
			
			orthographic = true;
			_zNear = -200;
			_zFar = 10000;
			
			_width = 300;
			_height = 300;
			radiusNear = 100;
			radiusFar = 150;
			setShadowArea(149, 150);
			rotationY = Math.PI;
			updateFrustum();
			
			blur = 0.002;
			numSamples = 5;
			depthBias = 0.03;
			
			textureWidth = 1024;
			textureHeight = 1024;
			fovX = 80 / 180 * Math.PI;
			fovY = 60 / 180 * Math.PI;
			intensity = 1;
			shadowTexture = new RenderTextureResource();
			lightTexture = new RenderTextureResource();
			
			var fm:FillMaterial = new FillMaterial(0xff0000, 0.5, true);
			fm.culling = TriangleFace.BOTH;
			debugCube = new Cube(1, 1, 1, 1, 1, 1, fm);
			debugCube.name = "ShadowCube"
			debugCube.castShadowEnabled = false;
			addChild(debugCube);
			
			debug = _debug;
		}
		
		public function setShadowArea(near:Number, far:Number):void 
		{
			radiusNear = near;
			radiusFar = far;
			_width = _height = far / Math.cos(Math.PI / 4) * 2;
		}
		
		override public function set debug(value:Boolean):void 
		{
			super.debug = value;
			debugCube.visible = _debug;
		}
		
		public function updateDebugModel():void
		{
			debugCube.scaleX = width;
			debugCube.scaleY = height;
			debugCube.scaleZ = zFar - zNear;
			debugCube.x = 0;
			debugCube.y = 0;
			debugCube.z = debugCube.scaleZ * -0.5 - zNear;
			debugCube.calculteWorldMatrix();
		}
		
		public function readyLightTexture(context3D:ContextProxy):void
		{
			lightTexture.createTexture(context3D, textureWidth, textureHeight);
		}
		
		public function readyShadowTexture(context3D:ContextProxy):void 
		{
			shadowTexture.createTexture(context3D, textureWidth, textureHeight);
		}
		
	}

}